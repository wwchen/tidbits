#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'mail'
require 'json'

USE_CACHE = true
DEBUG = false
SEND_EMAIL = true

unless USE_CACHE
  require "capybara"
  require "capybara/dsl"
  require "capybara-webkit"

  Capybara.app_host = "https://www.att.com"
  Capybara.current_driver = :webkit
  Capybara.default_wait_time = 5

  # place code below in features/support/headless.rb
  if Capybara.current_driver == :webkit
    require 'headless'
    headless = Headless.new
    headless.start
    at_exit do
      headless.destroy
    end
  end
  include Capybara::DSL
end

# read passwords from a config file
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG

class String
  def normalize
    return self.gsub(/[[:space:]]/,' ').gsub(/\u00e2\u0088\u0092/, '-').strip
  end
  def strip_to_f
    self.gsub(/[^-0-9\.]/, '').to_f
  end
  def titleize
    self.split(' ').map(&:capitalize).join(' ')
  end
end

class Hash
  # https://gist.github.com/weppos/6391
  def rmerge(other_hash)
    r = {}
    merge(other_hash) do |key, oldval, newval|
      r[key] = oldval.class == self.class ? oldval.rmerge(newval) : newval
    end
  end
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
      oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
  end
  def first_rkey(search)
    search = Regexp.new(search.to_s) unless search.is_a? Regexp
    return keys.detect { |k| k =~ search }
  end
  def rkey(search)
    first_rkey search
  end
  def has_rkey?(search)
    return !!first_rkey(search)
  end
  
  # return the value of the key in regex. Nil if not found
  def rvalue(search)
    return nil unless has_rkey? search
    return self[first_rkey(search)]
  end
end

##
# Grabs the AT&T bill summary
##
class Att
  attr_accessor :bill, :bill_json
  def initialize
    @bill = {:period => '', :summary => [], :total => ''}
    @bill_json = {}
    @bill_html = nil
    @bill_totals = {}
    @is_logged_in = false
  end

  #
  # private helper
  def get_total(arg)
    level, hash = arg
    totals = {}
    hash.each do |k, v|
      if v.is_a? Hash
        subtotal = get_total([level, v])
        if subtotal[0] >= 1
          level = [level, subtotal[0]].max
          total = v.first_rkey("Total " + k.split(' ')[0])
          totals[k] = {}
          totals[k].merge! subtotal[1]
          totals[k]["Total"] = v[total] unless total.nil?
        end
      else
        level = 0
        totals[k] = v if k == "Total"
      end
    end
    return [level+1, totals]
  end

  # find all table rows and convert to json
  def table_to_json(element)
    json = {}
    rows = element.xpath(".//tr")
    rows.each do |row|
      cols = row.xpath(".//td").map { |x| x.text.normalize }
      cols.delete_if { |x| x.empty? }
      json[cols[0]] = cols[-1] if cols.count > 1
    end
    return json
  end

  private :get_total, :table_to_json

  # 
  # public
  def login
    if USE_CACHE
      STDERR.puts "Using cache, so faking login.. Logged in!"
      return
    end
    puts "Loading the ATT login portal"
    visit('/olam/passthroughAction.myworld?actionType=Manage')
    sleep 1

    puts "Filling in credentials"
    fill_in "userid",   :with => CONFIG['ATT_USERNAME']
    fill_in "password", :with => CONFIG['ATT_PASSWORD']
    click_button 'Login'
    sleep 1
    if has_text? "The User ID and password combination you entered doesn't match any entries in our files."
      abort "There was a problem with the AT&T username and password combination. Check and try again"
    end

    puts "Submitting passcode"
    fill_in "passcode", :with => CONFIG['ATT_PASSCODE']
    click_button 'Continue'
    if has_text? "The passcode should be the same code you use to access account information when you call 611"
      abort "There was a problem with the AT&T passcode for the account. Check and try again"
    end
    @is_logged_in = true
  end

  def get_bill_summary
    if USE_CACHE
      STDERR.puts "Using cache, so faking getting the bill summary.. Fetched!"
      return
    end
    login unless @is_logged_in
    puts "Opening bill details"
    click_link 'Bill Details'

    title = find(:xpath, '//*[@id="toggleWirelesstrWirelessCounter11"]/div/div[3]/h3/a').text
    @bill[:period] = title.sub(/.*- /, '').strip
    begin
      (6..14).step(2).each do |i|
        name   = find(:xpath, "//*[@id='toggleWirelesstrWirelessCounter11']/div/div[#{i}]/h3/b/span[1]/span/span[1]").text.strip
        number = find(:xpath, "//*[@id='toggleWirelesstrWirelessCounter11']/div/div[#{i}]/h3/b/span[1]/span/span[2]").text.strip
        total  = find(:xpath, "//*[@id='toggleWirelesstrWirelessCounter11']/div/div[#{i}]/h3/b/span[2]").text.strip
        @bill[:summary].push [name, number, total]
      end
    rescue
    end
    @bill[:total] = find(:xpath, '//*[@id="toggleWirelesstrWirelessCounter11"]/div/div[14]/table/tfoot/tr/td[3]').text.strip

    # bill details page
    #save_screenshot 'screenshot.png'

    # bill full summary page
    visit '/pmt/jsp/titan/wireless/billPay-billSummary-printView.jsp?tooltip=no'
    save_page 'bill.html'
    save_screenshot 'bill.png'

    # put the html in a class variable
    @bill_html = open 'bill.html'
  end

  # parse the bill.html
  def parse
    #get_bill_summary unless @bill_html
    bill = open('bill.html') if USE_CACHE
    bill = @bill_html unless USE_CACHE
    doc = Nokogiri::HTML(bill)
    @bill_json = {}
    # header text with name + phone number
    accounts = doc.xpath("//h3[@class='CTNName']")
    accounts.each do |account|
      name, number, total = account.text.match(/(.*)(\d{3}-\d{3}-\d{4}).*(\$[\d\.]+)/)[1,3].map { |x| x.normalize }
      @bill_json[number] = { "Total" => total, "Name" => name.titleize }

      # find the main category breakdowns
      categories = account.parent.next.css("h3.categoryLabel")
      categories.each do |category|
        title = category.text.normalize
        category = category.parent.next
        @bill_json[number][title] = {}

        subcategories = category.css('h4') # TODO code cleanup.. reiteration of categories again
        subcategories.each do |subcategory|
          subtitle = subcategory.text.normalize
          subcategory = subcategory.parent.next
          @bill_json[number][title][subtitle] = table_to_json(subcategory)
          subcategory.remove
        end

        @bill_json[number][title].merge! table_to_json(category)
      end
    end
    return @bill_json
  end

  def get_bill_totals
    return get_total([0, @bill_json])[1]
  end

  def rebalance_bill
    # Let's not worry about the subsections for now
    totals = @bill_json.rmerge get_bill_totals
    total_familytalk = 0.0
    num_lines = @bill_json.keys.count

    totals.each do |line, charges|
      totals[line]['New total'] = nil
      next unless charges.is_a? Hash
      charges.each do |section, summary|
        next unless summary.is_a? Hash
        familytalk = summary.rvalue /FamilyTalk/i
        discount   = summary.rvalue /Discount/i
        total      = summary["Total"].strip_to_f
        unless familytalk.nil?
          discount = '0' if discount.nil?
          subtotal = familytalk.strip_to_f + discount.strip_to_f
          total_familytalk += subtotal

          #totals[line][section]['New total'] = "$%0.2f" % (total - subtotal)
          totals[line][section]['New total'] = total - subtotal
          totals[line]['New total'] = charges['Total'].strip_to_f - subtotal
        end
      end
    end

    # average out the familytalk
    avg_familytalk = total_familytalk / num_lines

    # add back to each line
    totals.each do |line, charges|
      next unless charges.is_a? Hash
      charges.each do |section, summary|
        next unless summary.is_a? Hash
        next unless summary.has_rkey? /Monthly Charges/i
        subtotal = summary['New total']
        #next if subtotal.nil?
        totals[line][section]['New total'] = "$%0.2f" % (subtotal + avg_familytalk)
        totals[line]['New total'] = "$%0.2f" % (charges['New total'] + avg_familytalk)
      end
    end

    # play out the new totals
    puts "Averaged familytalk: %0.2f" % avg_familytalk
    totals.each do |line, charges|
      next unless charges.is_a? Hash
      charges.each do |section, summary|
        next unless summary.is_a? Hash
        next unless summary.has_rkey? /Monthly Charges/i

        puts ""
        puts "=*=*=*=*=*=*=*=*=*=*=*=*"
        puts "=*=*= %s =*=*=" % line
        puts "Original subtotal: %s" % summary["Total"]
        puts "New subtotal:      %s" % summary["New total"]
        puts "Original total:    %s" % charges["Total"]
        puts "New total:         %s" % charges["New total"]
        puts "=*=*=*=*=*=*=*=*=*=*=*=*"
      end
    end

    @bill_json = totals
  end

  # TODO add the national discount in
  # FIXME deprecate?
  def rebalance_bill2
    totals = @bill_json.rmerge get_bill_totals
    total_familytalk = 0
    num_lines = @bill_json.keys.count
    # get the average
    @bill_json.each do |line, charges|
      # get the monthly voice charges
      monthly_charge_key = charges.first_rkey /Monthly Charges/i
      familytalk_key     = charges[monthly_charge_key].first_rkey /FamilyTalk/i
      discount_key       = charges[monthly_charge_key].first_rkey /Discount/i
      next unless monthly_charge_key # FIXME raise error
      next unless familytalk_key     # FIXME
      familytalk = charges[monthly_charge_key][familytalk_key]
      discount   = charges[monthly_charge_key][discount_key]
      discount   = '0' if discount.nil?
      price      = familytalk.strip_to_f + discount.strip_to_f
      total_familytalk += price

      monthly_total = totals[line][monthly_charge_key]["Total"].strip_to_f - price
      totals[line][monthly_charge_key]["Subtotal"] = monthly_total

      # double check on the math
      # get the totals of all the sections and add against the 'total'
      # NOT NECESSARY
#      sections_total = 0
#      account_total = charges['Total'].strip_to_f
#      charges.each do |k,section|
#        if section.is_a? Hash
#          key = section.first_rkey("Total " + k.split(' ')[0])
#          section_total = section[key].strip_to_f
#          sections_total += section_total
#          puts "%s's %s: %s" % [line, k.sub(/ - .*/,''), section_total] if DEBUG
#        end
#      end
#      # given that the calculated difference is less than five cents, don't raise an error
#      if DEBUG
#        puts "%s's sections total: %s" % [line, sections_total]
#        puts "%s's total: %s" % [line, account_total]
#        puts "%s's calculated difference in total: %s" % [line, (account_total-sections_total)]
#      end
#      difference = (account_total - sections_total).abs
#      if difference > 0.05
#        # FIXME raise error
#        STDERR.puts "WRONG WRONG WRONG. Calculated difference for %s is over five cents" % line
#      end
#
#      puts "%s's total: $%0.2s" % [line, account_total]
    end

    avg = (total_familytalk/num_lines)
    if DEBUG
      puts "total family talk: $%0.2f" % total_familytalk
      puts "average family talk: $%0.2f" % avg
    end
    puts "average family talk: $%0.2f" % avg

    orig_totals = get_bill_totals
    totals.each do |line, sections|
      monthly_charge_key = sections.first_rkey /Monthly Charges/i
      puts "======= %s =========" % line
      puts "monthly charge: $%0.2f" % orig_totals[line][monthly_charge_key]["Total"].strip_to_f
      puts "total: $%0.2f"          % orig_totals[line]["Total"].strip_to_f

      puts "new monthly charge: $%0.2f" % (totals[line][monthly_charge_key]["Total"].strip_to_f + avg)
      #puts "new total: $%0.2f" % totals[line]["Total"] 
      puts "==============================" % line
    end





#    @bill_json.each do |line, charges|
#      # get the monthly voice charges
#      monthly_charge_key = charges.first_rkey /Monthly Charges/i
#      familytalk_key     = charges[monthly_charge_key].first_rkey /FamilyTalk/i
#      discount_key       = charges[monthly_charge_key].first_rkey /Discount/i
#      next unless monthly_charge_key # FIXME raise error
#      next unless familytalk_key     # FIXME
#      familytalk = charges[monthly_charge_key][familytalk_key]
#      discount   = charges[monthly_charge_key][discount_key]
#      discount   = '0' if discount.nil?
#      price      = familytalk.strip_to_f + discount.strip_to_f
#      total_familytalk += price
#
#      # get the monthly voice charges
#      monthly_charge = charges.first_rkey /Monthly Charges/i
#      familytalk = charges[monthly_charge].first_rkey /FamilyTalk/i
#      price = charges[monthly_charge][familytalk].strip_to_f
#      account_total = charges['Total'].strip_to_f
#
#      puts "======= %s =========" % line
#      puts "monthly charge: $%0.2f" % price
#      puts "total: $%0.2f" % account_total
#
#      avg = (total_familytalk/num_lines)
#      if price > avg
#        delta = price - avg
#        price = avg
#        account_total -= delta
#      else
#        delta = avg - price
#        price = avg
#        account_total += delta
#      end
#      
#      puts "new monthly charge: $%0.2f" % (price)
#      puts "new total: $%0.2f" % account_total
#      puts "==============================" % line
#    end
  end
end



spider = Att.new
spider.login
spider.get_bill_summary
spider.parse
spider.rebalance_bill

File.open('bill.json', 'w') { |f| f.write JSON.pretty_generate(spider.bill_json) }

header_strings = []
html_strings = []
html = ""
spider.bill_json.each do |line, charges|
  html += "<h3>%s - %s</h3>" % [line, charges["Name"]]
  if charges.is_a? Hash
    html += "<table>"
    charges.each do |section, summary|
      next unless summary.is_a? Hash
      html += "<tr>"
      html += "<td>%s &nbsp;</td>" % section
      html += "<td>%s &nbsp;</td>" % summary["Total"]
      html += "<td>%s</td>"        % (summary["New total"] || summary["Total"])
      html += "</tr>"
    end
  end
  html += "<tr>"
  html += "<td>%s</td>"         % "Bill Total"
  html += "<td>%s</td>"         % charges["Total"]
  html += "<td><b>%s</b></td>"  % charges["New total"]
  html += "</tr></table>"
end

email = <<-eos
<p>The information below is retrieved on #{Time.now.strftime "%A %B %-m, %Y, %I:%M %p"} by logging onto AT&T online portal.</p>
<p>Attached is the bill summary in full details. Use it to verify the validity of all information here</p>
<p>Transfer money via <a href='https://bankofamerica.com'>Bank of America</a></p>
<br />
eos
email += html
puts email
# 
# <table>
# <tr><td colspan=3>#{spider.bill[:period]}</td></tr>
# #{str=''; spider.bill[:summary].each { |i| str += "<tr><td>" + i.join("</td><td>") + "</td></tr>" }; str}
# <tr><td colspan=2><strong>Total</strong></td><td>#{spider.bill[:total]}</td></tr>
# </table>
# Dividing the bill by #{num}, each person pays <strong>$#{tot/num}</strong>
# 
# The raw data:
# <pre>
# #{data}
# </pre>
# eos




if SEND_EMAIL
  ##
  # configuration to send emails
  ##
  Mail.defaults do
    delivery_method :smtp, {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => CONFIG['GMAIL_USERNAME'],
      :password             => CONFIG['GMAIL_PASSWORD'],
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
  end
  Mail.deliver do
           to CONFIG['MAIL_TO']
         from CONFIG['GMAIL_USERNAME']
      subject "AT&T bill - #{spider.bill[:period]}"
     add_file :filename => 'bill.html', :content => File.read('bill.html')
     add_file :filename => 'bill.png',  :content => File.read('bill.png')
     add_file :filename => 'bill.json', :content => File.read('bill.json')
    html_part do
      content_type 'text/html; charset=UTF-8'
      body         email
    end
  end
end

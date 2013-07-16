#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'mail'
require 'json'

USE_CACHE = false
DEBUG = false
SEND_EMAIL = true

HTML_FILE = "bill.html"
JSON_FILE = "bill.json"
SCREENSHOT_FILE = "bill.png"

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

##
# Standard class library override
##
class String
  # takes out &nbsp; and utf8 char for negative sign
  def normalize
    return self.gsub(/[[:space:]]/,' ').gsub(/\u00e2\u0088\u0092/, '-').strip
  end
  # remove all the alpha characters and convert into a float
  def strip_to_f
    self.gsub(/[^-0-9\.]/, '').to_f
  end
  # capitalize every word
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
  attr_accessor :bill
  def initialize
    @bill = { :json => {}, :html => nil, :period => nil }
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

  ## 
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

  # parse the bill.html
  def parse
    #get_bill_summary unless @bill[:html]
    bill = open(HTML_FILE) if USE_CACHE
    bill = @bill[:html] unless USE_CACHE
    doc = Nokogiri::HTML(bill)
    @bill[:json] = {}
    # header text with name + phone number
    accounts = doc.xpath("//h3[@class='CTNName']")
    accounts.each do |account|
      name, number, total = account.text.match(/(.*)(\d{3}-\d{3}-\d{4}).*(\$[\d\.]+)/)[1,3].map { |x| x.normalize }
      @bill[:json][number] = { "Total" => total, "Name" => name.titleize }

      # find the main category breakdowns
      categories = account.parent.next.css("h3.categoryLabel")
      categories.each do |category|
        title = category.text.normalize
        category = category.parent.next
        @bill[:json][number][title] = {}

        subcategories = category.css('h4') # TODO code cleanup.. reiteration of categories again
        subcategories.each do |subcategory|
          subtitle = subcategory.text.normalize
          subcategory = subcategory.parent.next
          @bill[:json][number][title][subtitle] = table_to_json(subcategory)
          subcategory.remove
        end

        @bill[:json][number][title].merge! table_to_json(category)
      end
    end

    # get the billing period
    period = doc.at('p:contains("Billing Period")').text
    #@bill[:period].sub!(/Billing Period /, '')
    period = period.match /\d{1,2}\/\d{1,2}\/\d{2,4} - \d{1,2}\/\d{1,2}\/\d{2,4}/
    @bill[:period] = period[0]
    return @bill[:json]
  end


  def get_bill_summary
    if USE_CACHE
      STDERR.puts "Using cache, so faking getting the bill summary.. Fetched!"
    else
      login unless @is_logged_in
      puts "Opening bill details"
      click_link 'Bill Details'

      # bill full summary page
      visit '/pmt/jsp/titan/wireless/billPay-billSummary-printView.jsp?tooltip=no'
      save_page HTML_FILE
      save_screenshot SCREENSHOT_FILE
    end

    @bill[:html] = open(HTML_FILE)
    parse
  end

  def get_bill_totals
    return get_total([0, @bill[:json]])[1]
  end

  def rebalance_bill
    # Let's not worry about the subsections for now
    totals = @bill[:json].rmerge get_bill_totals
    total_familytalk = 0.0
    num_lines = @bill[:json].keys.count

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
        puts "=*=*= %s =*=*=" % line
        puts "Original subtotal: %s" % summary["Total"]
        puts "New subtotal:      %s" % summary["New total"]
        puts "Original total:    %s" % charges["Total"]
        puts "New total:         %s" % charges["New total"]
        puts "=*=*=*=*=*=*=*=*=*=*=*=*"
      end
    end

    @bill[:json] = totals
  end
end


##
# Start of the script
##

spider = Att.new
spider.login
spider.get_bill_summary
spider.rebalance_bill

File.open(JSON_FILE, 'w') { |f| f.write JSON.pretty_generate(spider.bill[:json]) }

header_strings = []
html_strings = []
html = "<h2>Billing Period: %s</h2>" % spider.bill[:period]
spider.bill[:json].each do |line, charges|
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
  html += "</tr></table><br />"
end

email = <<-eos
<p>The information below is retrieved on #{Time.now.strftime "%A %B %-m, %Y, %I:%m %p"} by logging onto AT&T online portal</p>
<p>Attached is the bill summary in full details. Use it to verify the validity of all information here</p>
<p>Transfer money via <a href='https://bankofamerica.com'>Bank of America</a> to Rebecca.
Direct questions about this email to William</p>
<br />
eos
email += html

puts "=*=* Email body =*=*=*=*"
puts email
puts "=*=*=*=*=*=*=*=*=*=*=*=*"


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
     add_file :filename => HTML_FILE,       :content => File.read(HTML_FILE)
     add_file :filename => SCREENSHOT_FILE, :content => File.read(SCREENSHOT_FILE)
     add_file :filename => JSON_FILE,       :content => File.read(JSON_FILE)
    html_part do
      content_type 'text/html; charset=UTF-8'
      body         email
    end
  end
end

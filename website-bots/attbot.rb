#!/usr/bin/env ruby

require 'rubygems'
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require 'nokogiri'
require 'yaml'
require 'mail'
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

# read passwords from a config file
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG

class String
  def normalize
    return self.gsub(/[[:space:]]/,' ').gsub(/\u00e2\u0088\u0092/, '-').strip
  end
end

##
# Grabs the AT&T bill summary
##
class Att
  include Capybara::DSL
  attr_accessor :bill
  def initialize
    @bill = {:period => '', :summary => [], :total => ''}
    @is_logged_in = false
  end

  def login
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

  # find all table rows and convert to json
  def table_to_json(element)
    json = {}
    rows = element.xpath(".//tr")
    rows.each do |row|
      col = row.xpath(".//td").map { |x| x.text.normalize }
      col.reject! { |x| x.empty? }
      json[col[0]] = col[1] if col[0] and col[1]
    end
    return json
  end

  # parse the bill.html
  def parse
    #get_bill_summary unless @bill_html
    doc = Nokogiri::HTML(open(@bill_html))
    #doc = Nokogiri::HTML(open('bill.html'))
    summary = {}
    # header text with name + phone number
    accounts = doc.xpath("//h3[@class='CTNName']")
    accounts.each do |account|
      number = account.text.match(/\d{3}-\d{3}-\d{4}/)[0]
      summary[number] = {}

      # find the main category breakdowns
      categories = account.parent.next.css("h3.categoryLabel")
      categories.each do |category|
        title = category.text.normalize
        category = category.parent.next
        summary[number][title] = {}

        subcategories = category.css('h4')
        subcategories.each do |subcategory|
          subtitle = subcategory.text.normalize
          subcategory = subcategory.parent.next
          summary[number][title][subtitle] = table_to_json(subcategory)
          subcategory.remove
        end

        summary[number][title].merge! table_to_json(category)
      end
    end
    return summary
  end

end

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


spider = Att.new
spider.login
spider.get_bill_summary
data = JSON.pretty_generate spider.parse

File.open('bill.json', 'w') { |f| f.write data }

num = spider.bill[:summary].count
tot = spider.bill[:total].sub(/\$/, '').to_f
email = <<-eos
<p>The information below is retrieved on #{Time.now.strftime "%A %B %-m, %Y, %I:%M %p"} by logging onto AT&T online portal.</p>
<p>Attached is the bill summary in full details. Use it to verify the validity of all information here</p>
<p>Transfer money via <a href='https://bankofamerica.com'>Bank of America</a></p>
<br />

<table>
<tr><td colspan=3>#{spider.bill[:period]}</td></tr>
#{str=''; spider.bill[:summary].each { |i| str += "<tr><td>" + i.join("</td><td>") + "</td></tr>" }; str}
<tr><td colspan=2><strong>Total</strong></td><td>#{spider.bill[:total]}</td></tr>
</table>
Dividing the bill by #{num}, each person pays <strong>$#{tot/num}</strong>

The raw data:
<pre>
#{data}
</pre>
eos

Mail.deliver do
         to CONFIG['MAIL_TO']
       from CONFIG['GMAIL_USERNAME']
    subject "AT&T bill - #{spider.bill[:period]}"
   add_file :filename => 'bill.html', :content => File.read('bill.html')
   add_file :filename => 'bill.png',  :content => File.read('bill.png')
  html_part do
    content_type 'text/html; charset=UTF-8'
    body         email
  end
end


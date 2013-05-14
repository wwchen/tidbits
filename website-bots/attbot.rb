#!/usr/bin/env ruby

require 'rubygems'
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
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

##
# Grabs the AT&T bill summary
##
class Att
  include Capybara::DSL
  attr_accessor :bill
  def initialize
    @bill = {:period => '', :summary => [], :total => ''}
  end

  def get_results
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
spider.get_results

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


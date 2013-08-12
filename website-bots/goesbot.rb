#!/usr/bin/env ruby

require "rubygems"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
#require "headless"
require "nokogiri"
require "yaml"
require "time"
require 'mail'

## Configs
url = "https://goes-app.cbp.dhs.gov/"
config = "config.yml"

CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),config)) unless defined? CONFIG

## Cabybara set up
Capybara.run_server = false
Capybara.app_host = url
Capybara.current_driver = :webkit
#Capybara.headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31" }
Capybara.default_wait_time = 5
if Capybara.current_driver == :webkit
  require 'headless'
  headless = Headless.new
  headless.start
  at_exit do
    headless.destroy
  end
end

## Mail set up
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

class Goes_bot
  attr_accessor :my_date

  include Capybara::DSL
  def get_calendar
    puts "Visiting webpage"
    visit('/')

    puts "Signing in"
    fill_in "user",     :with=>CONFIG['GOES_USERNAME']
    fill_in "password", :with=>CONFIG['GOES_PASSWORD']
    click_button "Sign In"

    #click_link("Enter", exact: true)
    visit "/main/goes/HomePagePreAction.do"

    puts "Manage Interview Appointment"
    click_on "Manage Interview Appointment"

    # find the scheduled appointment time
    label = find(:xpath, '//p/strong[contains(text(), "Interview Date")]').text
    idate  = find(:xpath, '//p/strong[contains(text(), "Interview Date")]/..').text
    idate.sub!(label, '')

    label = find(:xpath, '//p/strong[contains(text(), "Interview Time")]').text
    itime  = find(:xpath, '//p/strong[contains(text(), "Interview Time")]/..').text
    itime.sub!(label, '')
    @my_date = Time.parse(idate + itime)
    puts "My current scheduled interview date is " + @my_date.to_s

    puts "Reschedule Appointment"
    click_on "Reschedule Appointment"

    puts "Select enrollment center"
    save_page 'center.html'
    find('option', :text => /Seattle Urban Enrollment Center/).select_option
    click_on "Next"

    save_page 'earliest.html'
  end

  def parse_calendar
    page = Nokogiri::HTML(open('earliest.html'))
    container = page.xpath("//div[@class='maincontainer']")
    bolded = container.xpath("//b").to_a
    bolded.map! {|a| a.text}
    printf("%s: %s %s - %s\n", *bolded)

    avail      = bolded[1..2].join(' ')
    avail_date = Time.strptime(avail, "%Y-%m-%d %H%M")
    open("earliest.txt", "w+") do |f|
      earliest = [avail_date, @my_date].min
      # We have an early interview date
      if earliest != @my_date
        puts "Sending email"
        send_email(earliest)
        reschedule()
      end
      f.write(earliest)
    end
  end

  def reschedule
  end

  def send_email(msg)
    email = "new date is " + msg.to_s
    Mail.deliver do
             to CONFIG['MAIL_TO_SELF']
           from CONFIG['GMAIL_USERNAME']
        subject "GOES"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body         email
      end
    end
  end
end

spider = Goes_bot.new
spider.get_calendar
spider.parse_calendar

#!/usr/bin/env ruby

require "rubygems"
#require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "faker"
require "yaml"
Capybara.run_server = false
Capybara.app_host = "http://www.bing.com"
Capybara.current_driver = :iphone
Capybara.javascript_driver = :webkit
#Capybara.current_session.driver.headers = { "User-Agent" => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5" }
Capybara.default_wait_time = 5
####Uncomment for and comment out Capybara.current_driver = :webkit for testing
#Capybara.current_driver = :selenium 
Capybara.register_driver :iphone do |app|
  require 'selenium/webdriver'
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['general.useragent.override'] = 'iPhone'
  Capybara::Selenium::Driver.new(app, :profile => profile)
end
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG

module Bing
  class Bing_bot
    include Capybara::DSL
    def get_results
      puts "Visiting bing rewards"
      visit('/rewards/signin')
      sleep 5

      puts "Clicking on Sign in"
      click_on "Sign in with your Microsoft account" 

      puts "Signing in"
      fill_in "login", :with=>CONFIG['BING_USERNAME']
      fill_in "passwd", :with=>CONFIG['BING_PASSWORD']
      sleep 2
      click_button "Sign in"
      sleep 5

      accept_alert
      puts "Visiting bing.com"
      visit('/')
      num_search = Random.new.rand(CONFIG['MIN_SEARCHES']..CONFIG['MAX_SEARCHES'])
      puts "Performing #{num_search} searches"
      num_search.times do |i|
        within "#sb_form" do
          countdown = Random.new.rand(CONFIG['MIN_WAIT_SECS']..CONFIG['MAX_WAIT_SECS'])
          countdown.times do
            STDOUT.write "\rSearch number #{i+1} in #{countdown} seconds"
            sleep 1
            countdown-=1
          end
          query = Faker::Company.catch_phrase()
          puts "\rSearching: #{query}"
          #this could probably be done with a query string but might as well just fill it out while we're here
          fill_in 'sb_form_q', :with=>query
          click_on "sbBtn"
        end
      end
    end
  end
end
spider = Bing::Bing_bot.new
spider.get_results

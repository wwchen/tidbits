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
Capybara.current_driver = :webkit
Capybara.default_wait_time = 5
####Uncomment for and comment out Capybara.current_driver = :webkit for testing
#Capybara.current_driver = :selenium 
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :chrome)
#end
CONFIG = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG

module Bing
    class Bing_bot
        include Capybara::DSL
        def get_results
            puts "Visiting bing.com"
            visit('/')
            sleep 5

            puts "Clicking on Sign in"
            click_on "Sign in" 

            puts "Signing in"
            find(:xpath, "//table[@id='id_dt']/tbody/tr[position() = 2]").click_on('Connect')#click on the second connect link
            fill_in "login", :with=>CONFIG['BING_USERNAME']
            fill_in "passwd", :with=>CONFIG['BING_PASSWORD']
            sleep 2
            find(:xpath, "//input[@id='idSIButton9']").click
            sleep 5

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
                    click_on "sb_form_go"
                end
            end
        end
    end
end
spider = Bing::Bing_bot.new
spider.get_results

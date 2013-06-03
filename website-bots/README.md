#BingBot
BingBot is a bot created to automatically search for gibberish using the Faker gem on MS's bing.com.
It utilizes capybara and webkit to log into bing and execute the searches. 
(bing requires javascript so mechanize was a no go).

Note: in order to set this up as a cron job you must use xvfb
Example: 0 8 * * * DISPLAY=localhost:1.0 xvfb-run /path/to/script/bingbot/bingbot.rb

#!/usr/bin/env ruby
require 'open-uri'

host = 'http://www.tunerplayground.com'
dir = File.join(Dir.home, 'Downloads')

html = open(host + '/models') { |f| f.read }
models = html.scan(/models\/([a-z-]+)"/).map { |i| i[0] }

models.each_index { |i|
  puts "%i) %s" % [ i, models[i]]
}
print "Enter choice: "
choice = gets.chomp

choice = choice.to_i # not checking for wrong inputs yet

html = open("%s/models/%s" % [host, models[choice]]) { |f| f.read }
params = html.scan(/model_thumb\.php\?id=(\d+)&i=([^'"]+)/)

model_dir = File.join(dir, models[choice])
Dir.mkdir model_dir unless Dir.exists? model_dir

puts "Created folder " + model_dir
params.each { |param|
  File.open("%s/%s" % [model_dir, param[1]], 'wb') { |local|
    url = "%s/images/models/%s/%s" % [host, param[0], param[1]]
    open(url, 'rb') { |remote|
      local.write(remote.read)
      puts "Downloaded " + url
    }
  }
}

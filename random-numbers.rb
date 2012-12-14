#!/usr/bin/env ruby
# Returns n number of unique random numbers from 0 to m, inclusive

if ARGV.count < 2
  puts "Usage: ./random-numbers.rb n m"
  puts "\tn the number of unique random numbers"
  puts "\tm the range from 0 to m"
end

n = ARGV[0].to_i
m = ARGV[1].to_i
r = Random.new
ranges = [[0,m]]
lottery = []

if m < n
  puts "m is bigger than n"
  puts (0..m).to_a.to_s
  exit
end

while lottery.count < n
  new_range = Array.new
  #puts ranges.to_s
  ranges.each { |range| 
    next if range[0] > range[1]
    ball = range[0] + r.rand(range[1]-range[0]+1)
    lottery.push(ball)
    break if lottery.count == n
    #puts "ball #{ball}"
    new_range.push([range[0],ball-1]) if ball != 0
    new_range.push([ball+1,range[1]]) if ball != m
  }
  ranges = new_range
end

puts lottery.to_s

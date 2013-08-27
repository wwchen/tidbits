#!/usr/bin/env ruby
## WORK IN PROGRESS
## This is teh template I will use for my question/solution

## Source: Cracking the coding interview, 19.7
QUESTION = "You are given an array of integers (both positive and negative) Find the continuous sequence with the largest sum. Return the sum"
INPUT    = "{2, -8, 3, -2, 4, -10}"
OUTPUT   = "5 (i.e., {3, -2, 4})"

## Usage help
# ARGS is the argument list
ARGS = %w(list)
DEBUG = true
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
  printf("\n----\n%s\n----\n", QUESTION)
  printf("Input:\t%s\n", INPUT)
  printf("Output:\t%s\n", OUTPUT)
  exit
end

def debug(str)
  puts "\e[33mDEBUG:\e[0m " + str if DEBUG
end

def error(str)
  puts "\e[31mERROR:\e[0m " + str if DEBUG
  exit
end

## Solution 1:
# Most obvious and inefficent approach: for all possible lengths of subset, sum up and return the the largest sum
# Space:      O(1)
# Complexity: O(n^2)
class Array
  def sum
    sum = 0
    self.each { |i| sum += i.to_i }
    return sum
  end

  def subset(n)
    sets = []
    return self if n >= self.length
    (0..self.length-n).each { |i| sets.push self[i..i+n] }
    return sets
  end
end

def main(args)
  # convert the string to an array
  string = args[0]
  error "Invalid string" unless string.gsub(/[\{\[,\]\}\s\d-]/, '').empty?
  array = string.match(/[-\d\s,]+/).to_s.split(',').map { |s| s.to_i }
  debug "Parsed array is " + array.to_s

  largest_sum = -999999
  largest_array = nil
  array.each_index do |i|
    array.subset(i).each do |subset|
      sum = subset.sum
      if largest_sum < sum
        largest_sum = sum
        largest_array = subset
      end
    end
  end

  puts "Largest sum is " + largest_sum.to_s
  puts "The corresponding subset is " + largest_array.to_s
end


## Execution
main(ARGV)


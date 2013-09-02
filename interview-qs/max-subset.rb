#!/usr/bin/env ruby
require 'benchmark'

## Source: Cracking the coding interview, 19.7
# Test cases:
# {1,1,1}
# {-1,0,1}
# {1,-1,1,-1,-2,4}
# {9,4,2,-20,23}
# {-56,-23,-1,-4}
# {-34,-39,4459,-923}
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
  puts "\e[33mDEBUG:\e[0m " + str.to_s if DEBUG
end

def error(str)
  puts "\e[31mERROR:\e[0m " + str.to_s if DEBUG
  exit
end

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

def try_parse(string)
  # convert the string to an array
  error "Invalid string" unless string.gsub(/[\{\[,\]\}\s\d-]/, '').empty?
  array = string.match(/[-\d\s,]+/).to_s.split(',').map { |s| s.to_i }
  debug "Parsed array is " + array.to_s
  return array
end

## Solution 1:
# Most obvious and inefficent approach: for all possible lengths of subset, sum up and return the the largest sum
# Space:      O(1)
# Complexity: O(n^2)
def main(args)
  array = try_parse args[0]

  # keep try of the largest sum
  largest_sum = -99999999       # arbitrary. I donno how to find the INT_MIN in ruby
  largest_array = nil
  # go through all possible subsets in all lengths
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

def main2(args)
  # instead of O(n^2), let's try doing O(n) now
  # basic idea is to "trim" right side of the array, then the left
  # find what indicies get the max value from index 0..i, then
  # find what index get the max value from j..i
  # Worst case O(n^2), where all the elements produce the max value
  # Average and best case O(2*n) == O(n)
  array = try_parse args[0]
  sums = []
  rmax_indices = []
  # k
  array.each_index do |i|
    sums.push array[0,i+1].sum
  end
  # find the indices with max value
  max_sum = sums.max
  first_index = 0
  while true
    index = sums[first_index,sums.count].index max_sum
    rmax_indices.push index unless index == nil
    break if index == nil or index == sums.count-1
    first_index = index
  end

  max_subarray = []
  max_sum = -99999999
  rmax_indices.each do |i|
    (0..i).each do |j|
      subarray = array[j,i]
      submaxsum = subarray.sum
      if submaxsum > max_sum
        max_subarray = subarray
        max_sum = submaxsum
      end
    end
  end

  puts "Largest sum is " + max_sum.to_s
  puts "The corresponding subset is " + max_subarray.to_s
end


## Execution
puts "Solution 1:"
puts Benchmark.measure { main(ARGV) }
puts "\n==========\n"
puts "Solution 2:"
puts Benchmark.measure { main2(ARGV) }


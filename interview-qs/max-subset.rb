#!/usr/bin/env ruby
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

def try_parse(string)
  # convert the string to an array
  error "Invalid string" unless string.gsub(/[\{\[,\]\}\s\d-]/, '').empty?
  array = string.match(/[-\d\s,]+/).to_s.split(',').map { |s| s.to_i }
  debug "Parsed array is " + array.to_s
  return array
end

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
  # instead of n^2, let's try doing O(n) now
  array = try_parse args[0]
end


## Execution
main(ARGV)


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
end

def main(args)
  puts args[0]
  puts [1,2,3].sum
end


## Execution
main(ARGV)


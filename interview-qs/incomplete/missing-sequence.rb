#!/usr/bin/env ruby
## source: http://www.careercup.com/question?id=5564407157358592

## Question:
QUESTION = "Given a string of numbers in sequence order. find the missing number. Range is not given."
INPUT    = "9899100101103104105" 
OUTPUT   = "102"

## Usage help
# ARGS is the argument list
ARGS = %w(sequence)
DEBUG = true
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
  printf("\n----\n%s\n----\n", QUESTION)
  printf("Input:\t%s\n", INPUT)
  printf("Output:\t%s\n", OUTPUT)
  exit
end

def debug(str)
  puts str if DEBUG
end

## Solution 1:
# This problem can be broken down to subproblems:
# 1. Figure out where the string should be split
# 2. Find the missing number in the sequence
# Let's assume for now the sequence is not a geometric or arthimetic.
# Let's assume the sequence increases by one every time.
#
# First problem is figuring out where the numbers are separated. First number can be two digits,
# second can be three (i.e. 99,100), or it can be two; however, the number of digits in the second
# number cannot be lower than the first.
#
# A proper number cannot start with a zero. The next number cannot be smaller than the previous one.
# The next number can only increase by a digit when the first number starts with a 9, and second number
# starts with a 1. Three assumptions I can start with.
# Space:      O()
# Complexity: O()
def main(args)
  str = ARGV.first
  debug("Input is " + str)
  str.each_char do |char|
    digit = char.to_i
  end
end


## Execution
main(ARGS)


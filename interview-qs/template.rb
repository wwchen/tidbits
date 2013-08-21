#!/usr/bin/env ruby
## WORK IN PROGRESS
## This is teh template I will use for my question/solution

## Source:
## Question:
QUESTION = "Given a string of numbers in sequence order. find the missing number. Range is not given."
INPUT    = "9899100101103104105" 
OUTPUT   = "102"

## Usage help
# ARGS is the argument list
ARGS = %w(arg1 arg2)
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
# <insert explaination here>
# Space:      O()
# Complexity: O()
def main(args)
end


## Execution
main(ARGV)


#!/usr/bin/env ruby
## Source:
## Question:
QUESTION = "This is the classic PIN guessing game (I don't know what the actual name of it is). A 4-unique-digit number is randomly picked, and you want to guess it in the least amount of times. With each guess, you are hinted how many digits are right (X) and how many are right and in the same location (O)"
INPUT    = "None. Let's say the program generates 1234"
OUTPUT   = "1348\tOXX\n\t6834\tOO\n\t1234\tOOOO"

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


#!/usr/bin/env ruby

## WORK IN PROGRESS
## This is teh template I will use for my question/solution

## Usage help
# ARGS is the argument list
ARGS = %w(arg1 arg2)
DEBUG = true
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
end

def debug(str)
  puts str if DEBUG
end

## Question:
# <insert question here>

## Example:
# INPUT:  
# OUTPUT: 

## Solution 1:
# <insert explaination here>
# Space:      O()
# Complexity: O()
def main(args)
end


## Execution
main(ARGS)


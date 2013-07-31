#!/usr/bin/env ruby

## WORK IN PROGRESS
## This is teh template I will use for my question/solution

## Usage help
# ARGS is the argument list
ARGS = %w(n)
DEBUG = false
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
end

def debug(str)
  puts str if DEBUG
end

## Question:
# Implement an algorithm to print all valid (e.g. properly opened and closed)
# combinations of n-pairs of parentheses.

## Example:
# INPUT:  3
# OUTPUT: ()()(), ()(()), (()()), ((()))

## Solution 1:
# Using recursion, I loop through all the possible varitions of open and close parens.
# However, not all are valid combinations. Valid combos cannot have more close parens than open ones.
# Once we deplete our open parens, the rest must all be close parens.
# Space:      O(n^2) - each recursion stores a string, though invalid strings get discarded.
#             n from 1 - 10, number of valid combinations are: 1,2,5,14,42,132,429,1430,4862,16796
# Complexity: O(n^2) - each recursion makes two other calls to it
def main(args)
  n = args[0].to_i
  main_helper(n, n, '')
end

def main_helper(open, close, output)
  debug [open, close, output].join(' ')
  if open <= 0
    puts output + ')' * close if close > 0
    return
  end
  if close < open
    return
  end
  main_helper(open-1, close, output+'(')
  main_helper(open, close-1, output+')')
end

## Execution
main(ARGV)


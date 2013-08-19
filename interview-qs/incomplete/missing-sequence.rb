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
  puts "\e[33mDEBUG:\e[0m " + str if DEBUG
end

def error(str)
  puts "\e[31mERROR:\e[0m " + str if DEBUG
  exit
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
  string = ARGV.first
  debug("Input is " + string)
  numbers = []
  numbers.push string[0]            # first digit is special b/c that's the only starting point 
  first_digit = numbers[0].to_i     # assumption we can make
  error("Input cannot start with a 0") if first_digit == 0

  str_ind = 0
  num_ind = 0
  while index < string.length
    # if the next digit is the following digit of the first digit (i.e 5->6), and the prev digit ends with
    # 8 or 9, it can be the next number in the sequence. Special case of this is 9->1, when 99 goes to 100.
    # 
    # we have to be careful how we compare digits. 1 is bigger than 9 in some cases
    number = digit_one = string[str_ind]
    boundary = false
    while not boundary
      str_ind += 1
      digit_nxt = string[str_ind]
      # if the next digit is smaller than the first digit in the number, it can't be the next number in sequence
      if digit_nxt < digit_one
        number += digit_nxt
        continue
      end

      # if the next digit is equal to the first digit, it can be the next number in the sequence
      if digit_nxt == digit_one
      end

      if digit_nxt == digit_one + 1 or (digit_nxt == 1 and digit_one == 9 and number[-1] == 8 or 9)
      end

    end
    numbers[num_ind] = number
    str_ind += 1

    while string[str_ind].to_i < first_digit
      numbers[num_ind] += string[str_ind]
      str_ind += 1
    end


    index += 1 # for now
    puts first_digit
  end
end


## Execution
main(ARGS)


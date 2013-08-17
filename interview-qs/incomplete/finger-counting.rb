#!/usr/bin/env ruby
## Source:   http://www.careercup.com/question?id=4664438636412928
## Question: A young girl counted in the following way on the fingers of her left hand.
# She started calling the thumb 1, the index finger 2, the middle finger 3, the ring finger 4,
# the little finger 5, then reversed direction calling the ring finger 6, the middle finger 7,
# the index finger 8, the thumb 9 then back to the index finger for 10, the middle finger for 11,
# and so on. She counted up to n (to be input by the user). She ended on her which finger?

QUESTION = <<EOS
A young girl counted in the following way on the fingers of her left hand.
She started calling the thumb 1, the index finger 2, the middle finger 3, the ring finger 4,
the little finger 5, then reversed direction calling the ring finger 6, the middle finger 7,
the index finger 8, the thumb 9 then back to the index finger for 10, the middle finger for 11,
and so on. She counted up to n (to be input by the user). She ended on her which finger?
EOS
INPUT    = "8"
OUTPUT   = "index"

## Usage help
# ARGS is the argument list
ARGS = %w(n-fingers)
DEBUG = true
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
  printf("\n----\n%s\n----\n", QUESTION)
  printf("Input:\t%s\n", INPUT)
  printf("Output:\t%s\n", OUTPUT)
  exit
end

def debug(str)
  puts "\e[31mDEBUG:\e[0m " + str if DEBUG
end

def error(str)
  puts "\e[31mERROR:\e[0m " + str if DEBUG
  exit
end

## Solution 1:
# thumb   1,10,11,20,21
# index   2,9,12,19,22
# middle  3,8,13,18,23
# ring    4,7,14,17,24
# little  5,6,15,16,25
# As you can see, there is no apparent pattern here. Scratch that. I found one.
# Multiple of 5's alternate between thumb and little finger.
# Space:      O()
# Complexity: O()
def eputs(str)
  puts str
  exit
end

def main(args)
  n = ARGV[0].to_i
  ans = %w(thumb index middle ring little)
  modten = n % 10
  modfive = n % 5

  eputs ans[0] if modten == 0
  eputs ans[4] if modfive == 0

  if modfive < modten
    eputs ans[-modfive]
  else
    eputs ans[modfive-1]
  end
end


## Execution
main(ARGS)


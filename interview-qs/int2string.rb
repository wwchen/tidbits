#!/usr/bin/env ruby
## Source:   Cracking the Coding Interview book, p. 164
QUESTION = "Given any integer, print an English phrase that describes the integer"
INPUT    = "1234"
OUTPUT   = "One thoussand, two hundred thirty four"

## Usage help
# ARGS is the argument list
ARGS = %w(number)
DEBUG = true
if ARGV.count != ARGS.count
  printf("Usage: %s %s\n", __FILE__, ARGS.join(' '))
  printf("\n----\n%s\n----\n", QUESTION)
  printf("Input:\t%s\n", INPUT)
  printf("Output:\t%s\n", OUTPUT)
  exit
end

def debug(obj)
  puts "\e[33mDEBUG:\e[0m " + obj.to_s if DEBUG
end

def error(obj)
  puts "\e[31mERROR:\e[0m " + obj.to_s if DEBUG
  exit
end

def prints(obj)
  print obj.to_s + ' '
end

## Solution 1:
# <insert explaination here>
# Space:      O()
# Complexity: O()
def main(args)
  ones = [''] + %w{one two three four five six seven eight nine}
  teens = %w{ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen}
  tens = [''] + %w{ten twenty thirty fourty fifty sixty seventy eighty ninety}
  hundreds = [''] + %w{hundred thousand million billion trillion}

  string = args[0]
  debug "Input is " + string

  # splitting the number in digits of threes
  string = string.gsub(/\D/, '')  # strip out any non-digit characters
  strings = [string[0,string.length % 3]]
  strings += string[(string.length % 3).. string.length].scan(/.../)

  (0..strings.length).each do |index|
    triple = strings[index].to_i.to_s   # truncate the leading zeros
    if triple.length == 3
      prints ones[triple[0].to_i]
      prints hundreds[1]
      triple = triple[1..2]
    end
    if triple.length == 2
      prints 'and' if index != 0
      if triple[0] == '1'
        prints teens[triple[1].to_i]
      else
        prints tens[triple[0].to_i]
        prints ones[triple[1].to_i]
      end
      triple = triple[1]
      prints hundreds[strings.length - index] unless index == strings.length-1
    elsif triple.length == 1 and triple[0] != '0'
      prints ones[triple[0].to_i]
      prints hundreds[strings.length - index] unless index == strings.length-1
    end

  end
  prints "\n"
end


## Execution
main(ARGV)


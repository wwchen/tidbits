#!/usr/bin/env ruby
## Source:   I donno
## Question: 
QUESTION = "Output all the permuations of a string"
INPUT    = "9899100101103104105" 
OUTPUT   = "102"

## Usage help
# ARGS is the argument list
ARGS = %w(string)
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
def perm(str)
  if(str.length <= 1)
    return [str]
  end
  arr = []
  str.split(//).each { |char|
    perm(str.sub(char,'')).each { |suffix|
      arr.push(char + suffix)
    }
  }
  return arr
end

def main(args)
  permutations = perm(args[0].gsub(/\W/,''))
  puts permutations.to_s
end


## Execution
main(ARGV)


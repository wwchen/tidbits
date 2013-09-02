#!/usr/bin/env ruby
## Source:
## Question:
QUESTION = "This is the classic PIN guessing game (I don't know what the actual name of it is). A 4-unique-digit number is randomly picked, and you want to guess it in the least amount of times. With each guess, you are hinted how many digits are right (X) and how many are right and in the same location (O)"
INPUT    = "None. Let's say the program generates 1234"
OUTPUT   = "1348\tOXX\n\t6834\tOO\n\t1234\tOOOO"

## Usage help
# ARGS is the argument list
ARGS = %w()
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

def generate_pin(character_set, length)
  pin = ""
  r = Random.new
  length.times do |i|
    index = r.rand(character_set.length)
    char = character_set[index]
    pin += char
    character_set.delete! char
  end
  return pin
end

def check_pin(pin, guess)
  result = ""
  pin.split('').each_with_index do |char, index|
    if guess.include? char
      if guess.index(char) == index
        result = 'O' + result
      else
        result = result + 'X'
      end
    end
  end
  return result + '-' * (pin.length - result.length)
end

## Solution 1:
# <insert explaination here>
# Space:      O()
# Complexity: O()
def main(args)
  printf("\n----\n%s\n----\n%s\n%s\n----\n", QUESTION, "X for digits that are right", "O for digits that are right and in the same location")
  charset = "1234567890"
  length = 4
  pin = generate_pin(charset, length)
  debug "Pin is " + pin
  puts "Enter your guesses: "
  result = ""
  count = 1
  while result != "O" * length
    guess = STDIN.gets
    result = check_pin(pin, guess)
    puts "\t\t" + result
    count += 1
  end
  puts "Congratulations, you got the pin in %s tries!" % count
end


## Execution
main(ARGV)


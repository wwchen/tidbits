#!/usr/bin/env ruby
# Computes the diff between two strings
# http://en.wikipedia.org/wiki/Levenshtein_distance

DEBUG = false
RECURSIVE = false

# recursive. performance is truly terrible
def levenshtein_distance_recursive(str1, len1, str2, len2)
  return len2 if len1 == 0
  return len1 if len2 == 0

  cost = 1
  cost = 0 if str1[len1-1] == str2[len2-1]

  return [levenshtein_distance_recursive(str1, len1-1, str2, len2)   + 1,
          levenshtein_distance_recursive(str1, len1  , str2, len2-1) + 1,
          levenshtein_distance_recursive(str1, len1-1, str2, len2-1) + cost].min
end

# dynamic programming, improved
# improved in the sense that we are not keeping tracking of all row.
# just only the previous and current row
def levenshtein_distance(str1, str2)
  # degenerate cases
  return 0 if str1 == str2
  return str1.length if str2.length == 0
  return str2.length if str1.length == 0

  # arrays to hold the previous and current row
  # changing an empty st1 will take i edits to get to str2
  prev = Array.new(str2.length + 1) { |i| i }
  curr = Array.new(str2.length + 1)

  0.upto(str1.length - 1) { |i|
    # calculate curr row distance from prev row
    # edit distance is delete (i+1) chars from str1 to match empty str2
    curr[0] = i + 1

    # formula
    0.upto(str2.length - 1) { |j|
      cost = 1
      cost = 0 if str1[i] == str2[j]
      curr[j + 1] = [curr[j] + 1,
                     prev[j + 1] + 1,
                     prev[j] + cost].min
    }

    # debug
    if DEBUG
      puts "=========="
      puts "Iteration #{i}"
      puts "prev: #{prev}"
      puts "curr: #{curr}"
      puts "=========="
    end

    prev = Array.new curr
  }
  return curr[-1]
end

def main
  str1 = ARGV[0]
  str2 = ARGV[1]
  puts "Comparing '#{str1}' and '#{str2}'"
  if RECURSIVE
    puts levenshtein_distance_recursive(str1, str1.length, str2, str2.length)
  else
    puts levenshtein_distance(str1, str2)
  end
end

main


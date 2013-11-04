def isPalindrome (str)
    s = str.downcase.gsub(/[^a-z]/, '')
    # try 1: ruby specific
    return s == s.reverse
    
    # try 2: all other language
    mid = str.length/2 # rounds down
    (0..mid).each { |i|
        return false if str[i] != str[str.length - 1 - i]
    }
    return true
end

def containsPalindrome (str)
    # assuming this function is only looking for palindrome
    # in English, i.e. alpha characters.
    # normalize the string
    str = str.downcase.gsub(/[^a-z]/, '')
    
    # try 1: check all substring
    (0..str.length-1).each { |i|
        (i+1..str.length-1).each { |j|
            return true if isPalindrome(str[i..j])
        }
    }
    return false
    
    # try 2: check substrings that start and end with the same letter
    (0..str.length-1).each { |i|
        j = str.index(str[i], i)
        # go through all the substrings that ends with the character str[i]
        while (j) do
            return true if isPalindrome(str[i..j])
            j = str.index(str[i], j)
        end
    }
    return false
end

# test cases
containsPalindrome "Aa"
containsPalindrome "AA.a"
containsPalindrome ""
containsPalindrome "Nick loves driving a racecar."
containsPalindrome ".."
containsPalindrome "我我"
containsPalindrome " "
containsPalindrome "hello"
containsPalindrome "<some really long string that can potentially overflow buffer>"
containsPalindrome "<sql injection>"    # important if string is from user-input

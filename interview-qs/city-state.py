#!/usr/bin/env python
# Author: William Chen, Mar 19, 2014

#  Say you have a string that stores the city and state separated by hyphens:
#  
#  "Portland-Oregon"
#  "San-Francisco-California"
#  "New-York-New-York"
#  
#  Write a method that will take this string and return the City and State formatted like this: "City, State"
#  
#  You have access to two methods: 
#   - bool ValidateCity(string city) 
#   - bool ValidateState(string state)
#  
#  Note some cities have hyphens in them "Minneapolis-Saint Paul" and "Winston-Salem".  Your code must handle these scenarios.
#  
#  example input/output:
#  
#  "Portland-Oregon" => "Portland, Oregon"
#  "San-Francisco-California" => "San Francisco, California"
#  "New-York-New-York" => "New York, New York"

# Assumptions:
# Since it is not given that we are only talking about US cities and US states, we cannot make the assumption here that the
# state name can only be a max of two words, or that it has no hypens in the state name. Therefore, the best approach here
# is to run every hyphenated permutations with the supplied methods, and check until we get a result that satisfies the condition
# Other assumptions made are:
# - The input has a valid answer, and is a string
# - Extra hyphens are discarded, i.e. "Portland---Oregon" is same thing as "Portland-Oregon"

# workaround implementation of an enum
class LocationType(object):
    City = 1
    State = 2

# approach: recursively add a hyphen in between every word, until we get a valid city/state name
def getLocationName(loctype, words, index):
    if index+1 >= len(words):
        return "".join(words)
    # optimization: more likely there's no hyphens, so add hyphens later
    for addHyphen in [False, True]:
        wordlist = list(words)
        wordlist[index] += "-" if addHyphen else " "
        name = getLocationName(loctype, wordlist, index+1)
        if validateName(loctype, name):
            return name

# kickoff the recursive check
def normalizeCityState(string):
    words = string.split('-')
    if len(words) < 2:
        return "Not possible"
    # optimization: reversed because it's more likely state has a shorter word count
    for i in reversed(range(0, len(words))): # range is [min, max)
        cityName  = getLocationName(LocationType.City, words[:i], 0)
        stateName = getLocationName(LocationType.State, words[i:], 0)
        if cityName and stateName:
            return "%s, %s" % (cityName, stateName)
    return "Not possible"

# check if the supplied string is a valid city or state name
def validateName(loctype, name):
    if loctype == LocationType.City  and ValidateCity(name) or \
       loctype == LocationType.State and ValidateState(name):
        return True
    return False

# supplied method
def ValidateCity(name):
    return name in ["San Francisco", "New York", "Portland", "Minneapolis-Saint Paul", "Winston-Salem"]

# supplied method
def ValidateState(name):
    return name in ["Oregon", "California", "New York", "Minnesota", "North Carolina"]

# entrypoint to the program
def main():
    sample = ["Portland-Oregon", "San-Francisco-California", "New-York-New-York", "Minneapolis-Saint-Paul-Minnesota", "Winston-Salem-North-Carolina"]
    for string in sample:
        print normalizeCityState(string)

if __name__ == "__main__":
    main()

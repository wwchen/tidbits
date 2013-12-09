/*
  * Problem Statement
  *     
  * You are developing a new software calculator. Some people use the calculator to check the sums of several numbers, but they sometimes get unexpected results because they forget to press the 'plus' button. You have almost solved this problem, but a small method is still required.
  * You will be given a string conglutination and an int expectation. Your method should split conglutination into two numbers A and B so that A + B = expectation. Return the result as a String in the form "A+B" (quotes for clarity only). A and B must contain at least one digit each. Leading zeros are allowed and they must be preserved in the result. If there are several possible splits, choose the one with the smallest value of A. Return an empty string if there are no possible splits.
  * Definition
  *     
  * Class:
  * Conglutination
  * Method:
  * split
  * Parameters:
  * string, int
  * Returns:
  * string
  * Method signature:
  * string split(string conglutination, int expectation)
  * (be sure your method is public)
  *     
  * 
  * Constraints
  * -
  * conglutination will contain between 2 and 20 characters, inclusive.
  * -
  * conglutination will contain only digits ('0'-'9').
  * -
  * The first character of conglutination will not be zero.
  * -
  * expectation will be between 1 and 1000000000, inclusive.
  * Examples
  * 0)
  * 
  *     
  * "22"
  * 4
  * Returns: "2+2"
  * 
  * 1)
  * 
  *     
  * "536"
  * 41
  * Returns: "5+36"
  * 
  * 2)
  * 
  *     
  * "123456000789"
  * 1235349
  * Returns: "1234560+00789"
  * Be careful with leading zeros.
  * 3)
  * 
  *     
  * "123456789"
  * 4245
  * Returns: ""
  * 
  * 4)
  * 
  *     
  * "112"
  * 13
  * Returns: "1+12"
  * The value of A should be as small as possible.
  * This problem statement is the exclusive and proprietary property of TopCoder, Inc. Any unauthorized use or reproduction of this information without the prior written consent of TopCoder, Inc. is strictly prohibited. (c)2003, TopCoder, Inc. All rights reserved.
*/

#include <string>
using namespace std;

class Conglutination {
  public:
  string split(string conglutination, int expectation) {
    int str_length = conglutination.length();
    for(int i = 1; i < str_length; i++) {
      string one = conglutination.substr(0, i);
      string two = conglutination.substr(i, string::npos);
      if (atoi(one.c_str()) + atoi(one.c_str()) == expectation) {
        return one + "+" + two;
      }
    }

    return "";
  }
};

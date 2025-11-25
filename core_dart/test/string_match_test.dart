import "package:core_dart/src/extensions/string_match.dart";
import "package:test/test.dart";

void main() {
  test("Basic StringMatch.match tests", () {
    testMatch("g*ks", "geeks", true); // Yes
    testMatch("ge?ks*", "geeksforgeeks", true); // Yes
    testMatch("g*k", "gee", false); // No because 'k' is not in second
    testMatch("*pqrs", "pqrst", false); // No because 't' is not in first
    testMatch("abc*bcd", "abcdhghgbcd", true); // Yes
    testMatch("abc*c?d", "abcd", false); // No because second must have 2 instances of 'c'
    testMatch("*c*d", "abcd", true); // Yes
    testMatch("*?c*d", "abcd", true); // Yes
    testMatch("geeks**", "geeks", true); // Yes
  });
}

void testMatch(String first, String second, bool expectedResult) {
  expect(StringMatch.match(first, second), expectedResult);
}

// eof

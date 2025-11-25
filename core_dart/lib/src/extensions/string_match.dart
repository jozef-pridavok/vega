extension StringMatch on String {
  bool isMatch(String pattern) {
    return match(this, pattern);
  }

  static bool match(String first, String second) {
    // If we reach at the end of both strings,
    // we are done
    if (first.isEmpty && second.isEmpty) return true;

    // Make sure to eliminate consecutive '*'
    if (first.length > 1 && first[0] == "*") {
      int i = 0;
      while (i + 1 < first.length && first[i + 1] == "*") i++;
      first = first.substring(i);
    }

    // Make sure that the characters after '*'
    // are present in second string.
    // This function assumes that the first
    // string will not contain two consecutive '*'
    if (first.length > 1 && first[0] == "*" && second.isEmpty) return false;

    // If the first string contains '?',
    // or current characters of both strings match
    if ((first.length > 1 && first[0] == "?") || (first.isNotEmpty && second.isNotEmpty && first[0] == second[0]))
      return match(first.substring(1), second.substring(1));

    // If there is *, then there are two possibilities
    // a) We consider current character of second string
    // b) We ignore current character of second string.
    if (first.isNotEmpty && first[0] == "*")
      return match(first.substring(1), second) || match(first, second.substring(1));
    return false;
  }
}

// eof

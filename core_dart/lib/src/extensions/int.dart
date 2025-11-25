extension IntExtensions on int {
  /// Returns a string representation of this integer with the limited maximum number.
  /// For example, 123.limitedNumber(99) returns "99+".
  String asLimitedNumber({int maxNumber = 99}) {
    if (this <= maxNumber) return toString();
    return "$maxNumber+";
  }
}

// eof

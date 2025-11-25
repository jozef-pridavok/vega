import "dart:math";

import "package:intl/intl.dart";

class ProgramDigits {
  final int digits;

  ProgramDigits._(this.digits);

  static final Map<int, ProgramDigits> _digits = {};

  factory ProgramDigits(int digits) {
    if (_digits.containsKey(digits)) return _digits[digits]!;
    final programDigits = ProgramDigits._(digits);
    _digits[digits] = programDigits;
    return programDigits;
  }

  /// Convert a value from the fractional unit to the integer base.
  ///
  /// For example, `expand(150)` returns `1.5`,
  double expand(int value) => value / pow(10, digits);

  /// Convert a value from the integer basic the fractional unit.
  ///
  /// For example, `collapse(1.5)` returns `150`, representing 150 points.
  int collapse(num value) => (value * pow(10, digits)).floor();
  static final Map<String, NumberFormat> _valueFormat = {};

  NumberFormat _getValueFormat(String? locale) {
    final key = "$digits-$locale";
    if (_valueFormat.containsKey(key)) return _valueFormat[key]!;
    final pattern = digits == 0 ? "#" : "#.${"#" * digits}";
    final format = NumberFormat(pattern, locale);
    _valueFormat[key] = format;
    return format;
  }

  String format(int points, [String? locale]) {
    final fractional = expand(points);
    return _getValueFormat(locale).format(fractional);
  }

  int? parse(String? value, [String? locale]) {
    if (value == null) return null;
    final format = _getValueFormat(locale);
    try {
      return collapse(format.parse(value));
    } catch (e) {
      return null;
    }
  }
}

// eof
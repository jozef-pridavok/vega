import "dart:math";

import "package:intl/intl.dart";

class FixedPoint {
  final int fraction;
  final int digits;

  FixedPoint(this.fraction, this.digits);

  FixedPoint.digits(int digits) : this(0, digits);
  FixedPoint.zero() : this(0, 0);

  /// Convert a value from the fractional unit to the basic unit
  ///
  /// For example `expand(150)` returns `1.5`
  double expand(int value) => value / pow(10, digits);

  /// Convert a value from the basic unit to the fractional unit
  ///
  /// For example, `collapse(1.5)` returns `150`
  int collapse(num value) => (value * pow(10, digits)).floor();

  static final Map<String, NumberFormat> _valueFormat = {};

  NumberFormat _getValueFormat(String? locale) {
    final key = "$locale";
    return _valueFormat.putIfAbsent(key, () {
      final pattern = digits == 0 ? "#" : "0.${"0" * digits}";
      return NumberFormat(pattern, locale);
    });
  }

  String format(int fraction, [String? locale]) {
    final value = expand(fraction);
    if (value == value.roundToDouble()) return value.toInt().toString();
    return formatRaw(value);
  }

  String formatRaw(num number, [String? locale]) {
    return _getValueFormat(locale).format(number);
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

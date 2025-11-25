import "dart:math";

import "package:intl/intl.dart";

class Quantity {
  final int value;
  final int precision;

  static final Map<String, NumberFormat> _valueFormat = {};

  Quantity(this.value, {this.precision = 0});

  Quantity copyWith({int? value, int? precision}) {
    return Quantity(value ?? this.value, precision: precision ?? this.precision);
  }

  _expand(int value) => value / pow(10, precision);

  NumberFormat _getValueFormat(String? locale) {
    final key = locale ?? "en";
    if (_valueFormat.containsKey(key)) return _valueFormat[key]!;
    final pattern = precision == 0 ? "#" : "#.${"#" * precision}";
    final format = NumberFormat(pattern, locale);
    _valueFormat[key] = format;
    return format;
  }

  String format([String? locale]) {
    final price = _expand(value);
    return _getValueFormat(locale).format(price);
  }
}

// eof

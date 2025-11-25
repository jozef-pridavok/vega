import "package:core_dart/core_dart.dart";

enum PriceKeys { amount, currency }

class Price {
  final int fraction;
  final Currency currency;

  Price(this.fraction, this.currency);

  Price.zero(Currency currency) : this(0, currency);

  static const _fraction = "fraction";
  static const _currency = "currency";

  Price copyWith({int? fraction, Currency? currency}) {
    return Price(fraction ?? this.fraction, currency ?? this.currency);
  }

  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(map[_fraction], CurrencyCode.fromCode(map[_currency]));
  }

  static Price? tryFromMap(Map<String, dynamic> map) {
    if (map.containsKey(_fraction) && map.containsKey(_currency)) {
      return Price(map[_fraction], CurrencyCode.fromCode(map[_currency]));
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      _fraction: fraction,
      _currency: currency.code,
    };
  }

  String format([String? locale]) => currency.format(fraction, locale);

  String formatSymbol([String? locale]) => currency.formatSymbol(fraction, locale);

  String formatCode([String? locale]) => currency.formatCode(fraction, locale);

  int? parse(String value, [String? locale]) => currency.parse(value, locale);

  int? parseSymbol(String value, [String? locale]) => currency.parseSymbol(value, locale);

  int? parseCode(String value, [String? locale]) => currency.parseCode(value, locale);
}

// eof

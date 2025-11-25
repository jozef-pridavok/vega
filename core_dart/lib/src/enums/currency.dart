import "dart:math";

import "package:collection/collection.dart";
import "package:intl/intl.dart";

enum Currency {
  btc,
  eur,
  usd,
  pyg,
  ars,
  uyu,
}

const defaultCurrency = Currency.usd;

// https://github.com/onepub-dev/money.dart/blob/master/lib/src/common_currencies.dart
//

// https://en.wikipedia.org/wiki/ISO_4217
extension CurrencyCode on Currency {
  static final _codeMap = {
    Currency.btc: "BTC",
    Currency.eur: "EUR",
    Currency.usd: "USD",
    Currency.pyg: "PYG",
    Currency.ars: "ARS",
    Currency.uyu: "UYU",
  };

  String get code => _codeMap[this]!;

  static Currency fromCode(String? code, {Currency def = Currency.usd}) =>
      Currency.values.firstWhere((r) => r.code == code, orElse: () => def);

  static Currency? fromCodeOrNull(String? code) => Currency.values.firstWhereOrNull((r) => r.code == code);
}

// https://en.wikipedia.org/wiki/Template:List_of_currency_symbols
extension CurrencySymbol on Currency {
  static const _symbols = {
    Currency.btc: "₿",
    Currency.eur: "€",
    Currency.usd: "\$",
    Currency.pyg: "₲",
    Currency.ars: "\$",
    Currency.uyu: "\$",
  };

  String get symbol => _symbols[this]!;
}

// https://en.wikipedia.org/wiki/ISO_4217
// https://www.linkedin.com/pulse/cryptocurrency-base-units-tara-annison?trk=related_artice_Cryptocurrency%20Base%20Units_article-card_title
extension CurrencyDigits on Currency {
  static const _digits = {
    Currency.btc: 8,
    Currency.eur: 2,
    Currency.usd: 2,
    Currency.pyg: 0,
    Currency.ars: 2,
    Currency.uyu: 2,
  };

  int get digits => _digits[this]!;
}

extension CurrencyFormat on Currency {
  static final Map<String, NumberFormat> _symbolFormat = {};
  static final Map<String, NumberFormat> _codeFormat = {};
  static final Map<String, NumberFormat> _valueFormat = {};

  NumberFormat _getSymbolFormat(String? locale) {
    final key = "$code-$locale";
    if (_symbolFormat.containsKey(locale)) return _symbolFormat[key]!;
    final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: digits);
    _symbolFormat[key] = format;
    return format;
  }

  NumberFormat _getCodeFormat(String? locale) {
    final key = "$code-$locale";
    if (_codeFormat.containsKey(key)) return _codeFormat[key]!;
    final format = NumberFormat.currency(locale: locale, symbol: code, decimalDigits: digits);
    _codeFormat[key] = format;
    return format;
  }

  NumberFormat _getValueFormat(String? locale) {
    final key = "$code-$locale";
    if (_valueFormat.containsKey(key)) return _valueFormat[key]!;
    final pattern = digits == 0 ? "#" : "#.${"#" * digits}";
    final format = NumberFormat(pattern, locale);
    _valueFormat[key] = format;
    return format;
  }

  String formatSymbol(int fraction, [String? locale]) {
    final price = expand(fraction);
    return _getSymbolFormat(locale).format(price);
  }

  String formatCode(int fraction, [String? locale]) {
    final price = expand(fraction);
    return _getCodeFormat(locale).format(price);
  }

  String format(int fraction, [String? locale]) {
    final price = expand(fraction);
    return _getValueFormat(locale).format(price);
  }

  int? parseSymbol(String? value, [String? locale]) {
    if (value == null) return null;
    final format = _getSymbolFormat(locale);
    try {
      return collapse(format.parse(value));
    } catch (e) {
      return null;
    }
  }

  int? parseCode(String? value, [String? locale]) {
    if (value == null) return null;
    final format = _getCodeFormat(locale);
    try {
      return collapse(format.parse(value));
    } catch (e) {
      return null;
    }
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

extension CurrencyExpand on Currency {
  // https://en.wikipedia.org/wiki/List_of_circulating_currencies

  /// Convert a value from the fractional unit to the basic unit for this currency.
  ///
  /// For example, for USD, `expand(150)` returns `1.5`, representing $1.50.
  double expand(int value) => value / pow(10, digits);

  /// Convert a value from the basic unit to the fractional unit for this currency.
  ///
  /// For example, for USD, `collapse(1.5)` returns `150`, representing 150 cents.
  int collapse(num value) => (value * pow(10, digits)).floor();
}

// eof

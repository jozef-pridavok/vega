import "package:intl/intl.dart";

String formatBasisPoint(String locale, int bp, {int? decimalDigits}) {
  return NumberFormat.decimalPercentPattern(locale: locale, decimalDigits: decimalDigits).format(bp / 10000);
}

// eof

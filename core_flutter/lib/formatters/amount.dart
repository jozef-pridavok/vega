import "dart:math" as math;

import "package:core_dart/core_dart.dart";
import "package:core_flutter/extensions/string.dart";

// TODO: move translations to the app and also move this function

String? formatAmount(String locale, Plural? plural, num amount, {int digits = 0}) {
  if (digits > 0) amount = amount.toDouble() / math.pow(10, digits);
  return StringTranslation.formattedAmount(locale, plural, amount, digits: digits != 0 ? digits : null);
}

// eof

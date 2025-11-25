import "package:core_dart/core_data_models.dart";
import "package:intl/intl.dart";

import "../localization/public.dart" as ez;

extension StringTranslation on String {
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) =>
      ez.tr(this, args: args, namedArgs: namedArgs, gender: gender);

  String plural(
    num value, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) =>
      ez.plural(this, value, args: args, namedArgs: namedArgs, name: name, format: format);

  static String formattedAmount(String locale, Plural? plural, num amount, {int? digits}) {
    final defaultResult = "$amount";
    if (plural == null) return defaultResult;
    final selected = Intl.plural(
      amount,
      zero: plural.zero,
      one: plural.one,
      two: plural.two,
      few: plural.few,
      many: plural.many,
      other: plural.other,
      //precision: digits,
      locale: locale,
    );
    //if (amount is int || amount == amount.roundToDouble()) return selected.tr(args: [(amount.toInt()).toString()]);
    String value = amount.toString();
    if ((digits ?? 0) > 0 && amount is double) {
      final fixedPoint = FixedPoint.digits(digits!);
      value = fixedPoint.formatRaw(amount, locale);
    }
    return selected.tr(args: [value]);
  }
}

// eof

import "dart:convert";
import "dart:io";
import "dart:math" as math;

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:intl/intl.dart";
import "package:intl/locale.dart";

import "api_shelf2.dart";

extension MobileApiTranslator on MobileApi {
  Map<String, dynamic> _loadLang(String language) {
    try {
      final filePath = joinPath([config.localPath, "langs", "$language.json"]);
      final File file = File(filePath);
      final String content = file.readAsStringSync();
      return jsonDecode(content);
    } catch (ex) {
      log.error("Failed to load language file. $ex");
      //rethrow;
    }
    return {};
  }

  Translator loadTranslator() {
    return Translator.load(<Locale, Map<String, dynamic>>{
      Locale.fromSubtags(languageCode: "sk"): _loadLang("sk"),
      Locale.fromSubtags(languageCode: "en"): _loadLang("en"),
      Locale.fromSubtags(languageCode: "es"): _loadLang("es"),
    });
  }

  String? formatAmountWithTranslator(Translator translator, String locale, Plural? plural, num amount, {int? digits}) {
    if (digits != null && digits > 0) amount = amount.toDouble() / math.pow(10, digits);
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
      locale: locale,
    );
    //if (amount is int || amount == amount.roundToDouble())
    //  return _translator.tr(locale, selected, args: [(amount.toInt()).toString()]);
    String value = amount.toString();
    if ((digits ?? 0) > 0 && amount is double) {
      final fixedPoint = FixedPoint.digits(digits!);
      value = fixedPoint.formatRaw(amount, locale);
    }
    return translator.tr(locale, selected, args: [value]);
  }
}

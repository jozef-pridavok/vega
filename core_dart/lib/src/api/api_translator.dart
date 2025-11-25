import "package:intl/intl.dart";
import "package:intl/locale.dart";

import "../../core_api_server2.dart";
import "../../core_localization.dart";

class Translator {
  final RegExp _replaceArgRegex = RegExp("{}");
  final RegExp _linkKeyMatcher = RegExp(r"(?:@(?:\.[a-z]+)?:(?:[\w\-_|.]+|\([\w\-_|.]+\)))");
  final RegExp _linkKeyPrefixMatcher = RegExp(r"^@(?:\.([a-z]+))?:");
  final RegExp _bracketsMatcher = RegExp("[()]");
  final _modifiers = <String, String Function(String?)>{
    "upper": (String? val) => val!.toUpperCase(),
    "lower": (String? val) => val!.toLowerCase(),
    "capitalize": (String? val) => "${val![0].toUpperCase()}${val.substring(1)}"
  };
  late final ApiServer2 api;

  static Translator? _instance;
  static late Map<String, Map<String, dynamic>> _translations;

  factory Translator() => _instance!;

  Translator._(Map<Locale, Map<String, dynamic>> translations) {
    _instance = this;
    _translations = translations.map((key, value) => MapEntry(key.languageCode, value));
  }

  static Translator load(Map<Locale, Map<String, dynamic>> translation) {
    return Translator._(translation);
  }

  //

  static Translator load2(ApiServer2 api, Map<Locale, Map<String, dynamic>> translation) {
    return Translator._(translation)..api = api;
  }

  static _log(String message) {
    print(message);
  }

  String tr(
    String language,
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) {
    late String res;

    if (gender != null) {
      res = _gender(language, key, gender: gender);
    } else {
      res = _resolve(language, key);
    }

    res = _replaceLinks(language, res);

    res = _replaceNamedArgs(res, namedArgs);

    return _replaceArgs(res, args);
  }

  String _replaceLinks(String language, String res, {bool logging = true}) {
    // TODO: add recursion detection and a resolve stack.
    final matches = _linkKeyMatcher.allMatches(res);
    var result = res;

    for (final match in matches) {
      final link = match[0]!;
      final linkPrefixMatches = _linkKeyPrefixMatcher.allMatches(link);
      final linkPrefix = linkPrefixMatches.first[0]!;
      final formatterName = linkPrefixMatches.first[1];

      // Remove the leading @:, @.case: and the brackets
      final linkPlaceholder = link.replaceAll(linkPrefix, "").replaceAll(_bracketsMatcher, "");

      var translated = _resolve(language, linkPlaceholder);

      if (formatterName != null) {
        if (_modifiers.containsKey(formatterName)) {
          translated = _modifiers[formatterName]!(translated);
        } else {
          if (logging) {
            _log("Undefined modifier $formatterName, available modifiers: ${_modifiers.keys.toString()}");
          }
        }
      }

      result = translated.isEmpty ? result : result.replaceAll(link, translated);
    }

    return result;
  }

  String _replaceArgs(String res, List<String>? args) {
    if (args == null || args.isEmpty) return res;
    for (var str in args) {
      res = res.replaceFirst(_replaceArgRegex, str);
    }
    return res;
  }

  String _replaceNamedArgs(String res, Map<String, String>? args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String key, String value) => res = res.replaceAll(RegExp("{$key}"), value));
    return res;
  }

  static PluralRule? _pluralRule(String? locale, num howMany) {
    startRuleEvaluation(howMany);
    return pluralRules[locale];
  }

  String plural(
    String language,
    String key,
    num value, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) {
    late PluralCase pluralCase;
    late String res;
    var pluralRule = _pluralRule(language, value);
    switch (value) {
      case 0:
        pluralCase = PluralCase.ZERO;
        break;
      case 1:
        pluralCase = PluralCase.ONE;
        break;
      case 2:
        pluralCase = PluralCase.TWO;
        break;
      default:
        pluralCase = pluralRule!();
    }
    switch (pluralCase) {
      case PluralCase.ZERO:
        res = _resolvePlural(language, key, "zero");
        break;
      case PluralCase.ONE:
        res = _resolvePlural(language, key, "one");
        break;
      case PluralCase.TWO:
        res = _resolvePlural(language, key, "two");
        break;
      case PluralCase.FEW:
        res = _resolvePlural(language, key, "few");
        break;
      case PluralCase.MANY:
        res = _resolvePlural(language, key, "many");
        break;
      case PluralCase.OTHER:
        res = _resolvePlural(language, key, "other");
        break;
      default:
        throw ArgumentError.value(value, "howMany", "Invalid plural argument");
    }

    final formattedValue = format == null ? "$value" : format.format(value);

    if (name != null) {
      namedArgs = {...?namedArgs, name: formattedValue};
    }
    res = _replaceNamedArgs(res, namedArgs);

    return _replaceArgs(res, args ?? [formattedValue]);
  }

  String _gender(String language, String key, {required String gender}) {
    return _resolve(language, "$key.$gender");
  }

  String _resolvePlural(String language, String key, String subKey) {
    if (subKey == "other") return _resolve(language, "$key.other");

    final tag = "$key.$subKey";
    var resource = _resolve(language, tag, logging: false, fallback: false);
    if (resource == tag) {
      resource = _resolve(language, "$key.other");
    }
    return resource;
  }

  String _resolve(String language, String key, {bool logging = true, bool fallback = true}) {
    final translation = _translations[language];
    return translation?[key] ?? key;
  }
}

// eof

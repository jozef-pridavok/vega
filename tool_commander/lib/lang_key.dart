import "package:core_dart/core_dart.dart";

class LangKey {
  final String dartKey;
  final String langKey;

  int _counter;

  LangKey(this.dartKey, this.langKey) : _counter = 0;

  factory LangKey.fromLangKey(String langKey) {
    final dartKey = langKey.toCamelCase();
    return LangKey(dartKey, langKey);
  }

  get counter => _counter;

  get isCore => langKey.startsWith("core_");
  get isTranslation => langKey == "translation_version";

  get isNotCore => !isCore;

  void resetCounter() => _counter = 0;

  void increment() => _counter++;

  @override
  String toString() => "LangKey{dartKey: $dartKey, langKey: $langKey, counter: $_counter}";
}

// eof

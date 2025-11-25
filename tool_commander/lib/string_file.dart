import "dart:io";

import "package:tool_commander/lang_key.dart";

class StringFile {
  List<LangKey> keys;

  StringFile._(this.keys);

  factory StringFile.fromFile(String file) {
    final lines = File(file).readAsLinesSync();
    final keys = lines
        .where((e) => e.startsWith("  static const "))
        .map((e) {
          final pair = e.split(" = ");
          return (pair.first.split(" ").last, pair.last.trim().replaceAll("\"", "").replaceAll(";", ""));
        })
        .map((e) => LangKey(e.$1, e.$2))
        .toList();
    return StringFile._(keys);
  }

  List<LangKey> get unusedKeys => keys.where((e) => e.isNotCore && e.counter == 0).toList();

  void removeUnused() => keys.removeWhere((e) => e.isNotCore && e.counter == 0);

  String toFileContent() {
    final keysContent = StringBuffer();
    keysContent.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    keysContent.writeln();
    keysContent.writeln("class LangKeys {");
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      keysContent.writeln("  static const ${key.dartKey} = \"${key.langKey}\";");
    }
    keysContent.writeln("}");
    return keysContent.toString();
  }

  Future<void> saveToFile(String file) => File(file).writeAsString(toFileContent(), flush: true);

  void addKeys(Iterable<String> langKeys, {bool ignoreDuplicates = true}) {
    for (final langKey in langKeys) {
      if (ignoreDuplicates && keys.any((e) => e.langKey == langKey)) continue;
      keys.add(LangKey.fromLangKey(langKey));
    }
  }

  List<String> findDuplicates(List<String> langKeys) {
    final keysSet = keys.map((e) => e.langKey).toSet();
    return langKeys.where((e) => keysSet.contains(e)).toList();
  }
}

// eof

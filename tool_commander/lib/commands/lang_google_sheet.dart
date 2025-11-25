import "dart:async";
import "dart:convert";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart";
import "package:path/path.dart" as path;
import "package:tool_commander/commands/command.dart";

class LangGoogleSheet extends VegaCommand {
  LangGoogleSheet() {
    argParser.addOption("url", help: "Published GoogleSheet URL");
    argParser.addOption("keys", help: "Generated Dart keys file");
    argParser.addOption("output", help: "Output directory for JSON language files");
    argParser.addFlag("pretty", help: "Pretty printing in JSON language files");
  }

  @override
  String get name => "update";

  @override
  String get description => "Update language files";

  @override
  List<String> get aliases => ["u"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final gs = argResults?["url"];
    final pretty = argResults?["pretty"] as bool;

    print("Downloading GoogleSheet...");

    final dio = Dio();
    final response = await dio.get(
      "$gs&rnd=${DateTime.now().millisecondsSinceEpoch}",
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          "Cache-Control": "no-cache, no-store",
          "Pragma": "no-cache",
        },
      ),
    );

    final data = response.data as String;
    final rows = data.split("\n");
    final langs = rows[0].split("\t").map((e) => e.trim()).toList();
    final lines = rows.skip(1);

    print("Processing languages: ${langs.join(", ")}");
    print("  ${langs.length} languages, ${lines.length} lines");
    print("  ${lines.last.split("\t").firstOrNull}");

    final langStringMap = <String, String>{};
    for (final lang in langs) {
      langStringMap[lang] = "{";
      for (final src in lines) {
        final line = src.trim();
        if (line.isEmpty) continue;
        final tv = line.split("\t");
        final pair = tv[langs.indexOf(lang)];
        langStringMap[lang] = "${langStringMap[lang]}\n  $pair";
      }
      langStringMap[lang] = "${langStringMap[lang]}\n}";
    }

    print("Preparing JSON...");
    print("  ${langStringMap.keys.join(", ")}");

    final langJsonMap = <String, Map<String, dynamic>>{};
    for (final lang in langs) {
      try {
        langJsonMap[lang] = jsonDecode(langStringMap[lang] ?? "");
      } catch (e) {
        return "Invalid JSON!\nSource: $gs\nLanguage: $lang\nError: $e";
      }
    }

    final firstLang = langJsonMap.keys.first;
    final langKeys = langJsonMap[firstLang]!.keys.toList();
    final langCamelKeys = langKeys.map((e) => e.toCamelCase()).toList();

    print("Generating keys...");
    print("  ${langKeys.length} keys");

    final keysFile = File(argResults?["keys"]);
    final keysContent = StringBuffer();
    keysContent.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    keysContent.writeln("// GENERATED FROM: $gs");
    keysContent.writeln();
    keysContent.writeln("class LangKeys {");
    for (var i = 0; i < langKeys.length; i++) {
      final key = langKeys[i];
      final camelKey = langCamelKeys[i];
      keysContent.writeln("  static const $camelKey = \"$key\";");
    }
    keysContent.writeln("}");
    await keysFile.writeAsString(keysContent.toString(), flush: true);

    print("Generating language files...");
    print("  ${langJsonMap.keys.join(", ")}");

    final outputDir = Directory(argResults?["output"]);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    final jsonEncoder = JsonEncoder.withIndent(pretty ? "  " : null);
    for (final lang in langs) {
      final langJson = langJsonMap[lang];
      final langFile = File(path.join(outputDir.path, "$lang.json"));
      print("  $lang -> ${langFile.path}");
      final langContent = jsonEncoder.convert(langJson);
      await langFile.writeAsString(langContent, flush: true);
    }

    final lastRow = langJsonMap[firstLang]?["translation_version"];
    return "\n$lastRow\nOk";
  }
}

// eof

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:intl/intl.dart";
import "package:path/path.dart" as path;
import "package:pubspec_yaml/pubspec_yaml.dart";
import "package:tool_commander/commands/redis_mixin.dart";

import "command.dart";

class _Translation {
  final String key;
  final dynamic value;

  _Translation({required this.key, required this.value});

  _Translation copyWith({String? value}) => _Translation(key: key, value: value ?? this.value);

  @override
  toString() => "$key: $value";
}

class LangRedis extends VegaCommand with Redis {
  LangRedis() {
    addRedisOptions(argParser);
    argParser.addOption("input", help: "Input main project directory with pubspec.yaml");
    argParser.addOption("output", help: "Output directory", defaultsTo: null);
    argParser.addFlag("pull", help: "Pull translation from server to files", defaultsTo: false);
  }

  @override
  String get name => "redis";

  @override
  String get description => "Manage translation among source code and redis";

  @override
  List<String> get aliases => ["r"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();

    Directory input = Directory(argResults?["input"] ?? Directory.current.absolute.path);
    if (!input.existsSync()) return "Input directory '$input' does not exist";
    String? output = argResults?["output"] as String?;
    /*
    final locale = argResults?["locale"] as String;
    final refLocales = (argResults?["ref-locales"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    final keys = (argResults?["keys"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    final excludedKeys = (argResults?["excluded-keys"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    String? output = argResults?["output"] as String?;
    final verbose = argResults?["verbose"] as bool;
    bool dryRun = argResults?["dry-run"] as bool;
    */

    PubspecYaml pubspecYaml;
    late final List<String> locales;
    String assetsDir = "";
    try {
      pubspecYaml = File(path.join(input.path, "pubspec.yaml")).readAsStringSync().toPubspecYaml();
      final customFields = pubspecYaml.customFields;
      try {
        final relativeAssetsDir = customFields["vega"]["localization"]["assets"] as String;
        assetsDir = path.normalize(path.join(input.absolute.path, relativeAssetsDir));
      } catch (e) {
        return "Error reading pubspec.yaml. Failed to read vega.localization.assets: $e";
      }
      try {
        locales = (customFields["vega"]["localization"]["locales"] as List<dynamic>).cast<String>();
        if (locales.isEmpty) throw "No locales found";
      } catch (e) {
        return "Error reading pubspec.yaml. Failed to read vega.localization.locales: $e";
      }
    } catch (e) {
      return "Error reading pubspec.yaml: $e";
    }

    final pull = argResults?["pull"] as bool;

    await connect(argResults);

    try {
      for (final locale in locales) {
        final localeAssetJsonPath = path.join(assetsDir, "$locale.json");
        final localeAssetFile = File(localeAssetJsonPath);
        if (!localeAssetFile.existsSync()) {
          print("Locale $locale not found ($localeAssetJsonPath)");
          continue;
        }
        try {
          final json = jsonDecode(localeAssetFile.readAsStringSync());
          if (!pull) {
            await _push(pubspecYaml.name, locale, json);
          } else {
            await _pull(pubspecYaml.name, locale, json, localeAssetFile, output);
          }
        } catch (e) {
          print("Error reading $localeAssetJsonPath: $e");
        }
      }
    } finally {
      await close();
    }

    return "Done";
  }

  Future<void> _pull(
      String module, String language, Map<String, dynamic> originJson, File localeAssetFile, String? output) async {
    final prefix = "$module:pending:$language:";
    final res = await execute(["KEYS", "$prefix*"]);
    final keys = (res as List<dynamic>? ?? []).cast<String>();

    final all = await Future.wait(keys.map((key) async {
      final value = ((await execute(["GET", key])) as String? ?? "").trim();
      return _Translation(key: key.substring(prefix.length), value: value);
    }));

    final grouped = _groupTranslations(all);
    print("Grouped: ${grouped.length}");

    final newJson = originJson;
    for (final translation in grouped) {
      newJson[translation.key] = translation.value;
    }
    final formatter = DateFormat("yyMMddHHmmss");
    final version = formatter.format(DateTime.now().toUtc());
    newJson["translation_version"] = version;

    Directory outputDir = Directory(localeAssetFile.parent.path);
    if (output != null) {
      outputDir = Directory(output);
      if (!outputDir.existsSync()) {
        print("Output directory '$output' does not exist");
        return;
      }
    }
    final outputPath = path.join(outputDir.path, "$language.json");
    final outputJson = File(outputPath);
    outputJson.writeAsStringSync(jsonEncode(newJson));
  }

  Future<void> _push(String module, String language, Map<String, dynamic> json) async {
    json.removeWhere((key, value) => key.startsWith("core_"));
    json.remove("translation_version");
    await _pushToRedis(json, "$module:current:$language:");
  }

  Future<void> _pushToRedis(Map<String, dynamic> data, [String prefix = ""]) async {
    for (var key in data.keys) {
      print("Pushing $prefix$key (${(data.keys.toList().indexOf(key) / data.keys.length * 100).toStringAsFixed(2)}%)");
      final value = data[key];
      if (value is Map<String, dynamic>) {
        await _pushToRedis(value, "$prefix$key:");
      } else {
        await execute(["SET", "$prefix$key", value]);
      }
    }
  }

  List<_Translation> _groupTranslations(List<_Translation> translations) {
    // Map pre uloženie dočasných výsledkov
    final Map<String, Map<String, dynamic>> grouped = {};
    final List<_Translation> result = [];

    for (var translation in translations) {
      // Rozdeľ key podľa dvojbodky
      final parts = translation.key.split(':');

      if (parts.length > 1) {
        final prefix = parts[0];
        final suffix = parts[1];

        // Ak prefix ešte neexistuje v grouped mape, inicializuj ho
        if (!grouped.containsKey(prefix)) {
          grouped[prefix] = {};
        }

        // Pridaj do groupy, kde klúč je suffix a hodnota je translation.value
        grouped[prefix]![suffix] = translation.value;
      } else {
        // Ak neobsahuje dvojbodku, priamo pridaj do výsledku
        result.add(translation);
      }
    }

    // Preved všetky zgrupené položky do zoznamu _Translation
    grouped.forEach((key, value) {
      result.add(_Translation(key: key, value: value));
    });

    return result;
  }
}

// eof

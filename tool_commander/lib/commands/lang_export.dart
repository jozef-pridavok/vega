import "dart:async";
import "dart:convert";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:path/path.dart" as path;
import "package:pubspec_yaml/pubspec_yaml.dart";

import "command.dart";

class LangExport extends VegaCommand {
  LangExport() {
    argParser.addOption("input", help: "Input main project directory with pubspec.yaml");
    argParser.addOption("locale", help: "Locale to export", defaultsTo: "en");
    argParser.addOption("ref-locales", help: "Reference locales to export for help texts", defaultsTo: null);
    argParser.addOption("keys", help: "List of keys to export. You can use wild card pattern", defaultsTo: null);
    argParser.addOption("excluded-keys",
        help: "List of keys to exclude from export. You can use wild card pattern", defaultsTo: null);
    argParser.addOption("output", help: "Output directory", defaultsTo: null);
    argParser.addFlag("verbose", help: "Verbose output", defaultsTo: false);
    argParser.addFlag("dry-run", help: "Dry run, do not remove anything", defaultsTo: false);
  }

  @override
  String get name => "export";

  @override
  String get description => "Export all strings from localization json files";

  @override
  List<String> get aliases => ["e"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();

    Directory input = Directory(argResults?["input"] ?? Directory.current.absolute.path);
    if (!input.existsSync()) return "Input directory '$input' does not exist";

    final locale = argResults?["locale"] as String;
    final refLocales = (argResults?["ref-locales"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    final keys = (argResults?["keys"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    final excludedKeys = (argResults?["excluded-keys"] as String?)?.split(",").map((e) => e.trim()).toList() ?? [];
    String? output = argResults?["output"] as String?;
    final verbose = argResults?["verbose"] as bool;
    bool dryRun = argResults?["dry-run"] as bool;

    PubspecYaml pubspecYaml;
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
    } catch (e) {
      return "Error reading pubspec.yaml: $e";
    }

    if (output == null) {
      output = input.path;
      if (verbose) {
        print("No output directory specified, using input directory");
        print("  $output");
      }
    }

    final outputDir = Directory(output);
    if (!outputDir.existsSync()) return "Output directory '$output' does not exist";

    final localeAssetsJsonPath = path.join(assetsDir, "$locale.json");

    final refLocaleJson = <String, Map<String, dynamic>>{};

    for (final refLocale in refLocales) {
      final refLocaleAssetsJsonPath = path.join(assetsDir, "$refLocale.json");
      if (!File(refLocaleAssetsJsonPath).existsSync()) {
        continue;
      }
      final refJson = jsonDecode(File(refLocaleAssetsJsonPath).readAsStringSync()) as Map<String, dynamic>;
      refLocaleJson[refLocale] = refJson;
    }

    _exportAssetJson(localeAssetsJsonPath, refLocaleJson, keys, excludedKeys, output, verbose, dryRun);

    return "Done";
  }

  void _exportAssetJson(
    String assetJsonPath,
    Map<String, Map<String, dynamic>> refJson,
    List<String> keys,
    List<String> excludedKeys,
    String output,
    bool verbose,
    bool dryRun,
  ) {
    final jsonFile = File(assetJsonPath);
    final json = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

    final outputFile = File(path.join(output, "${path.basenameWithoutExtension(assetJsonPath)}.txt"));
    final StringBuffer buffer = StringBuffer();

    for (final key in json.keys) {
      //if (keys.isNotEmpty && !keys.contains(key)) {
      if (keys.isNotEmpty && !keys.any((element) => element.isMatch(key))) {
        continue;
      }

      if (excludedKeys.isNotEmpty && excludedKeys.any((element) => element.isMatch(key))) {
        continue;
      }

      buffer.writeln("! $key");

      if (refJson.isNotEmpty) {
        for (final refLocale in refJson.keys) {
          final refValue = refJson[refLocale]?[key]; // as String?;
          if (refValue is String?) {
            buffer.writeln("* ($refLocale) $refValue");
          } else if (refValue is Map<String, dynamic>?) {
            buffer.writeln("* ($refLocale) ${jsonEncode(refValue)}");
          }
        }
      }
      if (json[key] is String?)
        buffer.writeln(json[key]);
      else if (json[key] is Map<String, dynamic>?) buffer.writeln(jsonEncode(json[key]));

      buffer.writeln("");
    }

    if (buffer.isEmpty) {
      if (verbose) print("No keys found for $assetJsonPath");
      return;
    }

    if (verbose) print("Writing to ${outputFile.path}");
    if (dryRun) {
      print("Dry run, not saving to file. The file content would be:");
      print(buffer.toString());
      print("\n");
    } else {
      outputFile.writeAsStringSync(buffer.toString());
    }
  }
}

// eof

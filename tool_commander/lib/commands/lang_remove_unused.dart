import "dart:async";
import "dart:convert";
import "dart:io";

import "package:intl/intl.dart";
import "package:path/path.dart" as path;
import "package:pubspec_yaml/pubspec_yaml.dart";

import "../files.dart";
import "../lang_key.dart";
import "../string_file.dart";
import "command.dart";

class LangRemoveUnused extends VegaCommand {
  LangRemoveUnused() {
    argParser.addOption("input", help: "Input main project directory with pubspec.yaml");
    argParser.addFlag("verbose", help: "Verbose output", defaultsTo: false);
    argParser.addFlag("dry-run", help: "Dry run, do not remove anything", defaultsTo: false);
  }

  @override
  String get name => "remove_unused";

  @override
  String get description => "Remove unused keys from strings.dart and localization json files";

  @override
  List<String> get aliases => ["x"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final verbose = argResults?["verbose"] as bool;
    final dryRun = argResults?["dry-run"] as bool;

    Directory input = Directory(argResults?["input"] ?? Directory.current.absolute.path);
    if (!input.existsSync()) return "Input directory '$input' does not exist";

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

    final stringsFile = path.join(input.path, "lib", "strings.dart");
    if (!File(stringsFile).existsSync()) return "Strings file '$stringsFile' not found";

    final stringFile = StringFile.fromFile(stringsFile);
    final keys = stringFile.keys;
    if (verbose) {
      print("Found ${keys.length} keys");
      print(keys.join("\n"));
    }

    Files allFiles = Files.listPackageSources(input.path);
    for (final key in keys) {
      key.resetCounter();
      allFiles.count(key);
    }

    final unusedKeys = stringFile.unusedKeys;
    if (unusedKeys.isNotEmpty) {
      print("Found ${unusedKeys.length} unused keys");
      if (verbose) print(unusedKeys.join("\n"));

      print("Removing unused keys from $stringsFile");
      stringFile.removeUnused();
      if (dryRun) {
        print("Dry run, not saving to file. The file content would be:");
        print(stringFile.toFileContent());
        print("\n");
      } else
        await stringFile.saveToFile(stringsFile);

      final assetJsonFiles = Directory(assetsDir).listSync().whereType<File>().where((e) => e.path.endsWith(".json"));
      for (final assetJson in assetJsonFiles) _removeUnused(assetJson, unusedKeys, verbose, dryRun);
    } else {
      print("No unused keys found");
    }

    return "Done";
  }

  void _removeUnused(File jsonFile, List<LangKey> unusedKeys, bool verbose, bool dryRun) {
    print("Removing unused keys from ${jsonFile.path}");
    final oldJson = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

    oldJson.removeWhere((key, value) => unusedKeys.any((e) => e.langKey == key));

    if (oldJson.containsKey("translation_version")) {
      final formatter = DateFormat("yyMMddHHmmss");
      final version = formatter.format(DateTime.now().toUtc());
      oldJson["translation_version"] = version;
      if (verbose) print("Updated translation_version to $version");
    } else {
      if (verbose) print("No translation_version found");
    }

    final newJson = jsonEncode(oldJson);
    if (dryRun) {
      print("Dry run, not saving to file. The file content would be:");
      print(newJson);
      print("\n");
    } else
      jsonFile.writeAsStringSync(newJson);
  }
}

// eof

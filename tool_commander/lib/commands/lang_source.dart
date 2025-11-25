import "dart:async";
import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:core_dart/core_dart.dart";
import "package:intl/intl.dart";
import "package:path/path.dart" as path;
import "package:pubspec_yaml/pubspec_yaml.dart";
import "package:tool_commander/source_line.dart";

import "../files.dart";
import "../string_file.dart";
import "command.dart";

class LangSource extends VegaCommand {
  LangSource() {
    argParser.addOption(
      "input",
      help: "Input main project directory with pubspec.yaml",
    );
    argParser.addFlag(
      "check-duplicates",
      help: "Checks duplicates",
      defaultsTo: false,
    );
    argParser.addFlag("verbose", help: "Verbose output", defaultsTo: false);
    argParser.addFlag(
      "dry-run",
      help: "Dry run, do not remove anything",
      defaultsTo: false,
    );
  }

  @override
  String get name => "source";

  @override
  String get description =>
      "Process TODO: localize lines in source code files and update strings.dart and localization json files";

  @override
  List<String> get aliases => ["s"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();

    Directory input = Directory(
      argResults?["input"] ?? Directory.current.absolute.path,
    );
    if (!input.existsSync()) return "Input directory '$input' does not exist";

    late final List<String> locales;
    final checkDuplicates = argResults?["check-duplicates"] as bool;
    final verbose = argResults?["verbose"] as bool;
    bool dryRun = argResults?["dry-run"] as bool;
    bool forceDryRun = false;

    PubspecYaml pubspecYaml;
    String assetsDir = "";
    try {
      pubspecYaml = File(
        path.join(input.path, "pubspec.yaml"),
      ).readAsStringSync().toPubspecYaml();
      final customFields = pubspecYaml.customFields;
      try {
        final relativeAssetsDir =
            customFields["vega"]["localization"]["assets"] as String;
        assetsDir = path.normalize(
          path.join(input.absolute.path, relativeAssetsDir),
        );
      } catch (e) {
        return "Error reading pubspec.yaml. Failed to read vega.localization.assets: $e";
      }
      try {
        locales =
            (customFields["vega"]["localization"]["locales"] as List<dynamic>)
                .cast<String>();
        if (locales.isEmpty) throw "No locales found";
      } catch (e) {
        return "Error reading pubspec.yaml. Failed to read vega.localization.locales: $e";
      }
    } catch (e) {
      return "Error reading pubspec.yaml: $e";
    }

    final corePackageRelative = pubspecYaml.dependencies
        .where((e) => e.package().startsWith("core_"))
        .map(
          (e) => e.iswitch(
            sdk: (value) => null,
            git: (value) => null,
            path: (value) => value.path,
            hosted: (value) => null,
          ),
        )
        .whereType<String>();

    if (corePackageRelative.isEmpty)
      return "No core package with relative path found";

    final stringsFile = path.join(input.path, "lib", "strings.dart");

    final appFiles = Files.listPackageSources(
      input.path,
      exclude: [stringsFile],
    );
    _verboseFiles(verbose, appFiles, "app ${pubspecYaml.name}");

    Files coresFiles = Files.empty();

    for (final coreRelative in corePackageRelative) {
      final packageRoot = path.normalize(path.join(input.path, coreRelative));
      final coreFiles = Files.listPackageSources(packageRoot);
      coresFiles = coresFiles.merge(coreFiles);
      _verboseFiles(verbose, coreFiles, "core $packageRoot ($coreRelative)");
    }

    final appTodoAddTasks = List<TodoAddTask>.empty(growable: true);
    forceDryRun = await _parseTodoAddTasks(
      verbose,
      appFiles,
      appTodoAddTasks,
      locales,
    );
    if (forceDryRun) {
      dryRun = true;
      return "Force dry run";
    }

    final appTodoAddPluralExpandedTasks = List<TodoAddTask>.empty(
      growable: true,
    );
    forceDryRun = await _readTodoAddPluralTasks(
      verbose,
      appFiles,
      appTodoAddPluralExpandedTasks,
      locales,
    );
    if (forceDryRun) {
      dryRun = true;
      return "Force dry run";
    }

    final appTodoAddPluralTasks = _packPlural(appTodoAddPluralExpandedTasks);

    final coreTodoAdd = List<TodoAddTask>.empty(growable: true);
    forceDryRun = await _parseTodoAddTasks(
      verbose,
      coresFiles,
      coreTodoAdd,
      locales,
    );
    if (forceDryRun) {
      dryRun = true;
      return "Force dry run";
    }

    print(
      "Application ${pubspecYaml.name} todo localizations : ${appTodoAddTasks.length}",
    );
    print(
      "Application ${pubspecYaml.name} todo localization plurals : ${appTodoAddPluralExpandedTasks.length}",
    );
    // dump all appTodoAddPlural
    //for (final task in appTodoAddPlural) {
    //  print("  ${task.dartKey} : ${task.translations}");
    //}
    print(
      "Application ${pubspecYaml.name} todo localization plurals : ${appTodoAddPluralTasks.length}",
    );
    print("Cores todo localizations : ${coreTodoAdd.length}");

    if (!File(stringsFile).existsSync())
      return "Strings file '$stringsFile' not found";

    final stringFile = StringFile.fromFile(stringsFile);

    final appTodoAppKeys = appTodoAddTasks.map((e) => e.langKey).toList();
    if (checkDuplicates) {
      final appTodoAppDuplicatedKeys = stringFile.findDuplicates(
        appTodoAppKeys,
      );
      if (appTodoAppDuplicatedKeys.isNotEmpty) {
        if (verbose) {
          print(
            "Found ${appTodoAppDuplicatedKeys.length} duplicate keys in $stringsFile",
          );
          print("  ${appTodoAppDuplicatedKeys.join(", ")}");
        }
        //return "Error: Duplicate keys found in $stringsFile";
      }
    }
    stringFile.addKeys(appTodoAppKeys);

    final appTodoAppPluralKeys = appTodoAddPluralTasks
        .map((e) => e.langKey)
        .toList();
    if (checkDuplicates) {
      final appTodoAppPluralDuplicatedKeys = stringFile.findDuplicates(
        appTodoAppPluralKeys,
      );
      if (appTodoAppPluralDuplicatedKeys.isNotEmpty) {
        if (verbose) {
          print(
            "Found ${appTodoAppPluralDuplicatedKeys.length} duplicate keys in $stringsFile",
          );
          print("  ${appTodoAppPluralDuplicatedKeys.join(", ")}");
        }
        //return "Error: Duplicate keys found in $stringsFile";
      }
    }
    stringFile.addKeys(appTodoAppPluralKeys);

    final coreTodoAppKeys = coreTodoAdd.map((e) => e.langKey).toList();
    if (checkDuplicates) {
      final coreTodoAppDuplicatedKeys = stringFile.findDuplicates(
        coreTodoAppKeys,
      );
      if (coreTodoAppDuplicatedKeys.isNotEmpty) {
        if (verbose) {
          print(
            "Found ${coreTodoAppDuplicatedKeys.length} duplicate keys in $stringsFile",
          );
          print("  ${coreTodoAppDuplicatedKeys.join(", ")}");
        }
        //return "Error: Duplicate keys found in $stringsFile";
      }
    }
    stringFile.addKeys(coreTodoAppKeys);

    if (dryRun) {
      print("Dry run, not saving to file. The file content would be:");
      print(stringFile.toFileContent());
      print("\n");
    } else
      await stringFile.saveToFile(stringsFile);

    final assetJsonFiles = Directory(
      assetsDir,
    ).listSync().whereType<File>().where((e) => e.path.endsWith(".json"));
    for (final assetJson in assetJsonFiles) {
      _updateAssetJson(
        assetJson,
        appTodoAddTasks,
        appTodoAddPluralTasks,
        coreTodoAdd,
        verbose,
        dryRun,
      );
    }

    _updateSourceFiles(
      appFiles,
      appTodoAddTasks,
      appTodoAddPluralTasks,
      coreTodoAdd,
      verbose,
      dryRun,
    );

    return "Done";
  }

  void _updateAssetJson(
    File assetJson,
    List<TodoAddTask> appTodoAddTasks,
    List<TodoAddPluralTask> appTodoAddPluralTask,
    List<TodoAddTask> coreTodoAddTasks,
    bool verbose,
    bool dryRun,
  ) {
    final translation = path.basenameWithoutExtension(assetJson.path);
    print("Processing ${assetJson.path} $translation");
    final oldJson =
        jsonDecode(assetJson.readAsStringSync()) as Map<String, dynamic>;

    if (verbose)
      print("Adding/Updating app todo tasks: ${appTodoAddTasks.length}");
    _updateAssetJsonAddTasks(appTodoAddTasks, translation, oldJson, verbose);

    if (verbose)
      print(
        "Adding/Updating app plural todo tasks: ${appTodoAddPluralTask.length}",
      );
    for (final task in appTodoAddPluralTask) {
      final newTranslation = task.translations[translation];
      if (newTranslation == null) {
        //if (verbose) print("Error: No translation for ${task.langKey} in $translation");
        continue;
      }
      final plural = newTranslation.toMap(Convention.snake);
      if (verbose) print("  Overwriting ${task.langKey}, $plural");
      oldJson[task.langKey] = plural;
    }

    if (verbose)
      print("Adding/Updating core todo tasks: ${coreTodoAddTasks.length}");
    _updateAssetJsonAddTasks(coreTodoAddTasks, translation, oldJson, verbose);

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
      assetJson.writeAsStringSync(newJson);
  }

  void _updateAssetJsonAddTasks(
    List<TodoAddTask> addTasks,
    String translation,
    Map<String, dynamic> json,
    bool verbose,
  ) {
    for (final task in addTasks) {
      final newTranslation = task.translations[translation];
      if (newTranslation == null) {
        //if (verbose) print("Error: No translation for ${task.langKey} in $translation");
        continue;
      }
      if (json.containsKey(task.langKey)) {
        if (json[task.langKey] != newTranslation) {
          if (verbose)
            print(
              "  Updating ${task.langKey}, '${json[task.langKey]}' => '$newTranslation'",
            );
          json[task.langKey] = newTranslation;
        }
      } else {
        if (verbose)
          print(
            "  Adding ${task.langKey}, '${task.translations[translation]}'",
          );
        json[task.langKey] = newTranslation;
      }
    }
  }

  void _verboseFiles(bool verbose, Files files, String specifier) {
    if (!verbose) return;
    print("All $specifier source code files:");
    print("  ${files.files.length} files");
    //for (final file in files.files) print("  ${file.path}");
  }

  Future<bool> _parseTodoAddTasks(
    bool verbose,
    Files files,
    List<TodoAddTask> todoAdd,
    List<String> locales,
  ) async {
    const term = "TODO: localize ";
    bool forceDryRun = false;
    final todoLines = await files.containing(term);
    for (final line in todoLines) {
      try {
        todoAdd.add(await _parseTodoLine(term, line, locales));
      } catch (e) {
        //print("Error: $e");
        forceDryRun = true;
      }
    }
    return forceDryRun;
  }

  Future<bool> _readTodoAddPluralTasks(
    bool verbose,
    Files files,
    List<TodoAddTask> todoAdd,
    List<String> locales,
  ) async {
    const term = "TODO: localize_plural ";
    bool forceDryRun = false;
    final todoLines = await files.containing(term);
    for (final line in todoLines) {
      try {
        todoAdd.add(await _parseTodoLine(term, line, locales));
      } catch (e) {
        //print("Error: $e");
        forceDryRun = true;
      }
    }
    return forceDryRun;
  }

  Future<TodoAddTask> _parseTodoLine(
    String term,
    SourceLine line,
    List<String> locales,
  ) async {
    final match = RegExp("$term(.*)").firstMatch(line.line);
    if (match == null)
      return Future.error("Invalid TODO: localize. Match failed");
    final todo = match.group(1);
    if (todo == null)
      return Future.error("Invalid TODO: localize. No match group");

    List<String> parts = [];
    try {
      final keyExpr = r'(\w+)';
      //final translationExpr = r'\s+"([^"]+)"';
      final translationExpr = r'\s*\"([^\"]*)\"';
      final matches = RegExp(
        keyExpr + locales.map((e) => translationExpr).join(","),
      ).allMatches(todo);

      if (matches.isEmpty) print("No matches for: ${todo.trim()}");

      for (RegExpMatch match in matches) {
        final key = match.group(1);
        if (key == null) {
          print("No key found");
          print("  line: ${todo.trim()}");
          print("  source: ${line.file}:${line.lineNumber} ${line.line}");
          print("\n");
          continue;
        }

        parts.add(key);

        locales.forEachIndexed((index, value) {
          final translation = match.group(index + 2);
          if (translation == null) {
            print("No $value translation for: $key");
            print("  line: ${todo.trim()}");
            print("  source: ${line.file}:${line.lineNumber} ${line.line}");
            print("\n");
            return;
          }
          parts.add(translation);
        });
      }
    } catch (e) {
      print("Error: $e");
      print("  line: ${todo.trim()}");
      print("  source: ${line.file}:${line.lineNumber} ${line.line}");
      print("\n");
      return Future.error("Error parsing TODO: localize. $e");
    }

    if (parts.length != locales.length + 1) {
      print("Invalid parts: ${parts.length} != ${locales.length + 1}");
      print("  line: ${todo.trim()}");
      print("  source: ${line.file}:${line.lineNumber} ${line.line}");
      print("\n");
      return Future.error("Error parsing TODO: localize. Invalid parts length");
    }

    return TodoAddTask(
      line: line,
      langKey: parts.first,
      translations: Map.fromIterable(
        locales,
        key: (locale) => locale,
        value: (locale) {
          int index = locales.indexOf(locale) + 1;
          return parts[index];
        },
      ),
    );

    //return TodoAddTask(line: line, dartKey: parts.first, translations: parts.sublist(1));
  }

  (String, String) _stripPlural(String key) {
    /* https://gitlab.vega.com/vega/vega/-/wikis/plural

      zero - zero
      one - singular
      two - dual
      few - paucal
      many - also used for fractions if they have a separate class)
      other - required—general plural form—also used if the language only has a single form)

    */
    final match = RegExp(
      r"(.+)_in_(zero|one|two|few|many|other)$",
    ).firstMatch(key);
    if (match == null) return (key, "");
    return (match.group(1)!, match.group(2)!);
  }

  List<TodoAddPluralTask> _packPlural(List<TodoAddTask> tasks) {
    final packed = <TodoAddPluralTask>[];

    for (final task in tasks) {
      final (key, suffix) = _stripPlural(task.langKey);
      var existing = packed.firstWhereOrNull((e) => e.langKey == key);
      if (existing == null) {
        existing = TodoAddPluralTask(
          line: task.line,
          langKey: key,
          translations: {},
        );
        packed.add(existing);
        task.translations.forEach((locale, translation) {
          existing!.updatePlural(locale, suffix, translation);
        });
      } else {
        task.translations.forEach((locale, translation) {
          existing!.updatePlural(locale, suffix, translation);
        });
      }
    }

    return packed;
  }

  void _updateSourceFiles(
    Files appFiles,
    List<TodoAddTask> appTodoAddTasks,
    List<TodoAddPluralTask> appTodoAddPluralTasks,
    List<TodoAddTask> coreTodoAdd,
    bool verbose,
    bool dryRun,
  ) {
    for (final file in appFiles.files) {
      _updateSourceFile(
        file.absolute.path,
        appTodoAddTasks,
        appTodoAddPluralTasks,
        coreTodoAdd,
        verbose,
        dryRun,
      );
    }
  }

  void _updateSourceFile(
    String filePath,
    List<TodoAddTask> appTodoAddTasks,
    List<TodoAddPluralTask> appTodoAddPluralTasks,
    List<TodoAddTask> coreTodoAdd,
    bool verbose,
    bool dryRun,
  ) {
    final file = File(filePath);
    final lines = file.readAsLinesSync();
    final buffer = StringBuffer();
    for (final line in lines) {
      final updated = _updateSourceLine(
        line,
        appTodoAddTasks,
        appTodoAddPluralTasks,
        coreTodoAdd,
        verbose,
      );
      if (updated == null) {
        if (verbose) print("Removing line: $line");
        continue;
      } else {
        if (verbose && updated != line) {
          print("Updating line: ");
          print("  $line");
          print("  $updated");
        }
        buffer.writeln(updated);
      }
    }
    if (dryRun) {
      print("Dry run, not saving to file. The file content would be:");
      print(buffer.toString());
      print("\n");
    } else
      file.writeAsStringSync(buffer.toString());
  }

  String? _updateSourceLine(
    String line,
    List<TodoAddTask> appTodoAddTasks,
    List<TodoAddPluralTask> appTodoAddPluralTasks,
    List<TodoAddTask> coreTodoAdd,
    bool verbose,
  ) {
    // Remove all "TODO: localize " and "TODO: localize_plural " lines
    // Replace all `"lang_key"` by `LangKeys.dartKey`

    final todoAdd = appTodoAddTasks + coreTodoAdd;
    final todoAddPlural = appTodoAddPluralTasks;

    final match = RegExp(r"TODO: localize(?:_plural)? (.*)").firstMatch(line);
    if (match != null) return null;

    final updated = todoAdd.fold(line, (line, task) {
      final updated = line.replaceAll(
        "\"${task.langKey}\"",
        "LangKeys.${task.langKey.toCamelCase()}",
      );
      return updated;
    });

    return todoAddPlural.fold(updated, (line, task) {
      final updated = line?.replaceAll(
        "\"${task.langKey}\"",
        "LangKeys.${task.langKey.toCamelCase()}",
      );
      return updated;
    });
  }
}

class TodoAddTask {
  final SourceLine line;
  final String langKey;
  // {"sk": "Slovenský preklad", "en": "English translation", "es": "Traducción al español"}
  final Map<String, String> translations;

  TodoAddTask({
    required this.line,
    required this.langKey,
    required this.translations,
  });
}

class TodoAddPluralTask {
  final SourceLine line;
  final String langKey;
  // {"sk": Plural{"zero": "Slovenský preklad", "one": "Slovenský preklad", ...}, "en": Plural{"zero": "English translation", "one": "English translation", ...}}
  final Map<String, Plural> translations;

  TodoAddPluralTask({
    required this.line,
    required this.langKey,
    required this.translations,
  });

  void updatePlural(String locale, String suffix, String translation) {
    final plural = Plural.fromMap({
      suffix: translation.isEmpty ? null : translation,
    }, Convention.snake);
    translations[locale] = translations[locale]?.merge(plural) ?? plural;
  }

  @override
  String toString() {
    return "TodoAddPluralTask{dartKey: $langKey, translations: $translations}";
  }
}

// eof

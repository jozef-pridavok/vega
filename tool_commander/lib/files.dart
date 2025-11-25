import "dart:io";

import "package:path/path.dart" as path;
import "package:tool_commander/lang_key.dart";
import "package:tool_commander/source_line.dart";

class Files {
  final List<FileSystemEntity> files;

  Files._(this.files);

  factory Files.empty() => Files._([]);

  factory Files.listDir(String root) {
    final dir = Directory(root);
    final files = dir.listSync(recursive: true);
    return Files._(files);
  }

  // List all *.dart files in lib directory
  factory Files.listPackageSources(String root, {List<String> exclude = const []}) {
    final dir = Directory(path.join(root, "lib"));
    //final files = dir.listSync(recursive: true).whereType<File>().where((e) => e.path.endsWith(".dart"));
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((e) => e.path.endsWith(".dart") && !exclude.any((e.path.contains)));
    return Files._(files.toList());
  }

  Files merge(Files other) => Files._([...files, ...other.files]);

  Future<List<SourceLine>> containing(String term) async {
    final result = <SourceLine>[];
    for (final file in files) {
      final lines = await File(file.path).readAsLines();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains(term)) {
          result.add(SourceLine(file.absolute.path, line, i + 1));
        }
      }
    }
    return result;
  }

  void count(LangKey key) {
    for (final file in files) {
      final lines = File(file.path).readAsStringSync();
      if (lines.contains("LangKeys.${key.dartKey}")) key.increment();
    }
  }
}

// eof

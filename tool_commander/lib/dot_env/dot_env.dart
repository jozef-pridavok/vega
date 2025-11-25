import "dart:io";

import "package:tool_commander/dot_env/parser.dart";

/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call (dotenv.load), the env variables can be accessed as a map
/// using the env getter of dotenv (dotenv.env).
/// You may wish to prefix the import.
///
///     import 'package:flutter_dotenv/flutter_dotenv.dart';
///
///     void main() async {
///       await dotenv.load();
///       var x = dotenv.env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => dotenv.isEveryDefined(_requiredEnvVars);
///
//DotEnv dotenv = DotEnv();

class DotEnv {
  final Map<String, String> _envMap;

  DotEnv(this._envMap);

  Map<String, String> get env => _envMap;
  String? get(String name, {String? fallback}) => _envMap[name] ?? fallback;

  static Future<DotEnv> load({String fileName = ".env", Parser parser = const Parser()}) async {
    final file = File(fileName);
    final linesFromFile = await file.readAsLines();
    final envEntries = parser.parse(linesFromFile);
    return DotEnv(envEntries);
  }

  static Future<DotEnv> testLoad({String fileInput = "", Parser parser = const Parser()}) async {
    final linesFromFile = fileInput.split("\n");
    final envEntries = parser.parse(linesFromFile);
    return DotEnv(envEntries);
  }
}

// eof

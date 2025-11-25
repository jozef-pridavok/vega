import "dart:async";
import "dart:convert";
import "dart:io";

import "package:tool_commander/commands/command.dart";
import "package:tool_commander/commands/psql_mixin.dart";
import "package:tool_commander/json_by_path.dart";

class _Command {
  final String sql;
  final String? extract;

  _Command(this.sql, {this.extract});
}

class PsqlExec extends VegaCommand with Psql {
  PsqlExec() {
    addPostgresOptions(argParser);
    argParser.addOption("command", help: "SQL command");
    argParser.addOption("file", help: "SQL file");
    argParser.addOption("extract", help: "JSON path to extract value from the first row of resultset");
    argParser.addFlag("pretty", help: "Pretty print JSON result");
  }

  @override
  String get name => "exec";

  @override
  String get description => "Execute sql";

  @override
  List<String> get aliases => ["e"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final pretty = argResults?["pretty"] as bool;
    final sql = argResults?["command"];
    final file = argResults?["file"];
    final extract = argResults?["extract"];
    final out = StringBuffer();

    if (file != null && extract != null) {
      return "Do not use '--extract' for '--file'. You can use special comment in SQL file e.g.: '--extract: path.to.value'";
    }

    if (sql == null && file == null) {
      return "'--command' or '--file' expected";
    }

    final commands = <_Command>[];
    if (sql != null) {
      commands.add(_Command(sql, extract: extract));
    }
    if (file != null) commands.addAll(await _loadFromFile(file));

    try {
      await connect(argResults);
      for (final command in commands) {
        out.writeln();
        out.writeln(command.sql);
        final res = await select(command.sql);
        final encoder = JsonEncoder.withIndent(pretty ? "  " : null, (item) {
          if (item is DateTime) {
            return item.toIso8601String();
          }
          return "$item: ${item.runtimeType}";
        });
        if (command.extract != null) {
          final path = JsonByPath();
          final value = path.getValue(res[0], command.extract);
          //out.write(command.extract);
          //out.write("=");
          out.writeln(value);
        } else {
          //if (res.isEmpty || (res.length == 1 && res[0].containsKey(""))) {
          //  out.writeln("OK");
          //} else {
          out.writeln(encoder.convert(res));
          //}
        }
      }
    } catch (ex) {
      out.writeln(ex.toString());
    } finally {
      await close();
    }
    return out.toString();
  }

  static const String _extract = "--extract";

  Future<List<_Command>> _loadFromFile(String fileName) async {
    final file = File(fileName);
    final commands = <_Command>[];
    final lines = await file.readAsLines();
    final command = StringBuffer();
    var inDD = false; // double dollar, $$
    String? extract;
    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      final head = line.trimLeft();
      final tail = line.trimRight();
      if (head.startsWith(_extract)) {
        final start = line.indexOf(_extract);
        extract = line.substring(start + _extract.length).trim();
        continue;
      } else if (head.startsWith("--")) {
        continue;
      } else if (tail.endsWith("\$\$")) {
        inDD = !inDD;
        command.writeln(line);
      } else if (!inDD && tail.endsWith(";")) {
        command.writeln(line);
        commands.add(_Command(command.toString().trim(), extract: extract));
        command.clear();
        extract = null;
      } else {
        command.writeln(line);
      }
    }
    if (command.isNotEmpty) {
      commands.add(_Command(command.toString().trim(), extract: extract));
    }
    return commands;
  }
}

// eof

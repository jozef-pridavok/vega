import "dart:async";
import "dart:io";

import "package:tool_commander/commands/command.dart";
import "package:tool_commander/commands/psql_mixin.dart";

class PsqlPump extends VegaCommand with Psql {
  PsqlPump() {
    addPostgresOptions(argParser);
    argParser.addOption("file", help: """Pump file transmformation. 
    
E.g.:
dart run ./bin/vtc.dart psql pump --file ./sql/migration_cards.sql
    """);
  }

  @override
  String get name => "pump";

  @override
  String get description => "Pump data";

  @override
  List<String> get aliases => ["p"];

  static const String _connection = "--connection";
  static const String _target = "--target";

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final out = StringBuffer();

    final fileName = argResults?["file"];
    final file = File(fileName);
    final lines = await file.readAsLines();
    String? connection;
    String source = "";
    String target = "";
    final command = StringBuffer();
    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      } else if (line.trimLeft().startsWith(_connection)) {
        final start = line.indexOf(_connection);
        connection = line.substring(start + _connection.length).trim();
      } else if (line.trimLeft().startsWith(_target)) {
        source = command.toString();
        command.clear();
      } else if (line.trimLeft().startsWith("--")) {
        continue;
      } else if (source.isEmpty || target.isEmpty) {
        command.writeln(line);
      }
    }
    target = command.toString();

    out.writeln("connection: $connection");
    out.writeln("source: $source");
    out.writeln("target: $target");

    try {
      await connect(argResults, url: connection);
      final res = await select(source);
      await close();

      final commands = <String>[];
      for (final row in res) {
        var command = target;
        final tables = row.keys;
        for (final table in tables) {
          final columns = row[table]!.keys;
          for (final column in columns) {
            final variable = "\$$table.$column";
            var value = row[table]![column];
            if (value is String)
              value = "'${value.replaceAll('\'', '`')}'";
            else if (value is List)
              value = "ARRAY [${value.map((e) => "'$e'").join(",")}]";
            else if (value is DateTime)
              value = "'${value.toIso8601String()}'";
            else
              value = value.toString();
            command = command.replaceAll(variable, value);
            //out.writeln("$variable = $value");
          }
        }
        commands.add(command);
      }

      await connect(argResults);
      for (final command in commands) {
        out.writeln(command);
        await select(command);
      }

      out.writeln("OK: ${commands.length} commands executed.");

      await close();
    } catch (ex) {
      out.writeln(ex.toString());
    } finally {
      await close();
    }
    return out.toString();
  }
}

// eof

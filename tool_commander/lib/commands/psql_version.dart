import "dart:async";

import "package:tool_commander/commands/command.dart";
import "package:tool_commander/commands/psql_mixin.dart";

class PsqlVersion extends VegaCommand with Psql {
  PsqlVersion() {
    addPostgresOptions(argParser);
    argParser.addFlag("dump", help: "Dump connection");
  }

  @override
  String get name => "version";

  @override
  String get description => "Execute sql";

  @override
  List<String> get aliases => ["v"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final out = StringBuffer();
    final dump = argResults?["dump"] as bool;
    if (dump) {
      out.writeln("host: ${getHost(argResults)}");
      out.writeln("port: ${getPort(argResults)}");
      out.writeln("database: ${getDatabase(argResults)}");
      out.writeln("username: ${getUsername(argResults)}");
      out.writeln("password: ***");
    }
    try {
      await connect(argResults);
      final version = (await select("SELECT VERSION() AS sql"))[0][""]?["sql"];
      out.writeln(version);
    } catch (ex) {
      out.writeln(ex.toString());
    } finally {
      await close();
    }
    return out.toString();
  }
}

// eof

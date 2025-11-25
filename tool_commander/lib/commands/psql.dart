import "package:tool_commander/commands/command.dart";
import "package:tool_commander/commands/psql_exec.dart";
import "package:tool_commander/commands/psql_pump.dart";
import "package:tool_commander/commands/psql_version.dart";

class PsqlCommand extends VegaCommand {
  PsqlCommand() {
    addSubcommand(PsqlVersion());
    addSubcommand(PsqlExec());
    addSubcommand(PsqlPump());
  }

  @override
  String get name => "psql";

  @override
  String get description => "Execute PostreSQL command";
}

// eof

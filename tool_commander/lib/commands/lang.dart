import "package:tool_commander/commands/lang_export.dart";

import "command.dart";
import "lang_google_sheet.dart";
import "lang_redis.dart";
import "lang_remove_unused.dart";
import "lang_source.dart";

class LangCommand extends VegaCommand {
  LangCommand() {
    addSubcommand(LangGoogleSheet());
    addSubcommand(LangRemoveUnused());
    addSubcommand(LangSource());
    addSubcommand(LangExport());
    addSubcommand(LangRedis());
  }

  @override
  String get name => "lang";

  @override
  String get description => "Language command";
}

// eof

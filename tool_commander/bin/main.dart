import "dart:io";

import "package:args/command_runner.dart";
import "package:path/path.dart" as path;
import "package:tool_commander/commands/bcrypt.dart";
import "package:tool_commander/commands/blur_hash.dart";
import "package:tool_commander/commands/cryptex.dart";
import "package:tool_commander/commands/lang.dart";
import "package:tool_commander/commands/psql.dart";
import "package:tool_commander/commands/version.dart";
import "package:tool_commander/dot_env.dart";
import "package:tool_commander/dot_env/dot_env.dart";

void main(List<String> args) async {
  final runner = CommandRunner<String>("vtc", "Vega tool commander")
    ..addCommand(VersionCommand())
    ..addCommand(PsqlCommand())
    ..addCommand(LangCommand())
    ..addCommand(BCryptCommand())
    ..addCommand(CryptexCommand())
    ..addCommand(BlurHashCommand());

  final envPath = Directory.current.path;
  final envFile = path.join(envPath, ".env");
  if (File(envFile).existsSync()) {
    dotenv = await DotEnv.load(fileName: envFile);
    //runner.argParser.addOption("env", help: "Environment file");
    //runner.argParser.addOption("postgres_host", help: "Postgres host");
  } else {
    print("Warning: environment file not found: $envFile");
  }

  final output = await runner.run(args);
  print(output);
}

// eof

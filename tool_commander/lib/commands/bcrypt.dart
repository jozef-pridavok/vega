import "bcrypt_encode.dart";
import "command.dart";

class BCryptCommand extends VegaCommand {
  BCryptCommand() {
    addSubcommand(BCryptEncode());
  }

  @override
  String get name => "bcrypt";

  @override
  String get description => "BCrypt command";
}

// eof

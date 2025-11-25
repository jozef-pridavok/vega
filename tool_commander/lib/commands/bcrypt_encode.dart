import "dart:async";

import "package:bcrypt/bcrypt.dart";

import "command.dart";

class BCryptEncode extends VegaCommand {
  BCryptEncode() {
    argParser.addOption("plain", help: "Plain password", mandatory: true);
    argParser.addOption("salt", help: "Salt");
  }

  @override
  String get name => "encode";

  @override
  String get description => "BCrypt encoder";

  @override
  List<String> get aliases => ["e"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final plain = argResults?["plain"];
    final salt = argResults?["salt"];
    final passwordSalt = salt ?? BCrypt.gensalt();
    final passwordHash = BCrypt.hashpw(plain, passwordSalt);
    return "salt = $passwordSalt\nhash = $passwordHash";
  }
}

// eof

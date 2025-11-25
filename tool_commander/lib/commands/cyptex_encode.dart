import "dart:async";

import "package:core_dart/core_algorithm.dart";

import "command.dart";

class CryptexEncode extends VegaCommand {
  CryptexEncode() {
    argParser.addOption("key", help: "Cryptex secret key", mandatory: true);
    argParser.addOption("plain", help: "Plain text", mandatory: true);
  }

  @override
  String get name => "encode";

  @override
  String get description => "Cryptex encoder";

  @override
  List<String> get aliases => ["e"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final key = argResults?["key"];
    final plain = argResults?["plain"];
    final cryptex = SimpleCipher(key);
    return cryptex.encrypt(plain);
  }
}

// eof

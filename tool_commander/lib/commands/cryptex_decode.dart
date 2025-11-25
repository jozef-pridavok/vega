import "dart:async";

import "package:core_dart/core_algorithm.dart";

import "command.dart";

class CryptexDecode extends VegaCommand {
  CryptexDecode() {
    argParser.addOption("key", help: "Cryptex secret key", mandatory: true);
    argParser.addOption("code", help: "Coded payload", mandatory: true);
  }

  @override
  String get name => "decode";

  @override
  String get description => "Cryptex decoder";

  @override
  List<String> get aliases => ["d"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final key = argResults?["key"];
    final code = argResults?["code"];
    final cryptex = SimpleCipher(key);
    try {
      return cryptex.decrypt(code);
    } catch (e) {
      return "Error: $e";
    }
  }
}

// eof

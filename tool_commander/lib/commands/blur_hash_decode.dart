import "dart:async";

import "command.dart";

class BlurHashDecode extends VegaCommand {
  BlurHashDecode() {
    argParser.addOption("hash", help: "Hash to be decoded", mandatory: true);
  }

  @override
  String get name => "decode";

  @override
  String get description => "BlurHash decoder";

  @override
  List<String> get aliases => ["d"];

  @override
  FutureOr<String>? run() async {
    return "Not implemented yet";
  }
}

// eof

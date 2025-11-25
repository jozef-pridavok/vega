import "dart:async";

import "package:args/command_runner.dart";

abstract class VegaCommand extends Command<String> {
  Future<void> prepare() async {
    //
  }
}

// eof

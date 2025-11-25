import "dart:core" as core;
import "dart:core" hide print;

import "package:core_dart/core_api_server.dart";

class ConsoleLog extends Logging {
  final Configuration config;

  ConsoleLog({required this.config});

  @override
  void print(String message) {
    core.print(message);
  }

  @override
  void error(String message, [StackTrace? stackTrace]) {
    if (config.logError) core.print(message);
  }

  @override
  void warning(String message) {
    if (config.logWarning) core.print(message);
  }

  @override
  void debug(String message) {
    if (config.logDebug) core.print(message);
  }

  @override
  void verbose(String message) {
    if (config.logVerbose) core.print(message);
  }
}

// eof

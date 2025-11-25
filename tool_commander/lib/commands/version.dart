import "dart:async";
import "dart:io";

import "command.dart";

const String appVersion = "1.2.0";

class VersionCommand extends VegaCommand {
  VersionCommand();

  @override
  String get name => "version";

  @override
  String get description => "Version command";

  @override
  List<String> get aliases => ["v"];

  @override
  FutureOr<String>? run() async {
    print(Directory.current.absolute.path);
    return appVersion;
  }
}

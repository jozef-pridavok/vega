import "package:core_flutter/core_dart.dart";

abstract class LogsRepository {
  Future<List<Log>> readAll(int? from, {int max = 25});
}

// eof

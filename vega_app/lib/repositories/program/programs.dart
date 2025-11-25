import "package:core_flutter/core_dart.dart";

abstract class ProgramsRepository {
  Future<Program?> read(String programId, {bool ignoreCache = false});
  Future<void> create(Program program);

  /// returns (userCardId, null) if tag has been applied to the user card
  /// otherwise (null, <String>()) with list of available user cards
  Future<(String?, List<String>?)> applyTag(String tagId, {String? cardId, String? userCardId});
}

// eof

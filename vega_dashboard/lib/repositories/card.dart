import "package:core_flutter/core_dart.dart";

abstract class CardRepository {
  Future<List<Card>> readAll();
}

// eof

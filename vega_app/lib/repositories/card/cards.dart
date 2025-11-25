import "package:core_flutter/core_dart.dart";

abstract class CardsRepository {
  Future<List<Card>?> readAll({Country? country});
  Future<List<Card>?> readTop({int? limit});
  Future<List<Card>?> search(String term);
}

// eof

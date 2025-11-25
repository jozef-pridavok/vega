import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "cards.dart";

class HiveCardsRepository extends CardsRepository {
  static late Box<Card> _box;

  static Future<void> init() async {
    _box = await Hive.openBox("b098ad7e-659c-4bbe-a673-0613e23ca5dc");
  }

  static void clear() {
    _box.clear();
  }

  @override
  Future<List<Card>?> readAll({Country? country}) async =>
      _box.values.where((e) => e.countries?.contains(country) ?? false).toList();

  @override
  Future<List<Card>?> readTop({int? limit}) => throw UnimplementedError();

  @override
  Future<List<Card>?> search(String term) => throw UnimplementedError();
}

// eof

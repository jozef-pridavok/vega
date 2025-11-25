import "package:core_flutter/core_dart.dart";

abstract class ItemRepository {
  Future<List<ProductItemModification>> readModifications(String itemId);
  Future<List<ProductItemOption>> readOptions(String itemId);
}

// eof

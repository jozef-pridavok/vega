import "package:core_flutter/core_dart.dart";

abstract class ProductItemOptionRepository {
  Future<List<ProductItemOption>> readForItem(String productItemId);

  Future<bool> create(ProductItemOption productItemOption);
  Future<bool> update(ProductItemOption productItemOption);

  Future<bool> archive(ProductItemOption productItemOption);
}

// eof

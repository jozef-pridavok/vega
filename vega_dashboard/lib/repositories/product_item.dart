import "package:core_flutter/core_dart.dart";

abstract class ProductItemRepository {
  Future<List<ProductItem>> readAll();
  Future<bool> create(ProductItem productItem, {List<int>? image});
  Future<bool> update(ProductItem productItem, {List<int>? image});

  Future<bool> archive(ProductItem productItem);
  Future<bool> block(ProductItem productItem);
  Future<bool> unblock(ProductItem productItem);

  Future<bool> reorder(List<ProductItem> productItems);
}

// eof

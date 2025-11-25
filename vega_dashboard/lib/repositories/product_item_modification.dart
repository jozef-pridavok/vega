import "package:core_flutter/core_dart.dart";

abstract class ProductItemModificationRepository {
  Future<List<ProductItemModification>> readForItem(String productItemId);

  Future<bool> create(ProductItemModification productItemModification);
  Future<bool> update(ProductItemModification productItemModification);

  Future<bool> reorder(List<ProductItemModification> productItemModifications);

  Future<bool> archive(ProductItemModification productItemModification);
}

// eof

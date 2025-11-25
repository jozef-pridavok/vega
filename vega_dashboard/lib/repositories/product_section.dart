import "package:core_flutter/core_dart.dart";

abstract class ProductSectionRepository {
  Future<List<ProductSection>> readAll();

  Future<bool> create(ProductSection productSection);
  Future<bool> update(ProductSection productSection);

  Future<bool> archive(ProductSection productSection);
  Future<bool> block(ProductSection productSection);
  Future<bool> unblock(ProductSection productSection);

  Future<bool> reorder(List<ProductSection> productSections);
}

// eof

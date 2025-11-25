import "package:core_flutter/core_dart.dart";

enum ProductOfferRepositoryFilter {
  active,
  archived,
}

abstract class ProductOfferRepository {
  Future<List<ProductOffer>> readAll({required ProductOfferRepositoryFilter filter});

  Future<bool> create(ProductOffer productOffer);
  Future<bool> update(ProductOffer productOffer);

  Future<bool> archive(ProductOffer productOffer);
  Future<bool> block(ProductOffer productOffer);
  Future<bool> unblock(ProductOffer productOffer);

  Future<bool> reorder(List<ProductOffer> productOffers);
}

// eof

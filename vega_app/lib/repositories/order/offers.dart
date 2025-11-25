import "package:core_flutter/core_dart.dart";

abstract class OffersRepository {
  Future<List<ProductOffer>> readAll(String clientId);
  Future<ProductOffer?> read(String offerId);
}

// eof

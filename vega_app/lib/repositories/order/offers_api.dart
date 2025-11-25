import "dart:io";

import "package:core_flutter/core_dart.dart";

import "offers.dart";

class ApiOffersRepository implements OffersRepository {
  ApiOffersRepository();

  @override
  Future<List<ProductOffer>> readAll(String clientId) async {
    final res = await ApiClient().get("/v1/offer/client/$clientId");

    switch (res.statusCode) {
      case -1:
        return Future.error(errorConnectionTimeout);
      case HttpStatus.noContent:
        return [];
      // cache is not supported by server
      //case HttpStatus.alreadyReported:
      //  return null;
      case HttpStatus.ok:
        break;
      default:
        return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));
    }

    final json = res.json!;
    final offers = json["offers"] as JsonArray;
    return offers.map((e) => ProductOffer.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<ProductOffer?> read(String offerId) async {
    final res = await ApiClient().get("/v1/offer/$offerId");

    switch (res.statusCode) {
      case -1:
        return Future.error(errorConnectionTimeout);
      case HttpStatus.noContent:
        return null;
      // cache is not supported by server
      //case HttpStatus.alreadyReported:
      //  return null;
      case HttpStatus.ok:
        break;
      default:
        return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));
    }

    final json = res.json;
    return json == null ? null : ProductOffer.fromMap(json, Convention.camel);
  }
}

// eof

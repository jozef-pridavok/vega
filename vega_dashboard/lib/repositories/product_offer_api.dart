import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/product_offer.dart";

extension _ProductOfferRepositoryFilterCode on ProductOfferRepositoryFilter {
  static final _codeMap = {
    ProductOfferRepositoryFilter.active: 1,
    ProductOfferRepositoryFilter.archived: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiProductOfferRepository with LoggerMixin implements ProductOfferRepository {
  @override
  Future<List<ProductOffer>> readAll({required ProductOfferRepositoryFilter filter}) async {
    const path = "/v1/dashboard/product_offer";
    final api = ApiClient();
    final data = <String, dynamic>{"filter": filter.code};
    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;

    return (json["productOffers"] as JsonArray?)?.map((e) => ProductOffer.fromMap(e, Convention.snake)).toList() ?? [];
  }

  @override
  Future<bool> create(ProductOffer productOffer) async {
    final path = "/v1/dashboard/product_offer/${productOffer.offerId}";

    final res = await ApiClient().post(path, data: productOffer.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> update(ProductOffer productOffer) async {
    final path = "/v1/dashboard/product_offer/${productOffer.offerId}";

    final res = await ApiClient().put(path, data: productOffer.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  Future<bool> _patch(ProductOffer productOffer, Map<String, dynamic> data) async {
    final path = "/v1/dashboard/product_offer/${productOffer.offerId}";
    final res = await ApiClient().patch(path, data: data);

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> archive(ProductOffer productOffer) => _patch(productOffer, {"archived": true});

  @override
  Future<bool> block(ProductOffer productOffer) => _patch(productOffer, {"blocked": true});

  @override
  Future<bool> unblock(ProductOffer productOffer) => _patch(productOffer, {"blocked": false});

  @override
  Future<bool> reorder(List<ProductOffer> productOffers) async {
    final path = "/v1/dashboard/product_offer/reorder";
    final data = productOffers.map((offer) => offer.offerId).toList();
    final ApiResponse res = await ApiClient().put(path, data: {"reorder": data});
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == productOffers.length;
  }
}

// eof

import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/product_item_modification.dart";

class ApiProductItemModificationRepository with LoggerMixin implements ProductItemModificationRepository {
  @override
  Future<List<ProductItemModification>> readForItem(String productItemId) async {
    final path = "/v1/dashboard/product_item_modification/$productItemId";
    final api = ApiClient();
    final data = <String, dynamic>{};
    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;

    return (json["productItemModifications"] as JsonArray?)
            ?.map((e) => ProductItemModification.fromMap(e, Convention.snake))
            .toList() ??
        [];
  }

  @override
  Future<bool> create(ProductItemModification productItemModification) async {
    final path = "/v1/dashboard/product_item_modification/${productItemModification.modificationId}";

    final res = await ApiClient().post(path, data: productItemModification.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> update(ProductItemModification productItemModification) async {
    final path = "/v1/dashboard/product_item_modification/${productItemModification.modificationId}";

    final res = await ApiClient().put(path, data: productItemModification.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  Future<bool> _patch(ProductItemModification productItemModification, Map<String, dynamic> data) async {
    final path = "/v1/dashboard/product_item_modification/${productItemModification.modificationId}";
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
  Future<bool> archive(ProductItemModification productItemModification) =>
      _patch(productItemModification, {"archived": true});

  @override
  Future<bool> reorder(List<ProductItemModification> productItemModifications) async {
    final path = "/v1/dashboard/product_item_modification/reorder";
    final data = productItemModifications.map((modification) => modification.modificationId).toList();
    final ApiResponse res = await ApiClient().put(path, data: {"reorder": data});
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == productItemModifications.length;
  }
}

// eof

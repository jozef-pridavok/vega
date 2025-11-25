import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/product_item.dart";

class ApiProductItemRepository with LoggerMixin implements ProductItemRepository {
  @override
  Future<List<ProductItem>> readAll() async {
    final path = "/v1/dashboard/product_item";
    final api = ApiClient();
    final data = <String, dynamic>{};
    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;

    return (json["productItems"] as JsonArray?)?.map((e) => ProductItem.fromMap(e, Convention.snake)).toList() ?? [];
  }

  @override
  Future<bool> create(ProductItem productItem, {List<int>? image}) async {
    final path = "/v1/dashboard/product_item/${productItem.itemId}";
    final api = ApiClient();
    final res = image != null
        ? await api.postMultipart(path, [image, productItem.toMap(Convention.camel)])
        : await api.post(path, data: productItem.toMap(Convention.camel));

    final statusCode = res.statusCode;
    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);
    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> update(ProductItem productItem, {List<int>? image}) async {
    final path = "/v1/dashboard/product_item/${productItem.itemId}";
    final api = ApiClient();

    final res = image != null
        ? await api.putMultipart(path, [image, productItem.toMap(Convention.camel)])
        : await api.put(path, data: productItem.toMap(Convention.camel));

    final statusCode = res.statusCode;
    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);
    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  Future<bool> _patch(ProductItem productItem, Map<String, dynamic> data) async {
    final path = "/v1/dashboard/product_item/${productItem.itemId}";
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
  Future<bool> archive(ProductItem productItem) => _patch(productItem, {"archived": true});

  @override
  Future<bool> block(ProductItem productItem) => _patch(productItem, {"blocked": true});

  @override
  Future<bool> unblock(ProductItem productItem) => _patch(productItem, {"blocked": false});

  @override
  Future<bool> reorder(List<ProductItem> productItems) async {
    final path = "/v1/dashboard/product_item/reorder";
    final data = productItems.map((item) => item.itemId).toList();
    final ApiResponse res = await ApiClient().put(path, data: {"reorder": data});
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == productItems.length;
  }
}

// eof

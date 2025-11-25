import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/product_item_option.dart";

class ApiProductItemOptionRepository with LoggerMixin implements ProductItemOptionRepository {
  @override
  Future<List<ProductItemOption>> readForItem(String productItemId) async {
    final path = "/v1/dashboard/product_item_option/$productItemId";
    final api = ApiClient();
    final data = <String, dynamic>{};
    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;

    return (json["productItemOptions"] as JsonArray?)
            ?.map((e) => ProductItemOption.fromMap(e, Convention.snake))
            .toList() ??
        [];
  }

  @override
  Future<bool> create(ProductItemOption productItemOption) async {
    final path = "/v1/dashboard/product_item_option/${productItemOption.optionId}";

    final res = await ApiClient().post(path, data: productItemOption.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> update(ProductItemOption productItemOption) async {
    final path = "/v1/dashboard/product_item_option/${productItemOption.optionId}";

    final res = await ApiClient().put(path, data: productItemOption.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  Future<bool> _patch(ProductItemOption productItemOption, Map<String, dynamic> data) async {
    final path = "/v1/dashboard/product_item_option/${productItemOption.optionId}";
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
  Future<bool> archive(ProductItemOption productItemOption) => _patch(productItemOption, {"archived": true});
}

// eof

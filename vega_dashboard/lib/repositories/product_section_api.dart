import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/product_section.dart";

class ApiProductSectionRepository with LoggerMixin implements ProductSectionRepository {
  @override
  Future<List<ProductSection>> readAll() async {
    final path = "/v1/dashboard/product_section";
    final api = ApiClient();
    final data = <String, dynamic>{};
    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;

    return (json["productSections"] as JsonArray?)?.map((e) => ProductSection.fromMap(e, Convention.snake)).toList() ??
        [];
  }

  @override
  Future<bool> create(ProductSection productSection) async {
    final path = "/v1/dashboard/product_section/${productSection.sectionId}";

    final res = await ApiClient().post(path, data: productSection.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  @override
  Future<bool> update(ProductSection productSection) async {
    final path = "/v1/dashboard/product_section/${productSection.sectionId}";

    final res = await ApiClient().put(path, data: productSection.toMap(Convention.camel));

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == 1;
  }

  Future<bool> _patch(ProductSection productSection, Map<String, dynamic> data) async {
    final path = "/v1/dashboard/product_section/${productSection.sectionId}";
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
  Future<bool> archive(ProductSection productSection) => _patch(productSection, {"archived": true});

  @override
  Future<bool> block(ProductSection productSection) => _patch(productSection, {"blocked": true});

  @override
  Future<bool> unblock(ProductSection productSection) => _patch(productSection, {"blocked": false});

  @override
  Future<bool> reorder(List<ProductSection> productSections) async {
    final path = "/v1/dashboard/product_section/reorder";
    final data = productSections.map((section) => section.sectionId).toList();
    final ApiResponse res = await ApiClient().put(path, data: {"reorder": data});
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == productSections.length;
  }
}

// eof

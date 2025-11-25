import "dart:io";

import "package:core_flutter/core_dart.dart";

import "item.dart";

class ApiItemRepository implements ItemRepository {
  @override
  Future<List<ProductItemModification>> readModifications(String itemId) async {
    final res = await ApiClient().get("/v1/item/modifications/$itemId");

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
    final modifications = json["modifications"] as JsonArray;
    return modifications.map((e) => ProductItemModification.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<List<ProductItemOption>> readOptions(String itemId) async {
    final res = await ApiClient().get("/v1/item/options/$itemId");

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
    final options = json["options"] as JsonArray;
    return options.map((e) => ProductItemOption.fromMap(e, Convention.camel)).toList();
  }
}

// eof

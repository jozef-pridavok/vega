import "dart:io";

import "package:core_flutter/core_dart.dart";

import "orders.dart";

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository();

  @override
  Future<List<UserOrder>> readAll(String clientId) async {
    final res = await ApiClient().get("/v1/order/current/$clientId");

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
    final orders = json["orders"] as JsonArray;
    return orders.map((e) => UserOrder.fromMap(e, Convention.camel)).toList();
  }
}

// eof

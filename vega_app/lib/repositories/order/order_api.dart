import "dart:io";

import "package:core_flutter/core_dart.dart";

import "order.dart";

class ApiOrderRepository implements OrderRepository {
  @override
  Future<bool> create(UserOrder order) async {
    final res = await ApiClient().post("/v1/order/${order.userCardId}", data: order.toMap(Convention.camel));

    final statusCode = res.statusCode;
    if (statusCode != HttpStatus.created)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json;
    return statusCode == HttpStatus.created && json != null && jsonInt(json, "affected") == 1;
  }
}

// eof

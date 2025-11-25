import "dart:io";

import "package:core_flutter/core_dart.dart";

import "product_order.dart";

extension _ProductOrderRepositoryFilterCode on ProductOrderRepositoryFilter {
  static final _codeMap = {
    ProductOrderRepositoryFilter.active: 1,
    ProductOrderRepositoryFilter.closed: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiProductOrderRepository with LoggerMixin implements ProductOrderRepository {
  @override
  Future<List<UserOrder>> readAll({ProductOrderRepositoryFilter filter = ProductOrderRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/product_order/", params: {"filter": filter.code});
    final json = await res.handleStatusCodeWithJson();
    return (json?["userOrders"] as JsonArray?)?.map((e) => UserOrder.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<List<UserOrderItem>> readAllItems(String productOrderId) async {
    final res = await ApiClient().get("/v1/dashboard/product_order/items/$productOrderId");
    final json = await res.handleStatusCodeWithJson();
    return (json?["userOrderItems"] as JsonArray?)?.map((e) => UserOrderItem.fromMap(e, Convention.camel)).toList() ??
        [];
  }

  Future<bool> _patch(UserOrder userOrder, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/product_order/${userOrder.orderId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> mark(
    UserOrder userOrder,
    ProductOrderStatus newStatus, {
    DateTime? deliveryEstimate,
    String? cancelledReason,
  }) =>
      _patch(userOrder, {
        "status": newStatus.code,
        if (deliveryEstimate != null) "deliveryEstimate": deliveryEstimate.toIso8601String(),
        "cancelledReason": cancelledReason,
      });
}

// eof

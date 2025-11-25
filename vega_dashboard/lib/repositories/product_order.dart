import "package:core_flutter/core_dart.dart";

enum ProductOrderRepositoryFilter {
  active,
  closed,
}

abstract class ProductOrderRepository {
  Future<List<UserOrder>> readAll({ProductOrderRepositoryFilter filter});
  Future<List<UserOrderItem>> readAllItems(String productOrderId);

  //Future<bool> update(ProductOrder productOrder);
  Future<bool> mark(
    UserOrder userOrder,
    ProductOrderStatus newStatus, {
    DateTime? deliveryEstimate,
    String? cancelledReason,
  });
}

// eof

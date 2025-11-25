import "package:collection/collection.dart";

enum ProductOrderStatus {
  created,
  accepted,
  ready,
  inProgress,
  dispatched,
  delivered,
  closed,
  returned,
  cancelled,
}

extension ProductOrderStatusCode on ProductOrderStatus {
  static final _codeMap = {
    ProductOrderStatus.created: 1,
    ProductOrderStatus.accepted: 2,
    ProductOrderStatus.ready: 3,
    ProductOrderStatus.inProgress: 4,
    ProductOrderStatus.dispatched: 5,
    ProductOrderStatus.delivered: 6,
    ProductOrderStatus.closed: 7,
    ProductOrderStatus.returned: 8,
    ProductOrderStatus.cancelled: 9,
  };

  int get code => _codeMap[this]!;

  static final _translationKeyMap = {
    ProductOrderStatus.created: "created",
    ProductOrderStatus.accepted: "accepted",
    ProductOrderStatus.ready: "ready",
    ProductOrderStatus.inProgress: "in_progress",
    ProductOrderStatus.dispatched: "dispatched",
    ProductOrderStatus.delivered: "delivered",
    ProductOrderStatus.closed: "closed",
    ProductOrderStatus.returned: "returned",
    ProductOrderStatus.cancelled: "cancelled",
  };

  String get translationKey => _translationKeyMap[this]!;

  static ProductOrderStatus fromCode(int? code, {ProductOrderStatus def = ProductOrderStatus.created}) =>
      ProductOrderStatus.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static ProductOrderStatus? fromCodeOrNull(int? code) =>
      ProductOrderStatus.values.firstWhereOrNull((r) => r.code == code);
}

// eof

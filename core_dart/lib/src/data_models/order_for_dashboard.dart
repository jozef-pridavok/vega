import "package:core_dart/core_dart.dart";

enum OrderForDashboardKeys {
  orderId,
  orderStatus,
  offerId,
  offerName,
  offerType,
  userId,
  userName,
  cancelledReason,
  cancelledAt,
  totalPrice,
  totalPriceCurrency,
  deliveryType,
  deliveryDate,
  deliverPrice,
  deliverCurrency,
  deliveryAddressLine1,
  deliveryAddressLine2,
  deliveryAddressCity,
  deliveryAddressZip,
  deliveryAddressState,
  deliveryAddressCountry,
  createdAt,
}

class OrderForDashboard {
  String orderId;
  ProductOrderStatus orderStatus;
  String offerId;
  String offerName;
  ProductOfferType offerType;
  String userId;
  String? userName;
  String? cancelledReason;
  DateTime? cancelledAt;
  int? totalPrice;
  Currency? totalPriceCurrency;
  DeliveryType deliveryType;
  DateTime? deliveryDate;
  int? deliverPrice;
  Currency? deliverCurrency;
  String? deliveryAddressLine1;
  String? deliveryAddressLine2;
  String? deliveryAddressCity;
  String? deliveryAddressZip;
  String? deliveryAddressState;
  String? deliveryAddressCountry;
  DateTime createdAt;

  OrderForDashboard({
    required this.orderId,
    required this.orderStatus,
    required this.offerId,
    required this.offerName,
    required this.offerType,
    required this.userId,
    this.userName,
    this.cancelledReason,
    this.cancelledAt,
    this.totalPrice,
    this.totalPriceCurrency,
    required this.deliveryType,
    this.deliveryDate,
    this.deliverPrice,
    this.deliverCurrency,
    this.deliveryAddressLine1,
    this.deliveryAddressLine2,
    this.deliveryAddressCity,
    this.deliveryAddressZip,
    this.deliveryAddressState,
    this.deliveryAddressCountry,
    required this.createdAt,
  });

  static const camel = {
    OrderForDashboardKeys.orderId: "orderId",
    OrderForDashboardKeys.orderStatus: "orderStatus",
    OrderForDashboardKeys.offerId: "offerId",
    OrderForDashboardKeys.offerName: "offerName",
    OrderForDashboardKeys.offerType: "offerType",
    OrderForDashboardKeys.userId: "userId",
    OrderForDashboardKeys.userName: "userName",
    OrderForDashboardKeys.cancelledReason: "cancelledReason",
    OrderForDashboardKeys.cancelledAt: "cancelledAt",
    OrderForDashboardKeys.totalPrice: "totalPrice",
    OrderForDashboardKeys.totalPriceCurrency: "totalPriceCurrency",
    OrderForDashboardKeys.deliveryType: "deliveryType",
    OrderForDashboardKeys.deliveryDate: "deliveryDate",
    OrderForDashboardKeys.deliverPrice: "deliverPrice",
    OrderForDashboardKeys.deliverCurrency: "deliverCurrency",
    OrderForDashboardKeys.deliveryAddressLine1: "deliveryAddressLine1",
    OrderForDashboardKeys.deliveryAddressLine2: "deliveryAddressLine2",
    OrderForDashboardKeys.deliveryAddressCity: "deliveryAddressCity",
    OrderForDashboardKeys.deliveryAddressZip: "deliveryAddressZip",
    OrderForDashboardKeys.deliveryAddressState: "deliveryAddressState",
    OrderForDashboardKeys.deliveryAddressCountry: "deliveryAddressCountry",
    OrderForDashboardKeys.createdAt: "createdAt",
  };

  static const snake = {
    OrderForDashboardKeys.orderId: "order_id",
    OrderForDashboardKeys.orderStatus: "order_status",
    OrderForDashboardKeys.offerId: "offer_id",
    OrderForDashboardKeys.offerName: "offer_name",
    OrderForDashboardKeys.offerType: "offer_type",
    OrderForDashboardKeys.userId: "user_id",
    OrderForDashboardKeys.userName: "user_name",
    OrderForDashboardKeys.cancelledReason: "cancelled_reason",
    OrderForDashboardKeys.cancelledAt: "cancelled_at",
    OrderForDashboardKeys.totalPrice: "total_price",
    OrderForDashboardKeys.totalPriceCurrency: "total_price_currency",
    OrderForDashboardKeys.deliveryType: "delivery_type",
    OrderForDashboardKeys.deliveryDate: "delivery_date",
    OrderForDashboardKeys.deliverPrice: "deliver_price",
    OrderForDashboardKeys.deliverCurrency: "deliver_currency",
    OrderForDashboardKeys.deliveryAddressLine1: "delivery_address_line1",
    OrderForDashboardKeys.deliveryAddressLine2: "delivery_address_line2",
    OrderForDashboardKeys.deliveryAddressCity: "delivery_address_city",
    OrderForDashboardKeys.deliveryAddressZip: "delivery_address_zip",
    OrderForDashboardKeys.deliveryAddressState: "delivery_address_state",
    OrderForDashboardKeys.deliveryAddressCountry: "delivery_address_country",
    OrderForDashboardKeys.createdAt: "created_at",
  };

  static OrderForDashboard fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? OrderForDashboard.camel : OrderForDashboard.snake;
    return OrderForDashboard(
      orderId: map[mapper[OrderForDashboardKeys.orderId]] as String,
      orderStatus: ProductOrderStatusCode.fromCode(map[mapper[OrderForDashboardKeys.orderStatus]]),
      offerId: map[mapper[OrderForDashboardKeys.offerId]] as String,
      offerName: map[mapper[OrderForDashboardKeys.offerName]] as String,
      offerType: ProductOfferTypeCode.fromCode(map[mapper[OrderForDashboardKeys.offerType]]),
      userId: map[mapper[OrderForDashboardKeys.userId]] as String,
      userName: map[mapper[OrderForDashboardKeys.userName]] as String?,
      cancelledReason: map[mapper[OrderForDashboardKeys.cancelledReason]] as String?,
      cancelledAt: tryParseDateTime(map[mapper[OrderForDashboardKeys.cancelledAt]]),
      totalPrice: tryParseInt(map[mapper[OrderForDashboardKeys.totalPrice]])!,
      totalPriceCurrency: CurrencyCode.fromCodeOrNull(map[mapper[OrderForDashboardKeys.totalPriceCurrency]]),
      deliveryType: DeliveryTypeCode.fromCode(map[mapper[OrderForDashboardKeys.deliveryType]]),
      deliveryDate: tryParseDateTime(map[mapper[OrderForDashboardKeys.deliveryDate]]),
      deliverPrice: tryParseInt(map[mapper[OrderForDashboardKeys.deliverPrice]]),
      deliverCurrency: CurrencyCode.fromCodeOrNull(map[mapper[OrderForDashboardKeys.deliverCurrency]]),
      deliveryAddressLine1: map[mapper[OrderForDashboardKeys.deliveryAddressLine1]] as String?,
      deliveryAddressLine2: map[mapper[OrderForDashboardKeys.deliveryAddressLine2]] as String?,
      deliveryAddressCity: map[mapper[OrderForDashboardKeys.deliveryAddressCity]] as String?,
      deliveryAddressZip: map[mapper[OrderForDashboardKeys.deliveryAddressZip]] as String?,
      deliveryAddressState: map[mapper[OrderForDashboardKeys.deliveryAddressState]] as String?,
      deliveryAddressCountry: map[mapper[OrderForDashboardKeys.deliveryAddressCountry]] as String?,
      createdAt: tryParseDateTime(map[mapper[OrderForDashboardKeys.createdAt]])!,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? OrderForDashboard.camel : OrderForDashboard.snake;
    return {
      mapper[OrderForDashboardKeys.orderId]!: orderId,
      mapper[OrderForDashboardKeys.orderStatus]!: orderStatus.code,
      mapper[OrderForDashboardKeys.offerId]!: offerId,
      mapper[OrderForDashboardKeys.offerName]!: offerName,
      mapper[OrderForDashboardKeys.offerType]!: offerType.code,
      mapper[OrderForDashboardKeys.userId]!: userId,
      if (userName != null) mapper[OrderForDashboardKeys.userName]!: userName,
      if (cancelledReason != null) mapper[OrderForDashboardKeys.cancelledReason]!: cancelledReason,
      if (cancelledAt != null) mapper[OrderForDashboardKeys.cancelledAt]!: cancelledAt?.toIso8601String(),
      if (totalPrice != null) mapper[OrderForDashboardKeys.totalPrice]!: totalPrice,
      if (totalPriceCurrency != null) mapper[OrderForDashboardKeys.totalPriceCurrency]!: totalPriceCurrency!.code,
      mapper[OrderForDashboardKeys.deliveryType]!: deliveryType.code,
      if (deliveryDate != null) mapper[OrderForDashboardKeys.deliveryDate]!: deliveryDate!.toIso8601String(),
      if (deliverPrice != null) mapper[OrderForDashboardKeys.deliverPrice]!: deliverPrice,
      if (deliverCurrency != null) mapper[OrderForDashboardKeys.deliverCurrency]!: deliverCurrency!.code,
      if (deliveryAddressLine1 != null) mapper[OrderForDashboardKeys.deliveryAddressLine1]!: deliveryAddressLine1,
      if (deliveryAddressLine2 != null) mapper[OrderForDashboardKeys.deliveryAddressLine2]!: deliveryAddressLine2,
      if (deliveryAddressCity != null) mapper[OrderForDashboardKeys.deliveryAddressCity]!: deliveryAddressCity,
      if (deliveryAddressZip != null) mapper[OrderForDashboardKeys.deliveryAddressZip]!: deliveryAddressZip,
      if (deliveryAddressState != null) mapper[OrderForDashboardKeys.deliveryAddressState]!: deliveryAddressState,
      if (deliveryAddressCountry != null) mapper[OrderForDashboardKeys.deliveryAddressCountry]!: deliveryAddressCountry,
      mapper[OrderForDashboardKeys.createdAt]!: createdAt.toIso8601String(),
    };
  }
}
//
import "../enums/convention.dart";
import "../enums/currency.dart";
import "../enums/delivery_type.dart";
import "../enums/product_order_status.dart";
import "../lang.dart";
import "user.dart";
import "user_order_item.dart";

enum UserOrderKeys {
  orderId,
  offerId,
  clientId,
  locationId,
  userId,
  userCardId,
  notes,
  status,
  cancelledReason,
  cancelledByUserId,
  cancelledAt,
  totalPrice,
  totalPriceCurrency,
  deliveryType,
  deliveryDate,
  deliverPrice,
  deliverCurrency,
  deliveryAddressId,
  meta,
  userNickname,
  createdAt,
  deliveryAddressLine1,
  deliveryAddressLine2,
  deliveryCity,
  items,
}

class UserOrder {
  String orderId;
  String offerId;
  String clientId;
  String? locationId;
  String userId;
  String userCardId;
  String? notes;
  ProductOrderStatus status;
  String? cancelledReason;
  String? cancelledByUserId;
  DateTime? cancelledAt;
  int? totalPrice;
  Currency? totalPriceCurrency;
  DeliveryType deliveryType;
  DateTime? deliveryDate;
  int? deliverPrice;
  Currency? deliverCurrency;
  String? deliveryAddressId;
  JsonObject? meta;
  String userNickname;
  DateTime createdAt;
  String? deliveryAddressLine1;
  String? deliveryAddressLine2;
  String? deliveryCity;
  List<UserOrderItem>? items;

  UserOrder({
    required this.orderId,
    required this.offerId,
    required this.clientId,
    this.locationId,
    required this.userId,
    required this.userCardId,
    this.notes,
    required this.status,
    this.cancelledReason,
    this.cancelledByUserId,
    this.cancelledAt,
    this.totalPrice,
    this.totalPriceCurrency,
    required this.deliveryType,
    this.deliveryDate,
    this.deliverPrice,
    this.deliverCurrency,
    this.deliveryAddressId,
    this.meta,
    required this.userNickname,
    required this.createdAt,
    this.deliveryAddressLine1,
    this.deliveryAddressLine2,
    this.deliveryCity,
    this.items,
  });

  factory UserOrder.createNew(String clientId, String offerId, String userCardId, User user) => UserOrder(
        orderId: uuid(),
        offerId: offerId,
        clientId: clientId,
        userId: user.userId,
        userCardId: userCardId,
        status: ProductOrderStatus.created,
        deliveryType: DeliveryType.delivery,
        userNickname: user.getClientName(clientId) ?? user.nick ?? "",
        createdAt: DateTime.now(),
      );

  UserOrder copyWith({
    String? locationId,
    String? userId,
    String? userCardId,
    String? notes,
    ProductOrderStatus? status,
    String? cancelledReason,
    String? cancelledByUserId,
    DateTime? cancelledAt,
    int? totalPrice,
    DeliveryType? deliveryType,
    DateTime? deliveryDate,
    int? deliverPrice,
    Currency? deliverCurrency,
    String? deliveryAddressId,
    JsonObject? meta,
    String? userNickname,
    DateTime? createdAt,
    String? deliveryAddressLine1,
    String? deliveryAddressLine2,
    String? deliveryCity,
    List<UserOrderItem>? items,
  }) {
    return UserOrder(
      orderId: orderId,
      offerId: offerId,
      clientId: clientId,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      userCardId: userCardId ?? this.userCardId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      cancelledByUserId: cancelledByUserId ?? this.cancelledByUserId,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      totalPrice: totalPrice ?? this.totalPrice,
      totalPriceCurrency: totalPriceCurrency,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliverPrice: deliverPrice ?? this.deliverPrice,
      deliverCurrency: deliverCurrency ?? this.deliverCurrency,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      meta: meta ?? this.meta,
      userNickname: userNickname ?? this.userNickname,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddressLine1: deliveryAddressLine1 ?? this.deliveryAddressLine1,
      deliveryAddressLine2: deliveryAddressLine2 ?? this.deliveryAddressLine2,
      deliveryCity: deliveryCity ?? this.deliveryCity,
      items: items ?? this.items,
    );
  }

  static const camel = {
    UserOrderKeys.orderId: "orderId",
    UserOrderKeys.offerId: "offerId",
    UserOrderKeys.clientId: "clientId",
    UserOrderKeys.locationId: "locationId",
    UserOrderKeys.userId: "userId",
    UserOrderKeys.userCardId: "userCardId",
    UserOrderKeys.notes: "notes",
    UserOrderKeys.status: "status",
    UserOrderKeys.cancelledReason: "cancelledReason",
    UserOrderKeys.cancelledByUserId: "cancelledByUserId",
    UserOrderKeys.cancelledAt: "cancelledAt",
    UserOrderKeys.totalPrice: "totalPrice",
    UserOrderKeys.totalPriceCurrency: "totalPriceCurrency",
    UserOrderKeys.deliveryType: "deliveryType",
    UserOrderKeys.deliveryDate: "deliveryDate",
    UserOrderKeys.deliverPrice: "deliverPrice",
    UserOrderKeys.deliverCurrency: "deliverCurrency",
    UserOrderKeys.deliveryAddressId: "deliveryAddressId",
    UserOrderKeys.meta: "meta",
    UserOrderKeys.userNickname: "userNickname",
    UserOrderKeys.createdAt: "createdAt",
    UserOrderKeys.deliveryAddressLine1: "deliveryAddressLine1",
    UserOrderKeys.deliveryAddressLine2: "deliveryAddressLine2",
    UserOrderKeys.deliveryCity: "deliveryCity",
    UserOrderKeys.items: "items",
  };

  static const snake = {
    UserOrderKeys.orderId: "order_id",
    UserOrderKeys.offerId: "offer_id",
    UserOrderKeys.clientId: "client_id",
    UserOrderKeys.locationId: "location_id",
    UserOrderKeys.userId: "user_id",
    UserOrderKeys.userCardId: "user_card_id",
    UserOrderKeys.notes: "notes",
    UserOrderKeys.status: "status",
    UserOrderKeys.cancelledReason: "cancelled_reason",
    UserOrderKeys.cancelledByUserId: "cancelled_by_user_id",
    UserOrderKeys.cancelledAt: "cancelled_at",
    UserOrderKeys.totalPrice: "total_price",
    UserOrderKeys.totalPriceCurrency: "total_price_currency",
    UserOrderKeys.deliveryType: "delivery_type",
    UserOrderKeys.deliveryDate: "delivery_date",
    UserOrderKeys.deliverPrice: "deliver_price",
    UserOrderKeys.deliverCurrency: "deliver_currency",
    UserOrderKeys.deliveryAddressId: "delivery_address_id",
    UserOrderKeys.meta: "meta",
    UserOrderKeys.userNickname: "user_nickname",
    UserOrderKeys.createdAt: "created_at",
    UserOrderKeys.deliveryAddressLine1: "delivery_address_line_1",
    UserOrderKeys.deliveryAddressLine2: "delivery_address_line_2",
    UserOrderKeys.deliveryCity: "delivery_city",
    UserOrderKeys.items: "items",
  };

  static UserOrder fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserOrder.camel : UserOrder.snake;
    return UserOrder(
      orderId: map[mapper[UserOrderKeys.orderId]] as String,
      offerId: map[mapper[UserOrderKeys.offerId]] as String,
      clientId: map[mapper[UserOrderKeys.clientId]] as String,
      userId: map[mapper[UserOrderKeys.userId]] as String,
      userCardId: map[mapper[UserOrderKeys.userCardId]] as String,
      status: ProductOrderStatusCode.fromCode(map[mapper[UserOrderKeys.status]] as int),
      deliveryType: DeliveryTypeCode.fromCode(map[mapper[UserOrderKeys.deliveryType]] as int),
      locationId: map[mapper[UserOrderKeys.locationId]] as String?,
      notes: map[mapper[UserOrderKeys.notes]] as String?,
      cancelledReason: map[mapper[UserOrderKeys.cancelledReason]] as String?,
      cancelledByUserId: map[mapper[UserOrderKeys.cancelledByUserId]] as String?,
      cancelledAt: map[mapper[UserOrderKeys.cancelledAt]] != null
          ? DateTime.parse(map[mapper[UserOrderKeys.cancelledAt]] as String)
          : null,
      totalPrice: map[mapper[UserOrderKeys.totalPrice]] as int?,
      totalPriceCurrency: CurrencyCode.fromCodeOrNull(map[mapper[UserOrderKeys.totalPriceCurrency]] as String?),
      deliveryDate: tryParseDateTime(map[mapper[UserOrderKeys.deliveryDate]]),
      deliverPrice: map[mapper[UserOrderKeys.deliverPrice]] as int?,
      deliverCurrency: CurrencyCode.fromCode(map[mapper[UserOrderKeys.deliverCurrency]] as String?),
      deliveryAddressId: map[mapper[UserOrderKeys.deliveryAddressId]] as String?,
      meta: map[mapper[UserOrderKeys.meta]] as JsonObject?,
      userNickname: map[mapper[UserOrderKeys.userNickname]] as String,
      createdAt: tryParseDateTime(map[mapper[UserOrderKeys.createdAt]])!,
      deliveryAddressLine1: map[mapper[UserOrderKeys.deliveryAddressLine1]] as String?,
      deliveryAddressLine2: map[mapper[UserOrderKeys.deliveryAddressLine2]] as String?,
      deliveryCity: map[mapper[UserOrderKeys.deliveryCity]] as String?,
      items: (map[mapper[UserOrderKeys.items]] as List<dynamic>?)
          ?.map((e) => UserOrderItem.fromMap(e, convention))
          .toList(),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserOrder.camel : UserOrder.snake;
    return {
      mapper[UserOrderKeys.orderId]!: orderId,
      mapper[UserOrderKeys.offerId]!: offerId,
      mapper[UserOrderKeys.clientId]!: clientId,
      mapper[UserOrderKeys.userId]!: userId,
      mapper[UserOrderKeys.userCardId]!: userCardId,
      mapper[UserOrderKeys.status]!: status.code,
      mapper[UserOrderKeys.deliveryType]!: deliveryType.code,
      if (locationId != null) mapper[UserOrderKeys.locationId]!: locationId,
      if (notes != null) mapper[UserOrderKeys.notes]!: notes,
      if (cancelledReason != null) mapper[UserOrderKeys.cancelledReason]!: cancelledReason,
      if (cancelledByUserId != null) mapper[UserOrderKeys.cancelledByUserId]!: cancelledByUserId,
      if (cancelledAt != null) mapper[UserOrderKeys.cancelledAt]!: cancelledAt!.toIso8601String(),
      if (totalPrice != null) mapper[UserOrderKeys.totalPrice]!: totalPrice,
      if (totalPriceCurrency != null) mapper[UserOrderKeys.totalPriceCurrency]!: totalPriceCurrency!.code,
      if (deliveryDate != null) mapper[UserOrderKeys.deliveryDate]!: deliveryDate!.toIso8601String(),
      if (deliverPrice != null) mapper[UserOrderKeys.deliverPrice]!: deliverPrice,
      if (deliverCurrency != null) mapper[UserOrderKeys.deliverCurrency]!: deliverCurrency!.code,
      if (deliveryAddressId != null) mapper[UserOrderKeys.deliveryAddressId]!: deliveryAddressId,
      if (meta != null) mapper[UserOrderKeys.meta]!: meta,
      mapper[UserOrderKeys.userNickname]!: userNickname,
      mapper[UserOrderKeys.createdAt]!: createdAt.toIso8601String(),
      if (deliveryAddressLine1 != null) mapper[UserOrderKeys.deliveryAddressLine1]!: deliveryAddressLine1,
      if (deliveryAddressLine2 != null) mapper[UserOrderKeys.deliveryAddressLine2]!: deliveryAddressLine2,
      if (deliveryCity != null) mapper[UserOrderKeys.deliveryCity]!: deliveryCity,
      if (items?.isNotEmpty ?? false) mapper[UserOrderKeys.items]!: items!.map((e) => e.toMap(convention)).toList(),
    };
  }

  void updateTotalPrice() {
    totalPriceCurrency = items?.firstOrNull?.currency;
    totalPrice = items?.fold(0, (prev, item) => (prev ?? 0) + (item.qty * item.price)) ?? 0;
  }
}

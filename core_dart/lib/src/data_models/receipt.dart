import "package:core_dart/core_dart.dart";

enum ReceiptKeys {
  receiptId,
  clientId,
  userId,
  userCardId,
  purchasedAtTime,
  purchasedAtPlace,
  totalItems,
  totalPrice,
  totalPriceCurrency,
  items,
  externalId,
}

class Receipt {
  String receiptId;
  String clientId;
  String userId;
  String userCardId;
  DateTime purchasedAtTime;
  String? purchasedAtPlace;
  int totalItems;
  int totalPrice;
  Currency totalPriceCurrency;

  /// {name, unitPrice, quantity, totalPrice, currency}
  List<Map<String, dynamic>> items;
  String? externalId;

  Receipt({
    required this.receiptId,
    required this.clientId,
    required this.userId,
    required this.userCardId,
    required this.purchasedAtTime,
    this.purchasedAtPlace,
    required this.totalItems,
    required this.totalPrice,
    required this.totalPriceCurrency,
    required this.items,
    this.externalId,
  });

  static const camel = {
    ReceiptKeys.receiptId: "receiptId",
    ReceiptKeys.clientId: "clientId",
    ReceiptKeys.userId: "userId",
    ReceiptKeys.userCardId: "userCardId",
    ReceiptKeys.purchasedAtTime: "purchasedAtTime",
    ReceiptKeys.purchasedAtPlace: "purchasedAtPlace",
    ReceiptKeys.totalItems: "totalItems",
    ReceiptKeys.totalPrice: "totalPrice",
    ReceiptKeys.totalPriceCurrency: "totalPriceCurrency",
    ReceiptKeys.items: "items",
    ReceiptKeys.externalId: "externalId",
  };

  static const snake = {
    ReceiptKeys.receiptId: "receipt_id",
    ReceiptKeys.clientId: "client_id",
    ReceiptKeys.userId: "user_id",
    ReceiptKeys.userCardId: "user_card_id",
    ReceiptKeys.purchasedAtTime: "purchased_at_time",
    ReceiptKeys.purchasedAtPlace: "purchased_at_place",
    ReceiptKeys.totalItems: "total_items",
    ReceiptKeys.totalPrice: "total_price",
    ReceiptKeys.totalPriceCurrency: "total_price_currency",
    ReceiptKeys.items: "items",
    ReceiptKeys.externalId: "external_id",
  };

  factory Receipt.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Receipt.camel : Receipt.snake;
    return Receipt(
      receiptId: map[mapper[ReceiptKeys.receiptId]!] as String,
      clientId: map[mapper[ReceiptKeys.clientId]!] as String,
      userId: map[mapper[ReceiptKeys.userId]!] as String,
      userCardId: map[mapper[ReceiptKeys.userCardId]!] as String,
      purchasedAtTime: DateTime.parse(map[mapper[ReceiptKeys.purchasedAtTime]!]),
      purchasedAtPlace: map[mapper[ReceiptKeys.purchasedAtPlace]!] as String?,
      totalItems: map[mapper[ReceiptKeys.totalItems]!] as int,
      totalPrice: map[mapper[ReceiptKeys.totalPrice]!] as int,
      totalPriceCurrency: CurrencyCode.fromCode(map[mapper[ReceiptKeys.totalPriceCurrency]!] as String?),
      items: (map[mapper[ReceiptKeys.items]!] as List<dynamic>).cast<Map<String, dynamic>>(),
      externalId: map[mapper[ReceiptKeys.externalId]!] as String?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Receipt.camel : Receipt.snake;
    return {
      mapper[ReceiptKeys.receiptId]!: receiptId,
      mapper[ReceiptKeys.clientId]!: clientId,
      mapper[ReceiptKeys.userId]!: userId,
      mapper[ReceiptKeys.userCardId]!: userCardId,
      mapper[ReceiptKeys.purchasedAtTime]!: purchasedAtTime.toUtc().toIso8601String(),
      if (purchasedAtPlace != null) mapper[ReceiptKeys.purchasedAtPlace]!: purchasedAtPlace,
      mapper[ReceiptKeys.totalItems]!: totalItems,
      mapper[ReceiptKeys.totalPrice]!: totalPrice,
      mapper[ReceiptKeys.totalPriceCurrency]!: totalPriceCurrency.code,
      mapper[ReceiptKeys.items]!: items,
      if (externalId != null) mapper[ReceiptKeys.externalId]!: externalId,
    };
  }
}

// eof

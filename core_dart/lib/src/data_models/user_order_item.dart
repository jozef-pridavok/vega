import "package:collection/collection.dart";

import "../../core_dart.dart";

enum UserOrderItemKeys {
  itemId,
  name,
  price,
  currency,
  qty,
  qtyPrecision,
  modifications,
  unit,
  photo,
  photoBh,
  updatedAt,
}

class UserOrderItem {
  String itemId;
  String name;
  int price;
  Currency currency;
  int qty;
  int qtyPrecision;
  List<UserOrderModification>? modifications;
  String unit;
  String? photo;
  String? photoBh;
  DateTime? updatedAt;

  // added to cart, just in memory not serialized
  bool confirmed;

  UserOrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.currency,
    required this.qty,
    required this.qtyPrecision,
    this.modifications,
    required this.unit,
    this.photo,
    this.photoBh,
    this.confirmed = false,
    this.updatedAt,
  });

  static const camel = {
    UserOrderItemKeys.itemId: "itemId",
    UserOrderItemKeys.name: "name",
    UserOrderItemKeys.price: "price",
    UserOrderItemKeys.currency: "currency",
    UserOrderItemKeys.qty: "qty",
    UserOrderItemKeys.qtyPrecision: "qtyPrecision",
    UserOrderItemKeys.modifications: "modifications",
    UserOrderItemKeys.unit: "unit",
    UserOrderItemKeys.photo: "photo",
    UserOrderItemKeys.photoBh: "photoBh",
    UserOrderItemKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    UserOrderItemKeys.itemId: "item_id",
    UserOrderItemKeys.name: "name",
    UserOrderItemKeys.price: "price",
    UserOrderItemKeys.currency: "currency",
    UserOrderItemKeys.qty: "qty",
    UserOrderItemKeys.qtyPrecision: "qty_precision",
    UserOrderItemKeys.modifications: "modifications",
    UserOrderItemKeys.unit: "unit",
    UserOrderItemKeys.photo: "photo",
    UserOrderItemKeys.photoBh: "photo_bh",
    UserOrderItemKeys.updatedAt: "updated_at",
  };

  static UserOrderItem fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserOrderItem.camel : UserOrderItem.snake;
    return UserOrderItem(
      itemId: map[mapper[UserOrderItemKeys.itemId]] as String,
      name: map[mapper[UserOrderItemKeys.name]] as String,
      price: map[mapper[UserOrderItemKeys.price]] as int,
      currency: CurrencyCode.fromCode(map[mapper[UserOrderItemKeys.currency]] as String),
      qty: map[mapper[UserOrderItemKeys.qty]] as int,
      qtyPrecision: map[mapper[UserOrderItemKeys.qtyPrecision]] as int,
      modifications: (map[mapper[UserOrderItemKeys.modifications]] as List<dynamic>?)
          ?.map((e) => UserOrderModification.fromMap(e, convention))
          .toList(),
      unit: map[mapper[UserOrderItemKeys.unit]] as String,
      photo: map[mapper[UserOrderItemKeys.photo]] as String?,
      photoBh: map[mapper[UserOrderItemKeys.photoBh]] as String?,
      updatedAt: tryParseDateTime(map[mapper[UserOrderItemKeys.updatedAt]] as String?),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserOrderItem.camel : UserOrderItem.snake;
    return {
      mapper[UserOrderItemKeys.itemId]!: itemId,
      mapper[UserOrderItemKeys.name]!: name,
      mapper[UserOrderItemKeys.price]!: price,
      mapper[UserOrderItemKeys.currency]!: currency.code,
      mapper[UserOrderItemKeys.qty]!: qty,
      mapper[UserOrderItemKeys.qtyPrecision]!: qtyPrecision,
      if (modifications?.isNotEmpty ?? false)
        mapper[UserOrderItemKeys.modifications]!: modifications?.map((e) => e.toMap(convention)).toList(),
      mapper[UserOrderItemKeys.unit]!: unit,
      if (photo != null) mapper[UserOrderItemKeys.photo]!: photo,
      if (photoBh != null) mapper[UserOrderItemKeys.photoBh]!: photoBh,
      if (updatedAt != null) mapper[UserOrderItemKeys.updatedAt]!: updatedAt!.toIso8601String(),
    };
  }

  Price getPrice(ProductItem item, List<ProductItemModification> allModifications) {
    assert(itemId == item.itemId);

    if ((modifications?.isEmpty ?? true) || allModifications.isEmpty) return Price(qty * (item.price ?? 0), currency);

    int totalPrice = qty * (item.price ?? 0);

    for (final myMod in modifications!) {
      final mod = allModifications.firstWhereOrNull((e) => e.modificationId == myMod.modificationId);
      if (mod == null) continue;
      final myModPrice = myMod.getPrice(item, mod);
      assert(myModPrice.currency == currency);
      totalPrice += qty * myModPrice.fraction;
    }

    return Price(totalPrice, currency);
  }
}

// eof


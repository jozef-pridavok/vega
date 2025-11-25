enum CouponOrderKeys {
  itemIds,
  itemPrices,
}

class CouponOrder {
  List<String> itemIds;
  List<int?> itemPrices;

  CouponOrder({
    this.itemIds = const [],
    this.itemPrices = const [],
  });

  static const camel = {
    CouponOrderKeys.itemIds: "itemIds",
    CouponOrderKeys.itemPrices: "itemPrices",
  };

  static CouponOrder fromMap(Map<String, dynamic> map) {
    final mapper = CouponOrder.camel;
    return CouponOrder(
      itemIds: ((map[mapper[CouponOrderKeys.itemIds]] ?? []) as List<dynamic>).cast<String>(),
      itemPrices: ((map[mapper[CouponOrderKeys.itemPrices]] ?? []) as List<dynamic>).cast<int?>(),
    );
  }

  Map<String, dynamic> toMap() {
    final mapper = CouponOrder.camel;
    return {
      mapper[CouponOrderKeys.itemIds]!: itemIds,
      mapper[CouponOrderKeys.itemPrices]!: itemPrices,
    };
  }
}


// eof

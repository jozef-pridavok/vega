import "package:core_flutter/core_dart.dart";

extension ProductItemOptionCopy on ProductItemOption {
  ProductItemOption copyWith({
    String? name,
    ProductItemOptionPricing? pricing,
    int? price,
    String? unit,
    int? rank,
    JsonObject? meta,
  }) {
    return ProductItemOption(
      optionId: optionId,
      modificationId: modificationId,
      name: name ?? this.name,
      pricing: pricing ?? this.pricing,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      rank: rank ?? this.rank,
      blocked: blocked,
      meta: meta ?? this.meta,
    );
  }
}

// eof

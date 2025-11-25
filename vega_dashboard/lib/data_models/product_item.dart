import "package:core_flutter/core_dart.dart";

extension ProductItemCopy on ProductItem {
  ProductItem copyWith({
    String? sectionId,
    String? name,
    String? description,
    int? rank,
    int? price,
    int? qtyPrecision,
    String? unit,
    JsonObject? meta,
  }) {
    return ProductItem(
      itemId: itemId,
      sectionId: sectionId ?? this.sectionId,
      clientId: clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      photo: photo,
      photoBh: photoBh,
      rank: rank ?? this.rank,
      price: price ?? this.price,
      currency: currency,
      qtyPrecision: qtyPrecision ?? this.qtyPrecision,
      unit: unit ?? this.unit,
      blocked: blocked,
      meta: meta ?? this.meta,
    );
  }
}

// eof

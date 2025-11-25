import "package:core_flutter/core_dart.dart";

extension ProductItemModificationCopy on ProductItemModification {
  ProductItemModification copyWith({
    String? name,
    ProductItemModificationType? type,
    bool? mandatory,
    int? max,
    int? rank,
    JsonObject? meta,
  }) {
    return ProductItemModification(
      modificationId: modificationId,
      itemId: itemId,
      clientId: clientId,
      name: name ?? this.name,
      type: type ?? this.type,
      mandatory: mandatory ?? this.mandatory,
      max: max ?? this.max,
      rank: rank ?? this.rank,
      blocked: blocked,
      meta: meta ?? this.meta,
    );
  }
}

// eof

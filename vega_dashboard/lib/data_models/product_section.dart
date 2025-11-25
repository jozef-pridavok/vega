import "package:core_flutter/core_dart.dart";

extension ProductSectionCopy on ProductSection {
  ProductSection copyWith({
    String? name,
    String? description,
    int? rank,
  }) {
    return ProductSection(
      sectionId: sectionId,
      clientId: clientId,
      offerId: offerId,
      name: name ?? this.name,
      description: description ?? this.description,
      rank: rank ?? this.rank,
      blocked: blocked,
      meta: meta,
    );
  }
}

// eof

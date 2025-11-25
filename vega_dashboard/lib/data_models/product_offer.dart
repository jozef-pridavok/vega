import "package:core_flutter/core_dart.dart";

extension ProductOfferCopy on ProductOffer {
  ProductOffer copyWith({
    String? locationId,
    String? name,
    String? description,
    LoyaltyMode? loyaltyMode,
    ProductOfferType? type,
    IntDate? date,
    int? rank,
  }) {
    return ProductOffer(
      offerId: offerId,
      clientId: clientId,
      programId: programId,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      description: description ?? this.description,
      loyaltyMode: loyaltyMode ?? this.loyaltyMode,
      type: type ?? this.type,
      date: date ?? this.date,
      rank: rank ?? this.rank,
      blocked: blocked,
      meta: meta,
    );
  }
}

// eof

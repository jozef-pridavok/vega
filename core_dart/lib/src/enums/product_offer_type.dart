import "package:collection/collection.dart";

enum ProductOfferType {
  regular,
  promoted,
  daily,
  weekly,
  monthly,
  yearly,
  special,
}

extension ProductOfferTypeCode on ProductOfferType {
  static final _codeMap = {
    ProductOfferType.regular: 1,
    ProductOfferType.promoted: 2,
    ProductOfferType.daily: 3,
    ProductOfferType.weekly: 4,
    ProductOfferType.monthly: 5,
    ProductOfferType.yearly: 6,
    ProductOfferType.special: 7,
  };

  int get code => _codeMap[this]!;

  static ProductOfferType fromCode(int? code, {ProductOfferType def = ProductOfferType.regular}) =>
      ProductOfferType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ProductOfferType? fromCodeOrNull(int? code) => ProductOfferType.values.firstWhereOrNull((r) => r.code == code);
}

// eof

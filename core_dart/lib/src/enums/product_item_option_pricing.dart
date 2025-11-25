import "package:collection/collection.dart";

enum ProductItemOptionPricing {
  add,
  overwrite,
}

extension ProductItemOptionPricingCode on ProductItemOptionPricing {
  static final _codeMap = {
    ProductItemOptionPricing.add: 1,
    ProductItemOptionPricing.overwrite: 2,
  };

  int get code => _codeMap[this]!;

  static final _translationKeyMap = {
    ProductItemOptionPricing.add: "add",
    ProductItemOptionPricing.overwrite: "overwrite",
  };

  String get translationKey => _translationKeyMap[this]!;

  static final _symbolMap = {
    ProductItemOptionPricing.add: "+",
    ProductItemOptionPricing.overwrite: "=",
  };

  String get symbol => _symbolMap[this]!;

  static ProductItemOptionPricing fromCode(int? code, {ProductItemOptionPricing def = ProductItemOptionPricing.add}) =>
      ProductItemOptionPricing.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ProductItemOptionPricing? fromCodeOrNull(int? code) =>
      ProductItemOptionPricing.values.firstWhereOrNull((r) => r.code == code);
}

// eof

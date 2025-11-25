import "package:collection/collection.dart";

enum ProductItemModificationType {
  singleSelection,
  multipleSelection,
}

extension ProductItemModificationTypeCode on ProductItemModificationType {
  static final _codeMap = {
    ProductItemModificationType.singleSelection: 1,
    ProductItemModificationType.multipleSelection: 2,
  };

  int get code => _codeMap[this]!;

  static final _translationKeyMap = {
    ProductItemModificationType.singleSelection: "single_selection",
    ProductItemModificationType.multipleSelection: "multiple_selection",
  };

  String get translationKey => _translationKeyMap[this]!;

  static ProductItemModificationType fromCode(int? code,
          {ProductItemModificationType def = ProductItemModificationType.singleSelection}) =>
      ProductItemModificationType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ProductItemModificationType? fromCodeOrNull(int? code) =>
      ProductItemModificationType.values.firstWhereOrNull((r) => r.code == code);
}

// eof

import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension ProductItemModificationTypeTranslation on ProductItemModificationType {
  // TODO: localize core_product_modification_type_single_selection "Jednoduchý výber", "Single selection", "Selección simple"
  // TODO: localize core_product_modification_type_multiple_selection "Viacnásobný výber", "Multiple selection", "Selección múltiple"

  String get localizedName => "core_product_modification_type_$translationKey".tr();
}

// eof

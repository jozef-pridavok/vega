import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension ProductItemOptionPricingTranslation on ProductItemOptionPricing {
  // TODO: localize core_product_option_pricing_add "Pridať ku konečnej cene", "Add to final price", "Añadir al precio final"
  // TODO: localize core_product_option_pricing_overwrite "Prepísať konečnú cenu", "Overwrite final price", "Sobrescribir precio final"

  String get localizedName => "core_product_option_pricing_$translationKey".tr();
}

// eof

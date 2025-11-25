import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension ProductOfferTypeTranslation on ProductOfferType {
  // TODO: localize core_product_offer_type_regular "Bežná", "Regular", "Regular"
  // TODO: localize core_product_offer_type_promoted "Promovaná", "Promoted", "Promoted"
  // TODO: localize core_product_offer_type_daily "Denná", "Daily", "Diario"
  // TODO: localize core_product_offer_type_weekly "Týždenná", "Weekly", "Semanal"
  // TODO: localize core_product_offer_type_monthly "Mesačná", "Monthly", "Mensual"
  // TODO: localize core_product_offer_type_yearly "Ročná", "Yearly", "Anual"
  // TODO: localize core_product_offer_type_special "Špeciálna", "Special", "Especial"

  String get localizedName => "core_product_offer_type_$name".tr();
}

// eof

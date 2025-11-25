import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension DeliveryTypeTranslation on DeliveryType {
  // TODO: localize core_delivery_type_delivery "Doručenie", "Delivery", "Entrega"
  // TODO: localize core_delivery_type_pickup "Osobný odber", "Pickup", "Recogida"
  String get localizedName => "core_delivery_type_$name".tr();
}

// eof

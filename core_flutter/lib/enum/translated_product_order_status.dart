import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension ProductOrderStatusTranslation on ProductOrderStatus {
  // TODO: localize core_product_order_status_created "Vytvorená", "Created", "Creado"
  // TODO: localize core_product_order_status_accepted "Akceptovaná", "Accepted", "Aceptado"
  // TODO: localize core_product_order_status_ready "Pripravená", "Ready", "Listo"
  // TODO: localize core_product_order_status_in_progress "V priebehu", "In progress", "En progreso"
  // TODO: localize core_product_order_status_dispatched "Odoslaná", "Dispatched", "Enviado"
  // TODO: localize core_product_order_status_delivered "Doručená", "Delivered", "Entregado"
  // TODO: localize core_product_order_status_closed "Uzavretá", "Closed", "Cerrado"
  // TODO: localize core_product_order_status_returned "Vrátená", "Returned", "Devuelto"
  // TODO: localize core_product_order_status_cancelled "Zrušená", "Cancelled", "Cancelado"

  String get localizedName => "core_product_order_status_$translationKey".tr();
}

// eof

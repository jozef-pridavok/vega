import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension ReservationDateStatusTranslation on ReservationDateStatus {
  // TODO: localize core_reservation_date_status_available "Čaká na potvrdenie", "Waiting for confirmation", "Esperando confirmación"
  // TODO: localize core_reservation_date_status_confirmed "Potvrdená", "Confirmed", "Confirmado"
  // TODO: localize core_reservation_date_status_completed "Dokončená", "Completed", "Completado"
  // TODO: localize core_reservation_date_status_forfeited "Prepadnutá", "Forfeited", "Perdida"
  String get localizedName => "core_reservation_date_status_$name".tr();
}

// eof

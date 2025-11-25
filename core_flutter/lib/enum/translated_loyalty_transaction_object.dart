import "../core_dart.dart";
import "../extensions/string.dart";

extension LoyaltyTransactionObjectTypeTranslation on LoyaltyTransactionObjectType {
  // TODO: localize core_loyalty_transaction_object_type_order "Objednávka", "Order", "Pedido"
  // TODO: localize core_loyalty_transaction_object_type_reservation "Rezervácia", "Reservation", "Reserva"
  // TODO: localize core_loyalty_transaction_object_type_receipt "Pokladničný bloček", "Receipt", "Recibo"
  // TODO: localize core_loyalty_transaction_object_type_externalReceipt "Externý pokladničný bloček", "External receipt", "Recibo externo"
  // TODO: localize core_loyalty_transaction_object_type_pos "POS", "POS", "POS"
  // TODO: localize core_loyalty_transaction_object_type_qr_tag "QR kód", "QR code", "Código QR"
  // TODO: localize core_loyalty_transaction_object_type_programReward "Odmena", "Reward", "Recompensa"

  String get localizedName => "core_loyalty_transaction_object_type_$translationKey".tr();
}

// eof

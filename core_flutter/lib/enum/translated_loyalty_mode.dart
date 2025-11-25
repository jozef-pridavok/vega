import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension LoyaltyModeTranslation on LoyaltyMode {
  // TODO: localize core_loyalty_mode_none "Žiadny", "None", "Ninguno"
  // TODO: localize core_loyalty_mode_count_reservations "Počítať rezervácie", "Count reservations", "Contar reservas"
  // TODO: localize core_loyalty_mode_count_spent_money "Počítať minuté peniaze", "Count spent money", "Contar dinero gastado"
  // TODO: localize core_loyalty_mode_discount_for_credit_payment "Zľava pri platbe kreditom", "Discount for credit payment", "Descuento por pago con crédito"

  String get localizedName => "core_loyalty_mode_$translationKey".tr();
}

// eof

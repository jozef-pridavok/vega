import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";

extension CouponTypeTranslation on CouponType {
  // TODO: localize core_coupon_type_universal "Všeobecný pre všetkých", "Universal for all", "Universal para todos"
  // TODO: localize core_coupon_type_array "Limitovaný zoznam", "Limited list", "Lista limitada"
  // TODO: localize core_coupon_type_manual "Individuálny", "Individual", "Individual"
  // TODO: localize core_coupon_type_reservation "Na rezerváciu", "For reservation", "Para reserva"
  // TODO: localize core_coupon_type_product "Na objednávku", "For order", "Para ordenar"

  String get localizedName => "core_coupon_type_$name".tr();
}

extension CouponMaskTypeTranslation on CouponCodeMaskType {
  // TODO: localize core_coupon_code_mask_type_only_upper_case "Iba veľké písmená", "Only uppercase letters", "Solamente letras mayúsculas"
  // TODO: localize core_coupon_code_mask_type_only_letters "Iba písmená", "Only letters", "Solamente letras"
  // TODO: localize core_coupon_code_mask_type_only_digits "Iba čísla", "Only digits", "Solamente dígitos"
  // TODO: localize core_coupon_code_mask_type_letters_and_digits "Písmená a čísla", "Letters and digits", "Letras e dígitos"

  String get localizedName => "core_coupon_code_mask_type_$translationKey".tr();
}

// eof

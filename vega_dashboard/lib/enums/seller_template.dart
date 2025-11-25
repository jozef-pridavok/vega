import "package:core_flutter/core_flutter.dart";

enum SellerTemplate {
  barber,
}

extension SellerTemplateValue on SellerTemplate {
  static SellerTemplate fromString(String? templateName, {SellerTemplate def = SellerTemplate.barber}) =>
      SellerTemplate.values.firstWhere((t) => t.name == templateName, orElse: () => def);
}

extension SellerTemplateName on SellerTemplate {

  String get localizedName => "seller_template_$name".tr();
}

// eof

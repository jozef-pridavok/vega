import "package:core_flutter/core_flutter.dart";

enum CouponItemPrice {
  original,
  free,
  percentage,
}

extension CouponItemPriceTranslation on CouponItemPrice {
  /*

  Don't remove this commented code. It's used to keep translations.

  final x = LangKeys.couponItemPriceOriginal.tr();
  final x = LangKeys.couponItemPriceFree.tr();
  final x = LangKeys.couponItemPricePercentage.tr();

  */


  String get localizedName => "coupon_item_price_$name".tr();
}

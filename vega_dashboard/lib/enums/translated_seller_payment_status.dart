import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";

extension SellerPaymentStatusTranslation on SellerPaymentStatus {
  /*

  Don't remove this commented code. It's used to keep translations.

  final x = LangKeys.sellerPaymentStatusWaiting.tr();
  final x = LangKeys.sellerPaymentStatusPending.tr();
  final x = LangKeys.sellerPaymentStatusProcessing.tr();
  final x = LangKeys.sellerPaymentStatusCanceled.tr();
  final x = LangKeys.sellerPaymentStatusFailed.tr();
  final x = LangKeys.sellerPaymentStatusPaid.tr();  
  */

  String get localizedName => "seller_payment_status_$name".tr();
}

// eof

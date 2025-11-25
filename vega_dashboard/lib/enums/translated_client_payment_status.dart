import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";

extension ClientPaymentStatusTranslation on ClientPaymentStatus {
  /*

  Don't remove this commented code. It's used to keep translations.

  final x = LangKeys.clientPaymentStatusPending.tr();
  final x = LangKeys.clientPaymentStatusProcessing.tr();
  final x = LangKeys.clientPaymentStatusCanceled.tr();
  final x = LangKeys.clientPaymentStatusFailed.tr();
  final x = LangKeys.clientPaymentStatusPaid.tr();    

  */


  String get localizedName => "client_payment_status_$name".tr();
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";

extension UserRoleName on UserRole {
  /*

  Don't remove this commented code. It's used to keep translations.

  final x = LangKeys.userRoleMinimal.tr();
  final x = LangKeys.userRoleAdmin.tr();
  final x = LangKeys.userRoleUser.tr();
  final x = LangKeys.userRoleSeller.tr();
  final x = LangKeys.userRolePos.tr();
  final x = LangKeys.userRoleOrder.tr();
  final x = LangKeys.userRoleDelivery.tr();
  final x = LangKeys.userRoleReservation.tr();
  final x = LangKeys.userRoleReport.tr();
  final x = LangKeys.userRoleMarketing.tr();
  final x = LangKeys.userRoleSupport.tr();
  final x = LangKeys.userRoleOwner.tr();
  final x = LangKeys.userRoleDevelopment.tr();
  final x = LangKeys.userRoleFinance.tr();
  final x = LangKeys.userRoleSuperadmin.tr();

  */

  String get localizedName => "user_role_$name".tr();
}

// eof

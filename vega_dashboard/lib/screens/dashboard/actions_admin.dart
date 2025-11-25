import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/dashboard.dart";
import "../../strings.dart";
import "../client_payments/screen_payments.dart";
import "action.dart";

extension DashboardActions on DashboardSucceed {
  List<DashboardAction> getActionsForAdmin(BuildContext context, WidgetRef ref) {
    final locale = context.locale.languageCode;
    List<DashboardAction> actions = [];

    final license = dashboard.license;

    //final simulatedDay = DateTime.now().toLocal().add(const Duration(days: -1));
    //final license = actions.isEmpty ? IntDate.fromDate(simulatedDay) : null;

    if (license != null) {
      final now = DateTime.now().toLocal().endOfDay;
      final validTo = license.toDate().toLocal().endOfDay;
      final days = validTo.difference(now).inDays;
      if (days < 0)
        actions.add(
          DashboardAction(
            type: DashboardActionType.system,
            title: LangKeys.menuClientPayments.tr(),
            label: LangKeys.dashboardLabelLicenseExpired.tr(),
            icon: AtomIcons.shieldOff,
            actions: [
              MoleculeAction.negative(
                title: LangKeys.buttonPay.tr(),
                onTap: () => context.push(const ClientPaymentsScreen()),
              ),
            ],
          ),
        );
      else if (days <= 7)
        actions.add(
          DashboardAction(
            type: DashboardActionType.system,
            title: LangKeys.menuClientPayments.tr(),
            label: LangKeys.dashboardLabelLicenseExpires.plural(days),
            icon: AtomIcons.shield,
            actions: [
              MoleculeAction.primary(
                title: LangKeys.buttonPay.tr(),
                onTap: () => context.push(const ClientPaymentsScreen()),
              ),
            ],
          ),
        );
      else if (days < 14)
        actions.add(
          DashboardAction(
            type: DashboardActionType.system,
            title: LangKeys.menuClientPayments.tr(),
            label: LangKeys.dashboardLabelLicenseValidTo.tr(args: [formatDate(locale, validTo)!]),
            icon: AtomIcons.shield,
            actions: [
              MoleculeAction.positive(
                title: LangKeys.buttonPay.tr(),
                onTap: () => context.push(const ClientPaymentsScreen()),
              ),
            ],
          ),
        );
    }

    return actions;
  }
}

// eof

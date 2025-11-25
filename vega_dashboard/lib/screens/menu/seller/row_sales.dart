import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../seller_payments/screen_payments.dart";

class SalesRow extends ConsumerStatefulWidget {
  const SalesRow({super.key});

  @override
  createState() => _SalesRowState();
}

class _SalesRowState extends ConsumerState<SalesRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "trending_up",
      title: LangKeys.menuSales.tr(),
      label: LangKeys.menuDashboardDescription.tr(),
      onAction: () => context.replace(const SellerPaymentsScreen(showDrawer: true)),
    );
  }
}

// eof

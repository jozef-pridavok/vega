import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../client_payments/screen_payments.dart";

class PaymentsRow extends ConsumerStatefulWidget {
  const PaymentsRow({super.key});

  @override
  createState() => _ClientPaymentsRowState();
}

class _ClientPaymentsRowState extends ConsumerState<PaymentsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.about,
      title: LangKeys.menuClientPayments.tr(),
      label: LangKeys.menuClientPaymentsDescription.tr(),
      onAction: () => context.replace(const ClientPaymentsScreen(showDrawer: true)),
    );
  }
}

// eof

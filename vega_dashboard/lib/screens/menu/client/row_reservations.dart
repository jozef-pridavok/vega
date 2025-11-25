import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../reservations/screen_reservations.dart";

class ReservationsRow extends ConsumerStatefulWidget {
  const ReservationsRow({super.key});

  @override
  createState() => _ReservationsRowState();
}

class _ReservationsRowState extends ConsumerState<ReservationsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.reservation,
      title: LangKeys.menuReservations.tr(),
      label: LangKeys.menuClientCardsDescriptions.tr(),
      onAction: () => context.replace(const ReservationsScreen(showDrawer: true)),
    );
  }
}

// eof

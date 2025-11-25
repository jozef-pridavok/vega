import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";
import "../dashboard/dashboard.dart";

class DashboardRow extends ConsumerStatefulWidget {
  const DashboardRow({super.key});

  @override
  createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<DashboardRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.dashboard,
      title: LangKeys.menuDashboard.tr(),
      label: LangKeys.menuDashboardDescription.tr(),
      onAction: () => context.replace(const DashboardScreen(showDrawer: true)),
    );
  }
}

// eof

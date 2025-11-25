import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";
import "screen_system.dart";

class SystemRow extends ConsumerStatefulWidget {
  const SystemRow({super.key});

  @override
  createState() => _SystemRowState();
}

class _SystemRowState extends ConsumerState<SystemRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "settings",
      title: LangKeys.menuSystem.tr(),
      actionIcon: AtomIcons.itemDetail,
      label: LangKeys.menuSystemDescription.tr(),
      onAction: () => context.replaceInDrawer(const SystemScreen()),
    );
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/strings.dart";

import "../../states/providers.dart";
import "screen_theme.dart";

class ThemeRow extends ConsumerStatefulWidget {
  const ThemeRow({super.key});

  @override
  createState() => _ThemeRowState();
}

class _ThemeRowState extends ConsumerState<ThemeRow> {
  @override
  Widget build(BuildContext context) {
    ref.watch(userUpdateLogic);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final theme = user.theme;
    return MoleculeItemBasic(
      icon: AtomIcons.eye,
      title: LangKeys.menuTheme.tr(),
      actionIcon: AtomIcons.chevronRight,
      label: theme.localizedName,
      onAction: () => context.replaceInDrawer(const ThemeScreen()),
    );
  }
}

// eof

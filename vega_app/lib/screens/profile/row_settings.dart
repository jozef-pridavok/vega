import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/profile/screen_settings.dart";
import "package:vega_app/strings.dart";

class SettingsRow extends ConsumerStatefulWidget {
  const SettingsRow({super.key});

  @override
  createState() => _SettingsRowState();
}

class _SettingsRowState extends ConsumerState<SettingsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "settings",
      title: LangKeys.menuSettings.tr(),
      label: LangKeys.menuSettingsDescription.tr(),
      actionIcon: AtomIcons.chevronRight,
      onAction: () => context.push(const SettingsScreen()),
    );
  }
}

// eof

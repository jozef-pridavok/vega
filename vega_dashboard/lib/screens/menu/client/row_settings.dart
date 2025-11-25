import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../states/providers.dart";
import "../../../strings.dart";
import "../../client_settings/screen_settings.dart";

class SettingsRow extends ConsumerStatefulWidget {
  const SettingsRow({super.key});

  @override
  createState() => _ClientSettingsRowState();
}

class _ClientSettingsRowState extends ConsumerState<SettingsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "settings",
      title: LangKeys.menuClientSettings.tr(),
      label: LangKeys.menuClientSettingsDescription.tr(),
      onAction: () {
        ref.read(clientSettingsLogic.notifier).load();
        context.replace(const ClientSettingsScreen(showDrawer: true));
      },
    );
  }
}

// eof

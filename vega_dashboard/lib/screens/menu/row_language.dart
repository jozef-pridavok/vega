import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "screen_language.dart";

class LanguageRow extends ConsumerStatefulWidget {
  const LanguageRow({super.key});

  @override
  createState() => _LanguageRowState();
}

class _LanguageRowState extends ConsumerState<LanguageRow> {
  @override
  Widget build(BuildContext context) {
    ref.watch(userUpdateLogic);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final languageCode = user.language ?? Localizations.localeOf(context).languageCode;
    return MoleculeItemBasic(
      icon: "globe",
      title: LangKeys.menuLanguage.tr(),
      actionIcon: "chevron_right",
      label: "core_language_$languageCode".tr(),
      onAction: () => context.replaceInDrawer(const LanguageScreen()),
    );
  }
}

// eof

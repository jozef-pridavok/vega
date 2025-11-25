import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../developer/screen_translations.dart";

class TranslationsRow extends ConsumerStatefulWidget {
  const TranslationsRow({super.key});

  @override
  createState() => _TranslationState();
}

class _TranslationState extends ConsumerState<TranslationsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.globe,
      title: "Translations",
      label: "Manage translations",
      onAction: () => context.replace(const TranslationsScreen(showDrawer: true)),
    );
  }
}

// eof

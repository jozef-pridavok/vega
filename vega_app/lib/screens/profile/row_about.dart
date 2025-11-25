import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/profile/screen_about.dart";
import "package:vega_app/strings.dart";

class AboutRow extends ConsumerStatefulWidget {
  const AboutRow({super.key});

  @override
  createState() => _AboutRowState();
}

class _AboutRowState extends ConsumerState<AboutRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.about,
      title: LangKeys.menuAbout.tr(),
      actionIcon: AtomIcons.chevronRight,
      label: LangKeys.menuAbout.tr(),
      onAction: () => context.push(const AboutScreen()),
    );
  }
}

// eof

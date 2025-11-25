import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../programs/screen_list.dart";

class ProgramsRow extends ConsumerStatefulWidget {
  const ProgramsRow({super.key});

  @override
  createState() => _ProgramsRowState();
}

class _ProgramsRowState extends ConsumerState<ProgramsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.program,
      title: LangKeys.menuClientPrograms.tr(),
      label: LangKeys.menuClientProgramsDescription.tr(),
      onAction: () => context.replace(const ProgramsScreen(showDrawer: true)),
    );
  }
}

// eof

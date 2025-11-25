import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";
import "../leaflets/screen_leaflets_list.dart";

class LeafletsRow extends ConsumerStatefulWidget {
  const LeafletsRow({super.key});

  @override
  createState() => _LeafletsState();
}

class _LeafletsState extends ConsumerState<LeafletsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.leaflet,
      title: LangKeys.menuLeaflets.tr(),
      label: LangKeys.menuLeafletsDescription.tr(),
      onAction: () => context.replace(const LeafletScreenList(showDrawer: true)),
    );
  }
}

// eof

import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../client_cards/screen_list.dart";

class ClientCardsRow extends ConsumerStatefulWidget {
  const ClientCardsRow({super.key});

  @override
  createState() => _ClientCardsRowState();
}

class _ClientCardsRowState extends ConsumerState<ClientCardsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.card,
      title: LangKeys.menuClientCards.tr(),
      label: LangKeys.menuClientCardsDescription.tr(),
      onAction: () => context.replace(const ClientCardsScreen(showDrawer: true)),
    );
  }
}

// eof

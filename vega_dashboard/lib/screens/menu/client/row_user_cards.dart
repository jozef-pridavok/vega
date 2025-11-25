import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../client_user_cards/screen_user_cards.dart";

class UserCardsRow extends ConsumerStatefulWidget {
  const UserCardsRow({super.key});

  @override
  createState() => _UserCardsRowState();
}

class _UserCardsRowState extends ConsumerState<UserCardsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.user,
      title: LangKeys.menuClientUserCards.tr(),
      label: LangKeys.menuClientUserCardsDescription.tr(),
      onAction: () => context.replace(const ClientUserCardsScreen(showDrawer: true)),
    );
  }
}

// eof

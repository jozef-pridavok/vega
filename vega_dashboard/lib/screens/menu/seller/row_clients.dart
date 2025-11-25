import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../seller_clients/screen_list.dart";

class ClientsRow extends ConsumerWidget {
  const ClientsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeItemBasic(
      icon: AtomIcons.users,
      title: LangKeys.menuSellerClients.tr(),
      label: LangKeys.menuSellerClientsDescription.tr(),
      onAction: () => context.replace(const SellerClientsScreen(showDrawer: true)),
    );
  }
}

// eof

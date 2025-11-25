import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../client_users/screen_list.dart";
import "../../screen_app.dart";

class UsersRow extends ConsumerWidget {
  const UsersRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client?;
    return MoleculeItemBasic(
      icon: AtomIcons.users,
      title: LangKeys.menuClientUsers.tr(),
      label: LangKeys.menuClientUsersDescription.tr(),
      //onAction: clientId != null ? () => context.replace(ClientUsersScreen(client)) : null,
      onAction: () => client != null
          ? context.replace(ClientUsersScreen(client, showDrawer: true))
          : toastError(ref, LangKeys.operationFailed.tr()),
    );
  }
}

// eof

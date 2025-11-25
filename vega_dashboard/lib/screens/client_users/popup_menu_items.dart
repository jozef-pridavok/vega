import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "screen_edit.dart";

class ClientUsersMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, User user, Client client) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () => context.popPush(EditClientUserScreen(client: client, user: user)),
      ),
    );
  }

  static PopupMenuItem changePassword(BuildContext context, WidgetRef ref, User user, Client client) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationChangePassword.tr(),
        icon: AtomIcons.lock,
        onAction: () => context.popPush(EditClientUserScreen(client: client, user: user)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, User user) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: user.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: user.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () async {
          context.pop();
          if (user.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            await ref.read(clientUserPatchLogic.notifier).unblock(user);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            await ref.read(clientUserPatchLogic.notifier).block(user);
          }
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, User user) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          _askToArchive(context, ref, user);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, User user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [user.userId]).text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.buttonArchive.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(clientUserPatchLogic.notifier).archive(user);
    }
  }
}

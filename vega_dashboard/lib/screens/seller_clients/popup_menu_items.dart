import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../client_users/screen_list.dart";
import "../dialog.dart";
import "screen_edit.dart";

class SellerClientMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Client client) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () => context.popPush(EditSellerClientScreen(client: client)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, Client client) {
    final isBlocked = client.blocked;
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: isBlocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: isBlocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () async {
          context.pop();
          if (isBlocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            await ref.read(sellerClientPatchLogic.notifier).unblock(client);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            await ref.read(sellerClientPatchLogic.notifier).block(client);
          }
        },
      ),
    );
  }

  static PopupMenuItem manageUsers(BuildContext context, WidgetRef ref, Client client) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationManageUsers.tr(),
        icon: AtomIcons.users,
        onAction: () => context.popPush(ClientUsersScreen(client)),
      ),
    );
  }

  static PopupMenuItem setDemoCredit(BuildContext context, WidgetRef ref, Client client) {
    final currency = client.currency;
    final int fraction = switch (currency) {
      Currency.eur => currency.collapse(200),
      Currency.usd => currency.collapse(200),
      Currency.pyg => currency.collapse(1800000),
      Currency.ars => currency.collapse(215000),
      Currency.uyu => currency.collapse(10000),
      _ => 0,
    };
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationSetDemoCredit.tr(args: [currency.formatSymbol(fraction)]),
        icon: AtomIcons.card,
        onAction: () async {
          context.pop();
          showWaitDialog(context, ref, LangKeys.operationSetDemoCreditToast.tr());
          await ref.read(sellerClientPatchLogic.notifier).setDemoCredit(client, fraction);
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Client client) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          _askToArchive(context, ref, client);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Client client) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr(args: [client.name]).text,
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
      await ref.read(sellerClientPatchLogic.notifier).archive(client);
    }
  }
}

// eof

import "package:core_flutter/app/flavors.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/qr_identity.dart";
import "../dialog.dart";
import "screen_edit.dart";

class CardMenuItems {
  static PopupMenuItem editCard(BuildContext context, WidgetRef ref, Card card) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(clientCardEditorLogic.notifier).edit(card);
          context.popPush(EditClientCard());
        },
      ),
    );
  }

  static PopupMenuItem blockCard(BuildContext context, WidgetRef ref, Card card) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: card.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: card.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (card.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(clientCardPatchLogic.notifier).unblock(card);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(clientCardPatchLogic.notifier).block(card);
          }
        },
      ),
    );
  }

  static PopupMenuItem archiveCard(BuildContext context, WidgetRef ref, Card card) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => CardMenuItems._askToArchive(context, ref, card));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Card card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [card.name]).text,
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
      ref.read(clientCardPatchLogic.notifier).archive(card);
    }
  }

  static PopupMenuItem showQrCode(BuildContext context, WidgetRef ref, Card card) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationShowQrCode.tr(),
        icon: AtomIcons.qr,
        onAction: () {
          context.pop();
          final qrCode = F().qrBuilder.generateCardIdentity(card.cardId);
          showIdentityForNewCard(context, ref, qrCode);
        },
      ),
    );
  }
}

// eof

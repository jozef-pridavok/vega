import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "screen_edit.dart";

class RewardMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Program program, Reward reward) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(rewardEditorLogic.notifier).edit(program, reward);
          context.popPush(EditProgramReward());
        },
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, Reward reward) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: reward.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: reward.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () async {
          context.pop();
          if (reward.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(rewardPatchLogic.notifier).unblock(reward);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(rewardPatchLogic.notifier).block(reward);
          }
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Reward reward) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToArchive(context, ref, reward));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Reward reward) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr(args: [reward.name]).text,
        content: LangKeys.dialogArchiveContent.tr(args: [reward.name]).text,
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
      ref.read(rewardPatchLogic.notifier).archive(reward);
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
    }
  }
}

// eof

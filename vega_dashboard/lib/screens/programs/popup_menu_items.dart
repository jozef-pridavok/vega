import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/program_rewards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_cards/screen_user_cards.dart";
import "../dialog.dart";
import "../program_rewards/screen_list.dart";
import "../qr_tags/screen_qr_tags.dart";
import "screen_edit.dart";
import "screen_settings.dart";

class ProgramMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(programEditorLogic.notifier).edit(program);
          context.popPush(EditScreen());
        },
      ),
    );
  }

  static PopupMenuItem showRewards(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationDefineRewards.tr(),
        icon: "star",
        onAction: () => context.popPush(ProgramRewardsScreen(program)),
      ),
    );
  }

  static PopupMenuItem showCards(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationShowCards.tr(),
        icon: AtomIcons.card,
        onAction: () => context.popPush(ClientUserCardsScreen(selectedProgram: program)),
      ),
    );
  }

  static PopupMenuItem showQrTags(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationManageQrTags.tr(),
        icon: AtomIcons.qr,
        onAction: () => context.popPush(QrTagsScreen(program: program)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, Program program) {
    final isBlocked = program.blocked;
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: isBlocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: isBlocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (isBlocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(programPatchLogic.notifier).unblock(program);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(programPatchLogic.notifier).block(program);
          }
        },
      ),
    );
  }

  static PopupMenuItem start(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationStart.tr(),
        icon: AtomIcons.start,
        onAction: () async {
          context.pop();
          final meta = program.meta ?? {};
          if (meta["plural"] == null ||
              ((meta["plural"]["zero"] ?? "") as String).isEmpty ||
              ((meta["plural"]["one"] ?? "") as String).isEmpty ||
              ((meta["plural"]["two"] ?? "") as String).isEmpty ||
              meta["actions"] == null ||
              ((meta["actions"]["addition"] ?? "") as String).isEmpty ||
              ((meta["actions"]["subtraction"] ?? "") as String).isEmpty) {
            return Future.delayed(
                fastRefreshDuration,
                () => _askToFixError(
                      context,
                      ref,
                      LangKeys.dialogProgramMetaNotFilled.tr(),
                      () {
                        ref.read(programEditorLogic.notifier).edit(program);
                        context.popPush(EditScreen());
                        context.push(SettingsScreen(program: program));
                      },
                    ));
          }
          if (program.type == ProgramType.reach) {
            await ref.read(rewardsLogic(program).notifier).load();
            final rewardState = ref.read(rewardsLogic(program));
            if (rewardState is! RewardsSucceed) return context.toastError(LangKeys.toastUnexpectedError.tr());
            if (rewardState.rewards.isEmpty)
              return Future.delayed(
                  fastRefreshDuration,
                  () => _askToFixError(context, ref, LangKeys.toastProgramHasNoReward.tr(),
                      () => context.popPush(ProgramRewardsScreen(program))));
          }
          showWaitDialog(context, ref, LangKeys.toastStarting.tr());
          ref.read(programPatchLogic.notifier).start(program);
        },
      ),
    );
  }

  static void _askToFixError(
    BuildContext context,
    WidgetRef ref,
    String error,
    void Function() onButtonFixTap,
  ) async {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogProgramStartError.tr().text,
        content: error.text,
        actions: [
          MoleculePrimaryButton(
            titleText: LangKeys.buttonCancel.tr(),
            onTap: () => context.pop(false),
          ),
          MoleculePrimaryButton(
            titleText: LangKeys.buttonFixError.tr(),
            onTap: onButtonFixTap,
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
  }

  static PopupMenuItem finish(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationFinish.tr(),
        icon: AtomIcons.stop,
        onAction: () {
          context.pop();
          _askToFinish(context, ref, program);
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Program program) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          _askToArchive(context, ref, program);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Program program) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr(args: [program.name]).text,
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
      ref.read(programPatchLogic.notifier).archive(program);
    }
  }

  static Future<void> _askToFinish(BuildContext context, WidgetRef ref, Program program) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogFinishTitle.tr().h3,
        content: LangKeys.dialogFinishContent.tr(args: [program.name]).text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.operationFinish.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastFinishing.tr());
      ref.read(programPatchLogic.notifier).finish(program);
    }
  }
}

// eof

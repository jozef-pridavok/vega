import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_coupons/screen_user_coupons.dart";
import "../dialog.dart";
import "screen_edit.dart";

class CouponMenuItems {
  static PopupMenuItem showProgress(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationShowProgress.tr(),
        icon: AtomIcons.about,
        onAction: () => context.popPush(ClientUserCouponsScreen(selectedCoupon: coupon)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: coupon.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: coupon.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (coupon.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(couponPatchLogic.notifier).unblock(coupon);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(couponPatchLogic.notifier).block(coupon);
          }
        },
      ),
    );
  }

  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(couponEditorLogic.notifier).edit(coupon);
          context.popPush(ScreenCouponEdit());
        },
      ),
    );
  }

  static PopupMenuItem start(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationStart.tr(),
        icon: AtomIcons.start,
        onAction: () async {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastStarting.tr());
          await ref.read(couponPatchLogic.notifier).start(coupon);
        },
      ),
    );
  }

  static PopupMenuItem finish(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationFinish.tr(),
        icon: AtomIcons.stop,
        onAction: () {
          context.pop();
          _askToFinish(context, ref, coupon);
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Coupon coupon) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          _askToArchive(context, ref, coupon);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Coupon coupon) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [coupon.name]).text,
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
      ref.read(couponPatchLogic.notifier).archive(coupon);
    }
  }

  static Future<void> _askToFinish(BuildContext context, WidgetRef ref, Coupon coupon) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogFinishTitle.tr().h3,
        content: LangKeys.dialogFinishContent.tr(args: [coupon.name]).text,
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
      ref.read(couponPatchLogic.notifier).finish(coupon);
    }
  }
}

// eof

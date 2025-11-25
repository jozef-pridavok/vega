import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_cards/screen_send_message.dart";
import "../dialog.dart";
import "screen_order_view.dart";

class ProductOrderMenuItems {
  static PopupMenuItem viewOrder(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationViewOrder.tr(args: [userOrder.userNickname]),
        icon: AtomIcons.eye,
        onAction: () {
          ref.read(productOrderPatchLogic.notifier).init(userOrder: userOrder);
          context.popPush(ViewProductOrder());
        },
      ),
    );
  }

  static PopupMenuItem sendMessageToUser(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationSendMessageToUser.tr(args: [userOrder.userNickname]),
        icon: AtomIcons.send,
        onAction: () {
          context.popPush(SendMessageScreen(userOrder.userId, userOrder.userNickname));
        },
      ),
    );
  }

  static PopupMenuItem acceptOrder(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationAcceptOrder.tr(args: [userOrder.userNickname]),
        icon: AtomIcons.check,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastAcceptingOrder.tr(args: [userOrder.userNickname]));
          ref.read(productOrderPatchLogic.notifier).accept(userOrder);
        },
      ),
    );
  }

  static PopupMenuItem cancelOrder(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationCancelOrder.tr(args: [userOrder.userNickname]),
        icon: AtomIcons.cancel,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => ProductOrderMenuItems.askToCancelOrder(context, ref, userOrder));
        },
      ),
    );
  }

  static Future<void> askToCancelOrder(BuildContext context, WidgetRef ref, UserOrder userOrder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogCancelOrderTitle.tr().text,
        content: LangKeys.dialogCancelOrderContent.tr(args: [userOrder.userNickname]).text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.buttonConfirm.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastCancellingOrder.tr(args: [userOrder.userNickname]));
      ref.read(productOrderPatchLogic.notifier).cancel(userOrder);
    }
  }

  static PopupMenuItem markAsInProgress(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationMarkOrderInProgress.tr(),
        icon: AtomIcons.clock,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, "toast_marking_order_in_progress".tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.inProgress);
        },
      ),
    );
  }

  static PopupMenuItem markAsReady(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationMarkOrderReady.tr(),
        icon: AtomIcons.check,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderReady.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.ready);
        },
      ),
    );
  }

  static PopupMenuItem markAsDispatched(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationMarkOrderDispatched.tr(),
        // TODO: nastavit spravnu ikonu
        icon: AtomIcons.camera,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDispatched.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.dispatched);
        },
      ),
    );
  }

  static PopupMenuItem markAsDelivered(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationMarkOrderDelivered.tr(),
        // TODO: nastavit spravnu ikonu
        icon: AtomIcons.cloudOff,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDelivered.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.delivered);
        },
      ),
    );
  }

  static PopupMenuItem closeOrder(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationCloseOrder.tr(),
        // TODO: nastavit spravnu ikonu
        icon: AtomIcons.cloudOff,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastClosingOrder.tr());
          ref.read(productOrderPatchLogic.notifier).closeOrder(userOrder);
        },
      ),
    );
  }

  static PopupMenuItem markAsReturned(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationMarkAsReturned.tr(),
        // TODO: nastavit spravnu ikonu
        icon: AtomIcons.xCircle,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => ProductOrderMenuItems.askToMarkAsReturned(context, ref, userOrder));
        },
      ),
    );
  }

  static Future<void> askToMarkAsReturned(BuildContext context, WidgetRef ref, UserOrder userOrder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogMarkOrderReturnedTitle.tr().text,
        content: LangKeys.dialogMarkOrderReturnedContent.tr().text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.buttonConfirm.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastMarkingOrderAsReturned.tr());
      ref.read(productOrderPatchLogic.notifier).returnOrder(userOrder);
    }
  }
}

// eof

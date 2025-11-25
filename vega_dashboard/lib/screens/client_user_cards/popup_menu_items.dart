import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../client_users/screen_edit_info.dart";
import "../dialog.dart";
import "screen_send_message.dart";
import "screen_transactions.dart";

class UserCardMenuItems {
  static PopupMenuItem showTransactions(BuildContext context, WidgetRef ref, UserCard userCard) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationViewTransactions.tr(),
        icon: AtomIcons.about,
        onAction: () => context.popPush(ClientUserCardTransactionsScreen(userCard)),
      ),
    );
  }

  static PopupMenuItem sendMessage(BuildContext context, WidgetRef ref, UserCard userCard) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationSendMessage.tr(),
        icon: AtomIcons.send,
        onAction: () => context.popPush(SendMessageScreen(userCard.userId, userCard.userName ?? "")),
      ),
    );
  }

  static PopupMenuItem book(BuildContext context, WidgetRef ref, UserCard userCard, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelBooking.tr(),
        icon: "calendar",
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastConfirmingBooking.tr());
          ref.read(reservationDatesLogic.notifier).book(term, userCard.userId);
        },
      ),
    );
  }

  static PopupMenuItem openUserData(BuildContext context, WidgetRef ref, UserCard userCard) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEditUserData.tr(),
        icon: AtomIcons.edit,
        onAction: () => context.popPush(EditClientUserInfoScreen(userId: userCard.userId)),
      ),
    );
  }
}

// eof

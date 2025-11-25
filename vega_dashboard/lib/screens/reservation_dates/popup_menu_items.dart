import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/dialog.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_cards/screen_send_message.dart";
import "../client_users/screen_edit_info.dart";
import "screen_book.dart";
import "screen_date_add.dart";

class DateMenuItems {
  static PopupMenuItem book(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelBooking.tr(),
        icon: "user_plus",
        onAction: () {
          ref.read(clientUserCardsLogic.notifier).loadPeriod(null);
          context.popPush(BookScreen(term));
        },
      ),
    );
  }

  static PopupMenuItem confirm(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelConfirmBooking.tr(),
        icon: "user_check",
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastConfirmingBooking.tr());
          ref.read(reservationDatesLogic.notifier).confirm(term);
        },
      ),
    );
  }

  static PopupMenuItem cancel(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelCancelBooking.tr(),
        icon: "user_x",
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastCancelingBooking.tr());
          ref.read(reservationDatesLogic.notifier).cancel(term);
        },
      ),
    );
  }

  static PopupMenuItem add(BuildContext context, WidgetRef ref, List<ReservationSlot> slots, DateTime date) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelAddBooking.tr(),
        icon: AtomIcons.plusCircle,
        onAction: () {
          context.pop();
          //ref.read(reservationDateEditorLogic.notifier).init(slots);
          context.push(
            AddReservationDate(createMany: false, dateOfReservation: date, newDateForSlot: slots.firstOrNull),
          );
        },
      ),
    );
  }

  static PopupMenuItem delete(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelDeleteBooking.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastDeletingBooking.tr());
          ref.read(reservationDatesLogic.notifier).delete(term);
        },
      ),
    );
  }

  static PopupMenuItem sendMessage(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.labelSendMessage.tr(),
        icon: AtomIcons.send,
        onAction: () {
          context.popPush(SendMessageScreen(term.reservedByUserId!, term.userNick ?? ""));
        },
      ),
    );
  }

  static PopupMenuItem openUserData(BuildContext context, WidgetRef ref, ReservationDate term) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEditUserData.tr(),
        icon: AtomIcons.edit,
        onAction: () => context.popPush(EditClientUserInfoScreen(userId: term.reservedByUserId!)),
      ),
    );
  }
}

// eof

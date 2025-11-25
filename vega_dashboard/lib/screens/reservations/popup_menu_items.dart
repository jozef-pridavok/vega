import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "../reservation_slots/screen_slots.dart";
import "screen_reservation_edit.dart";

class ReservationMenuItems {
  static PopupMenuItem defineServices(BuildContext context, WidgetRef ref, Reservation reservation) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationDefineServices.tr(),
        icon: AtomIcons.slot,
        onAction: () {
          ref.read(activeReservationsSlotLogic.notifier).load(reservation.reservationId, reload: true);
          context.popPush(ReservationSlotsScreen(reservation));
        },
      ),
    );
  }

  static PopupMenuItem editReservation(BuildContext context, WidgetRef ref, Reservation reservation) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(reservationEditorLogic.notifier).edit(reservation);
          context.popPush(EditReservation());
        },
      ),
    );
  }

  static PopupMenuItem blockReservation(BuildContext context, WidgetRef ref, Reservation reservation) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: reservation.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: reservation.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () async {
          context.pop();
          if (reservation.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(reservationPatchLogic.notifier).unblock(reservation);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(reservationPatchLogic.notifier).block(reservation);
          }
        },
      ),
    );
  }

  static PopupMenuItem archiveReservation(BuildContext context, WidgetRef ref, Reservation reservation) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => ReservationMenuItems._askToArchive(context, ref, reservation));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Reservation reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [reservation.name]).text,
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
      ref.read(reservationPatchLogic.notifier).archive(reservation);
    }
  }
}


// eof

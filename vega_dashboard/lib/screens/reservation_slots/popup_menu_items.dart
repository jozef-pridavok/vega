import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "../reservation_dates/screen_dates.dart";
import "screen_edit_slot.dart";

class SlotMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, ReservationSlot slot, Reservation reservation) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(reservationSlotEditorLogic.notifier).edit(slot);
          context.popPush(EditSlotScreen(reservation));
        },
      ),
    );
  }

  static PopupMenuItem scheduleDates(BuildContext context, WidgetRef ref, ReservationSlot slot) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationScheduleDates.tr(),
        icon: AtomIcons.calendar,
        onAction: () => context.replace(ReservationDatesScreen(pickedSlot: slot)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, ReservationSlot slot) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: slot.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: slot.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () async {
          context.pop();
          if (slot.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(slotPatchLogic.notifier).unblock(slot);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(slotPatchLogic.notifier).block(slot);
          }
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, ReservationSlot slot) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          SlotMenuItems._askToArchive(context, ref, slot);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, ReservationSlot slot) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr(args: [slot.name]).text,
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: LangKeys.buttonCancel.tr().text,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: LangKeys.buttonArchive.tr().text.color(ref.scheme.negative),
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(slotPatchLogic.notifier).archive(slot);
    }
  }
}

// eof

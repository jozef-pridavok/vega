import "package:calendar_view/calendar_view.dart";
import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";

enum ReservationEventLayout { compact, normal, full }

class ReservationEvent extends ConsumerWidget {
  final CalendarEventData event;
  final Color slotColor;
  final ReservationDate date;
  final ReservationEventLayout layout;

  ReservationEvent(this.event, {this.layout = ReservationEventLayout.compact, super.key})
      : slotColor = event.color,
        date = event.event as ReservationDate;

  factory ReservationEvent.compact(CalendarEventData event) =>
      ReservationEvent(event, layout: ReservationEventLayout.compact);

  factory ReservationEvent.normal(CalendarEventData event) =>
      ReservationEvent(event, layout: ReservationEventLayout.normal);

  factory ReservationEvent.full(CalendarEventData event) =>
      ReservationEvent(event, layout: ReservationEventLayout.full);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.languageCode;

    final sign = switch (date.status) {
      ReservationDateStatus.confirmed => "✓",
      ReservationDateStatus.available => date.reservedByUserId != null ? "!" : "",
      ReservationDateStatus.completed => "✓✓",
      ReservationDateStatus.forfeited => "✗",
    };

    final user = (date.userNick?.isNotEmpty ?? true) ? date.userNick : "";
    final dateTimeFrom = formatTime(lang, date.dateTimeFrom.toLocal());
    final dateTimeTo = formatTime(lang, date.dateTimeTo.toLocal());
    final dateTime = "$dateTimeFrom - $dateTimeTo";

    final alpha = (date.status == ReservationDateStatus.available /*&& date.reservedByUserId == null*/) ? 96 : 255;
    final background = slotColor.withAlpha(alpha);
    final foreground = slotColor.dol(1);

    final containerWidget = switch (layout) {
      ReservationEventLayout.compact => Container(
          alignment: Alignment.center,
          decoration: moleculeOutlineDecoration(slotColor, background, 1),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(child: sign.label.alignCenter.color(foreground)),
          ),
        ),
      ReservationEventLayout.normal => Container(
          alignment: Alignment.center,
          decoration: moleculeOutlineDecoration(slotColor, background, 1),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: "$sign $user".micro.alignCenter.maxLine(1).overflowEllipsis.color(foreground),
          ),
        ),
      ReservationEventLayout.full => Container(
          alignment: Alignment.center,
          decoration: moleculeOutlineDecoration(slotColor, background, 1),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                dateTime.micro.maxLine(1).overflowEllipsis.alignCenter.color(foreground),
                const Spacer(),
                "$sign $user".label.maxLine(1).overflowEllipsis.alignCenter.color(foreground),
                const Spacer(),
              ],
            ),
          ),
        ),
    };

    if (date.userNick != null) {
      return Draggable<ReservationDate>(
        data: date,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _buildFeedback(sign),
        child: containerWidget,
      );
    }

    return DragTarget<ReservationDate>(
      builder: (context, candidateItems, rejectedItems) {
        final dragged = candidateItems.firstOrNull;
        final draggedDuration = dragged?.dateTimeTo.difference(dragged.dateTimeFrom).inMinutes;
        final dateDuration = date.dateTimeTo.difference(date.dateTimeFrom).inMinutes;
        final swappable = draggedDuration != null && draggedDuration == dateDuration;
        return Container(
          decoration: moleculeOutlineDecoration(
            slotColor,
            slotColor.withAlpha(swappable ? 255 : 96),
            1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(child: sign.micro.color(slotColor.dol(1))),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        final draggedDuration = details.data.dateTimeTo.difference(details.data.dateTimeFrom).inMinutes;
        final dateDuration = date.dateTimeTo.difference(date.dateTimeFrom).inMinutes;
        if (draggedDuration == dateDuration) {
          _askToSwap(context, ref, date, details.data);
        }
      },
    );
  }

  Widget _buildFeedback(String text) {
    return SizedBox(
      width: 175,
      height: 100,
      child: Container(
        decoration: moleculeOutlineDecoration(
          slotColor,
          slotColor.withAlpha(
            (date.status == ReservationDateStatus.available && date.reservedByUserId == null) ? 96 : 255,
          ),
          1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(child: text.micro.color(slotColor.dol(1))),
        ),
      ),
    );
  }

  static Future<void> _askToSwap(
      BuildContext context, WidgetRef ref, ReservationDate date1, ReservationDate date2) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogSwapTitle.tr().h3,
        content: LangKeys.dialogSwapContent.tr().text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
            color: ref.scheme.negative,
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.operationSwap.tr(),
            color: ref.scheme.primary,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastSwapping.tr());
      ref.read(reservationDatesLogic.notifier).swap(date1, date2);
    }
  }
}

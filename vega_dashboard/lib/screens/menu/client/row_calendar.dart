import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../reservation_dates/screen_dates.dart";

class CalendarRow extends ConsumerStatefulWidget {
  const CalendarRow({super.key});

  @override
  createState() => _CalendarRowState();
}

class _CalendarRowState extends ConsumerState<CalendarRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "calendar",
      title: LangKeys.menuClientReservationCalendar.tr(),
      label: LangKeys.menuClientReservationCalendarDescription.tr(),
      onAction: () {
        //!R ref.read(reservationDatesLogic.notifier).init(null, null);
        context.replace(ReservationDatesScreen(showDrawer: true));
      },
    );
  }
}

// eof

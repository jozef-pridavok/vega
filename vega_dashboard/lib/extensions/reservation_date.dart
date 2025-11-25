import "package:calendar_view/calendar_view.dart";
import "package:core_flutter/core_dart.dart" hide Color;
import "package:flutter/material.dart";

extension ReservationDateEvent on ReservationDate {
  CalendarEventData toEvent(Color? color) {
    final status = this.status == ReservationDateStatus.confirmed ? "✓ " : "";
    final user = userNick != null ? "$userNick\n" : "";
    final dateTimeFrom = this.dateTimeFrom.toLocal();
    final dateTimeTo = this.dateTimeTo.toLocal();
    //final time = "${DateFormat.Hm().format(dateTimeFrom)} - ${DateFormat.Hm().format(dateTimeTo)}";
    return CalendarEventData(
      title: "$status$user",
      //title: time,
      //description: "$status$user",
      date: dateTimeFrom,
      startTime: dateTimeFrom,
      endTime: dateTimeTo,
      color: color ?? Colors.blue,
      event: this,
    );
  }
}

extension ReservationDateEventList on List<ReservationDate> {
  List<CalendarEventData> toEventList(Color? color) => map((rd) => rd.toEvent(color)).toList();
}

// eof

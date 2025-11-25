import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";

extension TimeOfDayToIntDayMinutes on TimeOfDay {
  IntDayMinutes toIntDayMinutes() => IntDayMinutes(hour * 60 + minute);
}

extension IntDayMinutesToTimeOfDayExtension on IntDayMinutes {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: this.value ~/ 60, minute: this.value % 60);
}

// eof

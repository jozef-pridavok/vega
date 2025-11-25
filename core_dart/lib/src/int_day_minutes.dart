import "../core_dart.dart";

/// A simple class to represent a period of the day as an integer value.
/// E.g. 9:30 is represented as 570 (9 * 60 + 30)
class IntDayMinutes {
  final int value;

  const IntDayMinutes(this.value);

  factory IntDayMinutes.now() {
    final now = DateTime.now();
    return IntDayMinutes((now.hour * 60) + now.minute);
  }

  factory IntDayMinutes.fromIntTime(IntTime intTime) => IntDayMinutes((intTime.hour * 60) + intTime.minute);

  int get minute => value % 60;
  int get hour => value ~/ 60;

  IntTime toIntTime() => IntTime((value ~/ 60), (value % 60));

  DateTime toDate() => DateTime(0, 0, 0, hour, minute);

  // display as HH:MM
  @override
  String toString() => "${(value ~/ 60).toString().padLeft(2, "0")}:${(value % 60).toString().padLeft(2, "0")}";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntDayMinutes && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  bool operator >(IntDayMinutes other) => value > other.value;
  bool operator <(IntDayMinutes other) => value < other.value;
  bool operator >=(IntDayMinutes other) => value >= other.value;
  bool operator <=(IntDayMinutes other) => value <= other.value;
}

// eof

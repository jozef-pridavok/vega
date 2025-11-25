import "int_day_minutes.dart";

/// A simple class to represent a time as an integer value but with a more human readable format.
/// This representation is suitable for use in a database, sorting and API calls.
/// E.g. 9:30 is represented as 930
class IntTime {
  final int value;
  final int hour;
  final int minute;

  const IntTime(this.hour, this.minute) : value = (hour * 100) + minute;

  factory IntTime.now() => IntTime.fromDateTime(DateTime.now());

  static fromPeriod(IntDayMinutes period) => IntTime(period.hour, period.minute);

  static fromDateTime(DateTime dateTime) => IntTime(dateTime.hour, dateTime.minute);

  static IntTime? parseInt(int? hhmm) {
    if (hhmm == null || hhmm < 0 || hhmm > 2359) return null;
    int hour = hhmm ~/ 100;
    int minute = hhmm % 100;
    return IntTime(hour, minute);
  }

  static IntTime? parseString(String? hhmm) {
    if (hhmm == null || hhmm.length != 4) return null;
    final val = int.tryParse(hhmm);
    if (val == null) return null;
    return parseInt(val);
  }

  factory IntTime.fromInt(int hhmm) => parseInt(hhmm)!;
  factory IntTime.fromString(String hhmm) => parseString(hhmm)!;

  DateTime toDate() => DateTime(0, 0, 0, hour, minute);

  // display as HH:MM
  @override
  String toString() => "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntTime && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  bool operator >(IntTime other) => value > other.value;
  bool operator <(IntTime other) => value < other.value;
  bool operator >=(IntTime other) => value >= other.value;
  bool operator <=(IntTime other) => value <= other.value;
}

// eof



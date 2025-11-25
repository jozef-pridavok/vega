import "../int_date.dart";

extension DateTimeExtensions on DateTime {
  static DateTime get today => DateTime.now();

  static DateTime get tomorrow => today.nextDay;
  static DateTime get yesterday => today.previousDay;

  static DateTime get startOfToday => today.startOfDay;
  static DateTime get endOfToday => today.endOfDay;

  static DateTime get startOfYesterday => yesterday.startOfDay;
  static DateTime get endOfYesterday => yesterday.endOfDay;

  static DateTime get startOfTomorrow => tomorrow.startOfDay;
  static DateTime get endOfTomorrow => tomorrow.endOfDay;

  static DateTime get startOfThisWeek => today.startOfWeek;
  static DateTime get endOfThisWeek => today.endOfWeek;

  static DateTime get startOfPreviousWeek => today.previousWeek.startOfWeek;
  static DateTime get endOfPreviousWeek => today.previousWeek.endOfWeek;

  static DateTime get startOfNextWeek => today.nextWeek.startOfWeek;
  static DateTime get endOfNextWeek => today.nextWeek.endOfWeek;

  static DateTime get startOfThisMonth => today.startOfMonth;
  static DateTime get endOfThisMonth => today.endOfMonth;

  static DateTime get startOfThisYear => today.startOfYear;
  static DateTime get endOfThisYear => today.endOfYear;

  static DateTime? parseYYYYMMDD(int yyyymmdd) {
    if (yyyymmdd <= 0) return null;
    int year = yyyymmdd ~/ 10000;
    int month = (yyyymmdd % 10000) ~/ 100;
    int day = yyyymmdd % 100;
    return DateTime(year, month, day);
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  bool isSameDay(DateTime other) => startOfDay == other.startOfDay;

  DateTime get nextDay => addDays(1);

  DateTime get previousDay => addDays(-1);

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1).add(Duration(microseconds: -1));

  DateTime get startOfYear => DateTime(year, DateTime.january, 1);

  DateTime get endOfYear {
    DateTime now = DateTime.now();
    return DateTime(now.year, DateTime.december, 31, 23, 59, 59, 999, 999);
  }

  bool get isToday => isSameDay(today);

  bool get isTomorrow => isSameDay(tomorrow);

  bool get isYesterday => isSameDay(yesterday);

  DateTime addDays(int amount, [bool ignoreDaylightSavings = false]) => ignoreDaylightSavings
      ? DateTime(year, month, day + amount, hour, minute, second, millisecond, microsecond)
      : add(Duration(days: amount));

  DateTime addHours(int amount, [bool ignoreDaylightSavings = false]) => ignoreDaylightSavings
      ? DateTime(year, month, day, hour + amount, minute, second, millisecond, microsecond)
      : add(Duration(hours: amount));

  /// The number of days starting from Jan 1 of a year. This is also called the ordinal date.
  ///
  /// Calculated as per https://en.wikipedia.org/wiki/Ordinal_date#Calculation
  //int get dayOfYear => difference(DateTime(year, 1, 1)).inDays.floor() + 1;

  /// The ISO week of the current date. As per ISO 8601 a week starts with Monday and ends on Sunday.
  ///
  /// Calculated as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  //int get week => ((dayOfYear - weekday + 10) / 7).floor();

  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays;

  // ISO week number
  int get weekNumber {
    int daysToAdd = DateTime.thursday - weekday;
    DateTime thursdayDate = daysToAdd > 0 ? add(Duration(days: daysToAdd)) : subtract(Duration(days: daysToAdd.abs()));
    int dayOfYearThursday = thursdayDate.dayOfYear;
    return 1 + ((dayOfYearThursday - 1) / 7).floor();
  }

  DateTime get nextWeek => addDays(7);
  DateTime get previousWeek => addDays(-7);

  /// Return the end of the week for this date. The result will be in the local timezone.
  ///!!!DateTime get endOfWeek => startOfWeek.add(const Duration(days: 7)).endOfDay;

  DateTime get endOfWeek {
    // V Darte je pondelok = 1 a nedeľa = 7
    int daysUntilSunday = DateTime.sunday - weekday;
    // Ak je už nedeľa, tak je to koniec týždňa
    if (daysUntilSunday < 0) {
      daysUntilSunday += 7;
    }
    // Pridaj počet dní do nedele
    return add(Duration(days: daysUntilSunday));
  }

  //DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  DateTime get startOfWeek {
    // V Darte je pondelok = 1 a nedeľa = 7
    int daysSinceMonday = weekday - DateTime.monday;
    // Ak je aktuálny deň pondelok, tak je to začiatok týždňa
    if (daysSinceMonday < 0) {
      daysSinceMonday += 7;
    }
    // Odpočítaj dni od aktuálneho dátumu, aby si dostal pondelok
    return subtract(Duration(days: daysSinceMonday));
  }

  int get yyyymm => (year * 100) + month;

  int get yyyymmdd => IntDate(year, month, day).value;

  bool operator >(DateTime other) => isAfter(other);

  bool operator <(DateTime other) => isBefore(other);

  int get dayMinutes => hour * 60 + minute;

  static int get epoch => DateTime.now().millisecondsSinceEpoch;

  static String get epochString => epoch.toString();
}

// eof

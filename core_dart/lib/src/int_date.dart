/// Simple class for representing dates as integers but with a more human readable format.
/// This representation is suitable for use in a database, sorting and API calls.
/// E.g. Date First of January 2021 would be 202101
class IntMonth {
  final int value;
  final int year;
  final int month;

  const IntMonth(this.year, this.month) : value = (year * 100) + month;

  factory IntMonth.now() {
    final now = DateTime.now();
    return IntMonth(now.year, now.month);
  }

  static IntMonth? parseInt(int? yyyymm) {
    if (yyyymm == null || yyyymm <= 0) return null;
    int year = yyyymm ~/ 100;
    int month = yyyymm % 100;
    return IntMonth(year, month);
  }

  static IntMonth? parseString(String? yyyymm) {
    if (yyyymm == null || yyyymm.length != 6) return null;
    final val = int.tryParse(yyyymm);
    if (val == null) return null;
    return parseInt(val);
  }

  factory IntMonth.fromInt(int yyyymm) => parseInt(yyyymm)!;
  factory IntMonth.fromString(String yyyymm) => parseString(yyyymm)!;
  factory IntMonth.fromDate(DateTime dateTime) => IntMonth(dateTime.year, dateTime.month);

  bool isSameYear(IntMonth other) => year == other.year;

  DateTime toDate() => DateTime(year, month);
  DateTime toLocalDate() => toDate().toLocal();

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntMonth && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  bool operator >(IntMonth other) => value > other.value;
  bool operator <(IntMonth other) => value < other.value;
  bool operator >=(IntMonth other) => value >= other.value;
  bool operator <=(IntMonth other) => value <= other.value;
}

/// Simple class for representing dates as integers but with a more human readable format.
/// This representation is suitable for use in a database, sorting and API calls.
/// E.g. Date First of January 2021 would be 20210101
class IntDate {
  final int value;
  final int year;
  final int month;
  final int day;

  const IntDate(this.year, this.month, this.day) : value = (year * 10000) + (month * 100) + day;

  factory IntDate.now() => IntDate.fromDate(DateTime.now());

  static IntDate? parseInt(int? yyyymmdd) {
    if (yyyymmdd == null || yyyymmdd <= 0) return null;
    int year = yyyymmdd ~/ 10000;
    int month = (yyyymmdd % 10000) ~/ 100;
    int day = yyyymmdd % 100;
    return IntDate(year, month, day);
  }

  static IntDate? parseString(String? yyyymmdd) {
    if (yyyymmdd == null || yyyymmdd.length != 8) return null;
    final val = int.tryParse(yyyymmdd);
    if (val == null) return null;
    return parseInt(val);
  }

  factory IntDate.fromInt(int yyyymmdd) => parseInt(yyyymmdd)!;
  factory IntDate.fromString(String yyyymmdd) => parseString(yyyymmdd)!;
  factory IntDate.fromDate(DateTime dateTime) => IntDate(dateTime.year, dateTime.month, dateTime.day);

  bool isSameMonth(IntDate other) => month == other.month && year == other.year;
  bool isSameYear(IntDate other) => year == other.year;

  DateTime toDate() => DateTime(year, month, day);
  DateTime toLocalDate() => toDate().toLocal();

  IntDate addDays(int days) => IntDate.fromDate(toDate().add(Duration(days: days)));
  IntDate addWeek() => addDays(7);

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntDate && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  bool operator >(IntDate other) => value > other.value;
  bool operator <(IntDate other) => value < other.value;
  bool operator >=(IntDate other) => value >= other.value;
  bool operator <=(IntDate other) => value <= other.value;
}

extension DateTimeToIntDate on DateTime {
  IntDate toIntDate() => IntDate.fromDate(this);
  IntMonth toIntMonth() => IntMonth.fromDate(this);
}

/// Class for composing and decomposing IntDate values to and from a single int.
/// Suitable for use in a database and API calls.
/// E.g. 20210101 to 20210131 would be 2021010120210131
class IntDateRange {
  final IntDate startingAt;
  final IntDate endingAt;

  const IntDateRange(this.startingAt, this.endingAt);

  static const minInt = /*00000*/ 10100000102;
  static BigInt maxInt = BigInt.parse("9999999999999999");
  static const multiplier = 100000000;

  BigInt compose() => (BigInt.from(startingAt.value) * BigInt.from(100000000)) + BigInt.from(endingAt.value);

  String composeForParam() {
    BigInt combinedValue = compose();
    // 16 = number of digits in 2x IntDate
    return combinedValue.toString().padLeft(16, "0");
  }

  static IntDateRange decompose(BigInt range) {
    int startingAtValue = (range ~/ BigInt.from(100000000)).toInt();
    int endingAtValue = (range % BigInt.from(100000000)).toInt();

    IntDate startingAt = IntDate.fromInt(startingAtValue);
    IntDate endingAt = IntDate.fromInt(endingAtValue);

    return IntDateRange(startingAt, endingAt);
  }

  static IntDateRange fromParam(String param) {
    final combinedValue = BigInt.parse(param);
    return decompose(combinedValue);
  }

  static bool isValid(BigInt range) => range >= BigInt.from(minInt) && range <= maxInt;

  @override
  String toString() => "${startingAt.value} - ${endingAt.value}";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntDateRange && other.startingAt == startingAt && other.endingAt == endingAt;
  }

  @override
  int get hashCode => startingAt.hashCode ^ endingAt.hashCode;
}

// eof

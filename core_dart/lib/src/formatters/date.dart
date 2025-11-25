import "package:core_dart/core_dart.dart";
import "package:intl/intl.dart";

String? formatDate(String locale, DateTime? date, {String? fallback}) {
  final formatter = DateFormat.yMd(locale);
  return date != null ? formatter.format(date) : fallback;
}

String? formatTime(String locale, DateTime? date, {String? fallback}) {
  final formatter = DateFormat.Hm(locale);
  return date != null ? formatter.format(date) : fallback;
}

String? formatDateTime(String locale, DateTime? date, {String? fallback, String separator = "-"}) {
  final formatterDate = DateFormat.yMd(locale);
  final formatterTime = DateFormat.Hm(locale);
  return date != null ? "${formatterDate.format(date)} $separator ${formatterTime.format(date)}" : fallback;
}

String? formatIntDate(String locale, IntDate? date, {String? fallback}) {
  return date != null ? formatDate(locale, date.toDate(), fallback: fallback) : fallback;
}

String? formatIntTime(String locale, IntTime? time, {String? fallback}) {
  return time != null ? formatTime(locale, time.toDate(), fallback: fallback) : fallback;
}

String? formatDay(String locale, DateTime? date, {String? fallback}) {
  final formatter = DateFormat.MMMEd(locale);
  return date != null ? formatter.format(date) : fallback;
}

String formatMonth(String locale, int yyyymm) {
  int year = yyyymm ~/ 100;
  int month = yyyymm % 100;
  final formatter = DateFormat.MMMd(locale);
  final date = DateTime(year, month);
  return formatter.format(date);
}

String formatIntMonth(String locale, IntMonth period) {
  final year = period.year;
  final month = period.month;
  final formatter = DateFormat.yM(locale);
  final date = DateTime(year, month);
  return formatter.format(date);
}

String? formatIntDayMinutes(String locale, IntDayMinutes? period, {String? fallback}) {
  return period != null ? formatTime(locale, period.toDate(), fallback: fallback) : fallback;
}

String? formatIntDayMinutesRange(String locale, IntDayMinutes? from, IntDayMinutes? to, {String? fallback}) {
  // return fallback if both are null
  // return "from - to" if both are not null
  // return "from" if only from is not null
  // return "to" if only to is not null
  if (from == null && to == null) return fallback;
  if (from != null && to != null) return "${formatIntDayMinutes(locale, from)} - ${formatIntDayMinutes(locale, to)}";
  if (from != null) return formatIntDayMinutes(locale, from);
  return formatIntDayMinutes(locale, to);
}

// eof

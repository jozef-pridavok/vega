import "package:core_flutter/enum/translated_day.dart";
import "package:intl/intl.dart";

import "../core_dart.dart";

String? formatDateTimePretty(String locale, DateTime? date, {String? fallback}) {
  if (date == null) return fallback;
  final localDate = date.toLocal();
  final timeFormatter = DateFormat.Hm(locale);
  if (date.isToday) {
    return timeFormatter.format(localDate);
  } else if (date.isYesterday) {
    return "${RelativeDay.yesterday.localizedName} ${timeFormatter.format(localDate)}";
  } else if (date.isTomorrow) {
    return "${RelativeDay.tomorrow.localizedName} ${timeFormatter.format(localDate)}";
  } else {
    return DateFormat("dd. MMM yyyy HH:mm", locale).format(localDate);
  }
}

String? formatTimePretty(String locale, DateTime? date, {String? fallback}) {
  if (date == null) return fallback;
  final localDate = date.toLocal();
  final timeFormatter = DateFormat.Hm(locale);
  return timeFormatter.format(localDate);
}

String? formatDateTimeRangePretty(String locale, DateTime from, DateTime to) {
  final localFrom = from.toLocal();
  final localTo = to.toLocal();
  if (localFrom.isSameDay(localTo))
    return "${formatDatePretty(locale, from)}, ${formatTimePretty(locale, from)} - ${formatTimePretty(locale, to)}";
  return "${formatDateTimePretty(locale, from)} - ${formatDateTimePretty(locale, to)}";
}

String? formatDatePretty(String locale, DateTime? date, {String? fallback}) {
  if (date == null) return fallback;
  final localDate = date.toLocal();
  if (date.isToday) {
    return RelativeDay.today.localizedName;
  } else if (date.isYesterday) {
    return RelativeDay.yesterday.localizedName;
  } else if (date.isTomorrow) {
    return RelativeDay.tomorrow.localizedName;
  } else {
    return DateFormat.yMd(locale).format(localDate);
  }
}

// eof

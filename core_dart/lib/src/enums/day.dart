import "package:collection/collection.dart";

enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

final week = [Day.monday, Day.tuesday, Day.wednesday, Day.thursday, Day.friday, Day.saturday, Day.sunday];

extension DayCode on Day {
  static final _dayCodes = {
    Day.monday: "mon",
    Day.tuesday: "tue",
    Day.wednesday: "wed",
    Day.thursday: "thu",
    Day.friday: "fri",
    Day.saturday: "sat",
    Day.sunday: "sun",
  };

  String get code => _dayCodes[this]!;

  static Day fromCode(String? code, {Day def = Day.monday}) =>
      Day.values.firstWhere((r) => r.code == code, orElse: () => def);

  static Day? fromCodeOrNull(String? code) => Day.values.firstWhereOrNull((r) => r.code == code);
}

enum RelativeDay {
  today,
  tomorrow,
  yesterday,
}

extension RelativeDayCode on RelativeDay {
  static final _relativeDayCodes = {
    RelativeDay.today: "today",
    RelativeDay.tomorrow: "tomorrow",
    RelativeDay.yesterday: "yesterday",
  };

  String get code => _relativeDayCodes[this]!;

  static RelativeDay fromCode(String? code, {RelativeDay def = RelativeDay.today}) =>
      RelativeDay.values.firstWhere((r) => r.code == code, orElse: () => def);

  static RelativeDay? fromCodeOrNull(String? code) => RelativeDay.values.firstWhereOrNull((r) => r.code == code);
}


// eof

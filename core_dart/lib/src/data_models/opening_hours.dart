import "../enums/day.dart";

class OpeningHours {
  final Map<Day, String> openingHours;

  bool get isEmpty => openingHours.isEmpty;
  bool get isNotEmpty => openingHours.isNotEmpty;

  const OpeningHours({required this.openingHours});

  void sort() {
    final sortedEntries = openingHours.entries.toList()
      ..sort((a, b) => Day.values.indexOf(a.key) - Day.values.indexOf(b.key));
    openingHours.clear();
    openingHours.addEntries(sortedEntries);
  }

  factory OpeningHours.fromMap(Map<String, dynamic>? map) {
    return OpeningHours(
      openingHours: map?.map((key, value) => MapEntry(DayCode.fromCode(key), value as String)) ?? {},
    );
  }

  static OpeningHours? fromMapOrNull(Map<String, dynamic>? map) {
    if (map == null) return null;
    return OpeningHours.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      ...openingHours.map((key, value) => MapEntry(key.code, value)),
    };
  }
}

// eof


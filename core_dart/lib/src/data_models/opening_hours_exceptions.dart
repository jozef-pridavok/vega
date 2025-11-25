import "package:core_dart/core_dart.dart";

class OpeningHoursExceptions {
  final Map<IntDate, String> exceptions;

  bool get isEmpty => exceptions.isEmpty;
  bool get isNotEmpty => exceptions.isNotEmpty;

  const OpeningHoursExceptions({
    required this.exceptions,
  });

  factory OpeningHoursExceptions.fromMap(Map<String, dynamic>? exceptionsMap) {
    return OpeningHoursExceptions(
      exceptions:
          exceptionsMap != null ? exceptionsMap.map((key, value) => MapEntry(IntDate.fromString(key), value)) : {},
    );
  }

  static fromMapOrNull(Map<String, dynamic>? map) {
    if (map == null) return null;
    return OpeningHoursExceptions.fromMap(map);
  }

  Map<String, dynamic> toMap() =>
      exceptions.map((key, value) => MapEntry(key.toString(), value)).cast<String, dynamic>();

  addException(IntDate date, String exception) => exceptions[date] = exception;

  deleteException(IntDate date) => exceptions.remove(date);
}

// eof

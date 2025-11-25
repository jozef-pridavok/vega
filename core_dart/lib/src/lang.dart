import "package:core_dart/src/int_time.dart";
import "package:uuid/uuid.dart";

import "int_date.dart";
import "int_day_minutes.dart";

const bool kProduct = bool.fromEnvironment("dart.vm.product");

typedef JsonObject = Map<String, dynamic>;
typedef JsonArray = List<dynamic>;

extension JsonObjectExtensions on JsonObject {
  bool get isNotEmpty => this.isNotEmpty;
  bool get isEmpty => this.isEmpty;

  static JsonObject empty() => {};
}

bool? tryParseBool(dynamic val) {
  if (val == null) return null;
  if (val is bool) return val;
  if (val is String) {
    final s = val.trim().toLowerCase();
    if (s == "true")
      return true;
    else if (s == "false")
      return false;
    else
      return null;
  }
  return null;
}

DateTime? tryParseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  if (val is String) {
    final s = val.trim();
    if (s.isNotEmpty) {
      final dt = DateTime.tryParse(s);
      if (dt != null) return dt;
    }
  }
  return null;
}

int? tryParseInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is String) return int.tryParse(val);
  return null;
}

IntDayMinutes? tryParseIntDayMinutes(dynamic val) {
  final period = tryParseInt(val);
  return period != null ? IntDayMinutes(period) : null;
}

IntTime? tryParseIntTime(dynamic val) {
  if (val == null) return null;
  if (val is IntTime) return val;
  if (val is int) return IntTime.fromInt(val);
  if (val is String) return IntTime.parseString(val);
  return null;
}

IntMonth? tryParseIntMonth(dynamic val) {
  if (val == null) return null;
  if (val is IntMonth) return val;
  if (val is int) return IntMonth.fromInt(val);
  if (val is String) return IntMonth.parseString(val);
  return null;
}

IntDate? tryParseIntDate(dynamic val) {
  if (val == null) return null;
  if (val is IntDate) return val;
  if (val is int) return IntDate.fromInt(val);
  if (val is String) return IntDate.parseString(val);
  return null;
}

double? tryParseDouble(dynamic val) {
  if (val == null) return null;
  if (val is double) return val;
  if (val is String) return double.tryParse(val);
  return null;
}

String jsonString(JsonObject json, String attribute) => json[attribute] as String;

num jsonNum(JsonObject json, String attribute) =>
    json[attribute] is int ? json[attribute] as int : (json[attribute] as double).toInt();

int jsonInt(JsonObject json, String attribute) =>
    json[attribute] is int ? json[attribute] as int : (json[attribute] as double).toInt();

int? jsonIntOrNull(JsonObject json, String attribute) => json[attribute] is int
    ? json[attribute] as int
    : (json[attribute] is double ? (json[attribute] as double).toInt() : null);

double jsonDouble(JsonObject json, String attribute) =>
    json[attribute] is double ? json[attribute] as double : (json[attribute] as int).toDouble();

double? jsonDoubleOrNull(JsonObject json, String attribute) => json[attribute] is double
    ? json[attribute] as double
    : (json[attribute] is int ? (json[attribute] as int).toDouble() : null);

T? cast<T>(x) => x is T ? x : null;

T value<T>(T? x, T value) => x ?? value;
String string<T>(T? x, String value) => x != null ? x.toString() : value;

const _uuidGenerator = Uuid();
String uuid() => _uuidGenerator.v4();

// Mainly used for API (Postgres), shared with mobile_api and cron_api
/*
typedef ResultRow = Map<String, Map<String, dynamic>>;
typedef ResultSet = List<ResultRow>;

extension FlatResult on ResultRow {
  Map<String, dynamic> get flatted {
    final Map<String, dynamic> outputMap = {};

    forEach((key, nestedMap) {
      nestedMap.forEach((nestedKey, value) {
        outputMap[nestedKey] = value;
      });
    });

    return outputMap;
  }
}
*/



// eof

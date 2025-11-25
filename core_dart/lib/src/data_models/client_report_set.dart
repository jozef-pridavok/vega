import "package:collection/collection.dart";

import "../../core_dart.dart";

class ClientReportSet {
  final List<(ClientReportType, String, JsonObject?)> reports;

  const ClientReportSet(this.reports);

  Map<String, dynamic> toJson() {
    return {
      "reports": reports.map((report) {
        final data = <String, dynamic>{
          "_type": report.$1.name,
          "_tag": report.$2,
        };
        final params = report.$3;
        if (params != null) {
          params.removeWhere((key, value) => key == "_type" || key == "_tag");
          data.addAll(params);
        }
        return data;
      }).toList(),
    };
  }
}

class ClientReportSetData {
  final List<Map<String, dynamic>> reports;

  ClientReportSetData._(this.reports);

  factory ClientReportSetData.fromJson(JsonObject json) {
    final results = (json["reports"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return ClientReportSetData._(results);
  }

  String display(String tag, String key) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    final value = report?[key];
    if (value == null) return report?["_error"]?.toString() ?? "No data, no error";
    return value?.toString() ?? "No data";
  }

  T? value<T>(String tag, String key) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    return report?[key];
  }

  int? count(String tag) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    return report?["count"] as int?;
  }

  List<int>? array(String tag) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    return (report?["array"] as List<dynamic>?)?.cast<int>();
  }

  List<int>? firstHalfOfArray(String tag) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    final array = (report?["array"] as List<dynamic>?)?.cast<int>();
    return array?.sublist(0, array.length ~/ 2);
  }

  List<int>? secondHalfOfArray(String tag) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    final array = (report?["array"] as List<dynamic>?)?.cast<int>();
    return array?.sublist(array.length ~/ 2);
  }

  List<int>? quarterOfArray(String tag, int quarter) {
    final report = reports.firstWhereOrNull((data) => data["_tag"] == tag);
    final array = (report?["array"] as List<dynamic>?)?.cast<int>();
    if (array == null) return null;
    final quarterLength = array.length ~/ 4;
    return array.sublist(quarterLength * quarter, quarterLength * (quarter + 1));
  }
}

// eof

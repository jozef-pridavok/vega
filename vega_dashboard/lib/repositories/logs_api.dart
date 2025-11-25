import "package:core_flutter/core_dart.dart";

import "logs.dart";

class ApiLogsRepository with LoggerMixin implements LogsRepository {
  @override
  Future<List<Log>> readAll(int? from, {int max = 25}) async {
    final params = <String, dynamic>{"max": max};
    if (from != null) params["from"] = from;

    final res = await ApiClient().get("/v1/dashboard/log", params: params);
    final json = await res.handleStatusCodeWithJson();
    return (json?["logs"] as JsonArray?)?.map((e) => Log.fromMap(e, Convention.camel)).toList() ?? [];
  }
}

// eof

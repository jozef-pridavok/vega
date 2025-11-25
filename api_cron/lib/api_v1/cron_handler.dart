import "dart:async";
import "dart:convert";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

abstract class CronHandler<T> extends ApiServerHandler {
  final String cronName;

  static final Map<String, Completer<void>> _runningJobs = {};

  CronHandler(this.cronName, super.api);

  Future<JsonObject> process(ApiServerContext context, T param);

  Future<JsonObject> execute(ApiServerContext context, T param) async {
    log.verbose("....$cronName: starting");

    while (_runningJobs.containsKey(cronName)) {
      log.verbose(":   $cronName: waiting for previous run to finish");
      await _runningJobs[cronName]!.future;
    }

    _runningJobs[cronName] = Completer<void>();
    try {
      log.verbose(":     $cronName: running");
      final result = await process(context, param);
      log.verbose(":     $cronName: finished with result: $result");
      await recordLastRun(result);
      log.verbose(":     $cronName: recorded last run");
      return result;
    } finally {
      final completer = _runningJobs[cronName];
      _runningJobs.remove(cronName);
      completer?.complete();
      log.verbose(":...$cronName: done");
    }
  }

  Future<void> recordLastRun(JsonObject result) async {
    final lastRun = DateTime.now().toUtc().toIso8601String();
    await api.redis(["SET", CacheKey.shared("cron:$cronName:lastRun").toString(), lastRun]);
    final resultKey = CacheKey.shared("cron:$cronName:result").toString();
    try {
      await api.redis(["SET", resultKey, jsonEncode(result)]);
    } catch (e) {
      await api.redis([
        "SET",
        resultKey,
        jsonEncode({"error": e.toString()})
      ]);
    }
  }
}

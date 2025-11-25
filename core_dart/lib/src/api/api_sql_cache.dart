import "dart:convert";

import "../../core_api_server.dart";
import "../../core_api_server2.dart";
import "../../core_dart.dart";

@Deprecated("Use Cache") // used in cron_api
class SqlCache {
  // singleton

  static final SqlCache _instance = SqlCache._internal();
  factory SqlCache() => _instance;
  SqlCache._internal();

  static final _rootKey = CacheKey.sql("turbo");

  static CacheKey _cacheKey(String key, String query, JsonObject params) =>
      _rootKey.join(key).join(query.hashCode.toString()).join(jsonEncode(params).hashCode.toString());

  static CacheKey _cacheKeyTs(String key, String query, JsonObject params) => _cacheKey(key, query, params).join("ts");
  //static CacheKey _cacheKeySql(String key, String query, JsonObject params) =>
  //    _cacheKey(key, query, params).join("sql");
  //static CacheKey _cacheKeyParams(String key, String query, JsonObject params) =>
  //    _cacheKey(key, query, params).join("params");

  Future<JsonObject?> get(Redis redis, String key, String query, JsonObject params) async {
    final rKey = _cacheKey(key, query, params).toString();
    final json = await redis(["GET", rKey]);
    if (json == null) return Future.value(null);
    return jsonDecode(json);
  }

  Future<int?> getTimestamp(Redis redis, String key, String query, JsonObject params) async {
    final rKey = _cacheKeyTs(key, query, params).toString();
    final timestamp = await redis(["GET", rKey]);
    return timestamp is String ? int.tryParse(timestamp) : cast<int>(timestamp);
  }

  Future<void> set(Redis redis, String key, String query, JsonObject params, JsonObject result,
      {
      // Duration.zero means no expiration
      Duration? expiration,
      int? timestamp}) async {
    final rKey = _cacheKey(key, query, params).toString();
    await redis(["SET", rKey, jsonEncode(result)]);

    final duration = expiration ?? /*(api.config.isDev ? const Duration(minutes: 5) :*/ const Duration(days: 30);

    if (timestamp != null) {
      final rKeyTs = _cacheKeyTs(key, query, params).toString();
      await redis(["SET", rKeyTs, timestamp]);
      if (duration != Duration.zero) await redis(["EXPIRE", rKeyTs, duration.inSeconds]);
    }

    /*
    if (api.config.isDev || api.config.isQa) {
      final rKeySql = _cacheKeySql(key, query, params).toString();
      final rKeyParams = _cacheKeyParams(key, query, params).toString();
      await redis(["SET", rKeySql, query]);
      await redis(["SET", rKeyParams, jsonEncode(params)]);
      if (duration != Duration.zero) {
        await redis(["EXPIRE", rKeySql, duration.inSeconds]);
        await redis(["EXPIRE", rKeyParams, duration.inSeconds]);
      }
    }
    */
    if (duration != Duration.zero) await redis(["EXPIRE", rKey, duration.inSeconds]);
  }

  Future<void> clear(Redis redis, String key) async {
    final allKey = _rootKey.join(key).join("*").toString();
    final res = await redis(["KEYS", allKey]);
    final keysToDelete = (res as List<dynamic>).cast<String>();
    if (keysToDelete.isNotEmpty) await redis(["DEL", ...keysToDelete]);

    /*

  slow version:
  
  var cursor = "0";
  final allKeys = <String>[];
  do {
    final res = await api.redis(["SCAN", cursor, "MATCH", key]);
    cursor = res[0] as String;
    final keys = (res[1] as List<dynamic>).cast<String>();
    if (keys.isNotEmpty) allKeys.addAll(keys);
  } while (cursor != "0");
  if (allKeys.isNotEmpty) await api.redis(["DEL", ...allKeys]);
  */
  }
}


// eof

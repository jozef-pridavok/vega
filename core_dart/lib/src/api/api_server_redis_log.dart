/*
import "dart:async";
import "dart:convert";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_dart.dart";

final _rootKey = CacheKey.log("apiMobile");

final String _keyIndex = _rootKey.join("index").toString();
final String _keyWrites = _rootKey.join("writes").toString();
final String _keyMessage = _rootKey.join("message").toString();
final String _keyDuration = _rootKey.join("duration").toString();
CacheKey _keyEntries(int index) => _rootKey.join("entries").join(index.toString());

extension _LogLevelExpiration on LogLevel {
  // in seconds
  static final _expirationMap = {
    // 15 minutes
    LogLevel.verbose: 15 * 60,
    // 1 hour
    LogLevel.debug: 60 * 60,
    // 7 days
    LogLevel.warning: 7 * 24 * 60 * 60,
    // 1 month
    LogLevel.error: 30 * 24 * 60 * 60,
  };

  int get expiration => _expirationMap[this]!;
}

class RedisLog extends Logging {
  final LogSource logSource;
  final ApiServer api;
  final _lastVerbose = <String>[];

  RedisLog(this.logSource, this.api);

  static final _maxEntries = 20;
  static const int _maxWrites = 1000;
  static const Duration _incrementWritesExpiration = Duration(minutes: 1);

  Future<void> _incrementWrites() async {
    final exists = await api.redis(["EXISTS", _keyWrites]);
    if (exists == 0) {
      await api.redis(["SET", _keyWrites, 1, "EX", _incrementWritesExpiration.inSeconds]);
    } else {
      await api.redis(["INCR", _keyWrites]);
    }
  }

  Future<int> _getNumberOfWrites() async {
    final value = await api.redis(["GET", _keyWrites]);
    if (value == null) return 0;
    return tryParseInt(value) ?? 0;
  }

  // TODO: toto treba lepšie vymyslieť. Teraz ak sa prekročí maxEntries, tak sa začne od 1. Ale to nie je dobre.
  Future<int> _getNextIndex() async {
    const startIndex = 1;
    final exists = await api.redis(["EXISTS", _keyIndex]);
    if (exists == 0) {
      await api.redis(["SET", _keyIndex, startIndex]);
      return startIndex;
    } else {
      final newIndex = tryParseInt(await api.redis(["INCR", _keyIndex]));
      if (newIndex == null) {
        await api.redis(["SET", _keyIndex, startIndex]);
        return startIndex;
      }
      if (newIndex > _maxEntries) {
        await api.redis(["SET", _keyIndex, startIndex]);
        return startIndex;
      }
      return newIndex;
    }
  }

  // TODO: celé previesť do transakcie
  Future<void> _addLog(LogLevel level, String message, [StackTrace? stackTrace]) async {
    try {
      int writes = await _getNumberOfWrites();
      if (writes > _maxWrites) {
        final message = "RedisLog: too many writes. $writes > $_maxWrites in $_incrementWritesExpiration.";
        await api.redis(["SET", _keyMessage, message, "EX", _incrementWritesExpiration.inSeconds]);
        await api.redis(["SET", _keyDuration, _incrementWritesExpiration.inMinutes.toString()]);
        return print(message);
      }
      await _incrementWrites();

      final index = await _getNextIndex();
      final log = Log(level: level, source: logSource, message: message, stackTrace: stackTrace, info: _lastVerbose);
      return await api.redis(
        ["SET", _keyEntries(index).toString(), jsonEncode(log.toMap(Convention.camel)), "EX", level.expiration],
      );
    } catch (e, st) {
      print("RedisLog error: $e\n$st");
    }
  }

  @override
  void error(String message, [StackTrace? stackTrace]) {
    scheduleMicrotask(() async {
      try {
        await _addLog(LogLevel.error, message, stackTrace);
      } catch (e) {
        print("Failed to log error `$message`: $e");
      }
    });
  }

  @override
  void warning(String message) => scheduleMicrotask(() async {
        try {
          await _addLog(LogLevel.warning, message);
        } catch (e) {
          print("Failed to log error `$message`: $e");
        }
      });

  @override
  void debug(String message) {}

  @override
  void verbose(String message) {
    _lastVerbose.add(message);
    if (_lastVerbose.length > 2) _lastVerbose.removeAt(0);
  }

  Future<(List<Log>, int, int)> list(int? from, {int max = 100}) async {
    final currentIndex = tryParseInt(await api.redis(["GET", _keyIndex])) ?? 0;
    int startIndex = from ?? currentIndex;

    List<Log> logList = [];
    int count = 0;
    int last = currentIndex;

    for (int i = startIndex; i > 0 && count < max; i--) {
      final key = _keyEntries(i).toString();
      final exists = await api.redis(["EXISTS", key]);
      if (exists == 1) {
        final logData = await api.redis(["GET", key]);
        if (logData != null) {
          last = i;
          logList.add(Log.fromMap(jsonDecode(logData), Convention.camel));
          count++;
        }
      }
    }

    return (logList, last, currentIndex);
  }
}
*/
// eof

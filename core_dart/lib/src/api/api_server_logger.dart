import "dart:core" as core;
import "dart:core" hide print;

import "../../core_dart.dart";
import "api_server2.dart";

class LogRequest {
  final String method;
  final String path;
  final Map<String, String>? params;
  final Map<String, String>? headers;

  LogRequest({required this.method, required this.path, this.params, this.headers});
}

class _SqlLogEntry {
  final String sql;
  final Map<String, dynamic>? params;
  final DateTime timestamp;

  _SqlLogEntry({required this.sql, this.params}) : timestamp = DateTime.now();
}

class _RequestLogEntry {
  final LogRequest request;
  final DateTime timestamp;

  String get method => request.method;
  String get path => request.path;
  Map<String, String> get params => request.params ?? {};
  Map<String, String> get headers => request.headers ?? {};

  _RequestLogEntry({
    required this.request,
  }) : timestamp = DateTime.now();
}

class _LogData {
  final Object error;
  final Type errorRuntimeType;
  final List<_SqlLogEntry> sqlHistory;
  final List<_RequestLogEntry> requestHistory;

  _LogData({
    required this.error,
    this.sqlHistory = const [],
    this.requestHistory = const [],
  }) : errorRuntimeType = error.runtimeType;
}

/*
enum LogLevel { verbose, debug, warning, error }

extension LogLevelExtension on LogLevel {
  static const Map<LogLevel, String> _names = {
    LogLevel.verbose: "verbose",
    LogLevel.debug: "debug",
    LogLevel.warning: "warning",
    LogLevel.error: "error",
  };
  String get name => _names[this]!;
}
*/

typedef LogPrint = String Function(Object? object);

class ApiLogger<R> {
  final LogLevelConfiguration logConfiguration;
  final _sqlLogs = <String, List<_SqlLogEntry>>{};
  final _requestLogs = <String, List<_RequestLogEntry>>{};

  ApiLogger({required this.logConfiguration});

  void error(String message) {
    if (!logConfiguration[LogLevel.error]) return;
    _log(LogLevel.error, message);
  }

  void warning(String message) {
    if (!logConfiguration[LogLevel.warning]) return;
    _log(LogLevel.warning, message);
  }

  void debug(Object? object, [LogPrint? print]) {
    if (!logConfiguration[LogLevel.debug]) return;
    _log(LogLevel.debug, print?.call(object) ?? object.toString());
  }

  void verbose(Object? object, [LogPrint? print]) {
    if (!logConfiguration[LogLevel.verbose]) return;
    _log(LogLevel.verbose, print?.call(object) ?? object.toString());
  }

  void print(Object? object) {
    core.print(object);
  }

  void _error(String message, _LogData data) {
    _log(LogLevel.error, message);
    _log(LogLevel.error, "${data.errorRuntimeType}: ${data.error}");
    for (final entry in data.requestHistory) {
      _logRequestEntry(LogLevel.error, entry);
    }
    for (final entry in data.sqlHistory) {
      _logSqlEntry(LogLevel.error, entry);
    }
  }

  void _logRequestEntry(LogLevel logLevel, _RequestLogEntry entry) {
    if (!logConfiguration[logLevel]) return;
    final method = entry.method;
    final path = entry.path;
    final params = entry.params;
    final headers = entry.headers;
    _log(logLevel, "┌──────────────────────────────────────────────────");
    _log(logLevel, "│ $method $path");
    if (params.isNotEmpty) params.forEach((key, value) => _log(logLevel, "│ & $key = $value"));
    if (headers.isEmpty) headers.forEach((key, value) => _log(logLevel, "│ > $key: $value"));
    _log(logLevel, "└──────────────────────────────────────────────────");
  }

  void _logSqlEntry(LogLevel logLevel, _SqlLogEntry entry) {
    if (!logConfiguration[logLevel]) return;
    final sql = entry.sql;
    final params = entry.params;
    _log(logLevel, sql.tidyCode());
    params?.forEach((key, value) => _log(logLevel, " -- $key: $value"));
    _log(logLevel, " --");
  }

  void _log(LogLevel level, String message) {
    //print("${level.prefix} $message");
    print(message);
  }

  R logError(ApiServer2<R> api, String message, Object error) {
    if (_sqlLogs.isEmpty && _requestLogs.isEmpty) return api.internalError(errorUnexpectedException(error));

    final allTransactionIds = <String>{..._sqlLogs.keys, ..._requestLogs.keys}.toList();

    while (allTransactionIds.isNotEmpty) {
      final transactionId = allTransactionIds.removeAt(0);
      final sqlLogs = _getSqlLogs(transactionId);
      final reqLogs = _getRequestLogs(transactionId);
      _clearSqlLogs(transactionId);
      _clearRequestLogs(transactionId);
      _error(message, _LogData(error: error, sqlHistory: sqlLogs, requestHistory: reqLogs));
    }

    return api.internalError(errorUnexpectedException(error));
  }

  void startSqlLogging(ApiServerContext context) {
    _sqlLogs[context.id] = [];
  }

  void clearSqlLogs(ApiServerContext context) {
    _sqlLogs.remove(context.id);
  }

  void _clearSqlLogs(String contextId) {
    _sqlLogs.remove(contextId);
  }

  List<_SqlLogEntry> _getSqlLogs(String contextId) {
    return _sqlLogs[contextId] ?? [];
  }

  void logSql(ApiServerContext context, String sql, [Map<String, dynamic>? params]) {
    final entry = _SqlLogEntry(sql: sql, params: params);
    _logSqlEntry(LogLevel.verbose, entry);
    if (_sqlLogs.containsKey(context.id)) _sqlLogs[context.id]!.add(entry);
  }

  void startRequestLogging(ApiServerContext context) {
    _requestLogs[context.id] = [];
  }

  void clearRequestLogs(ApiServerContext context) {
    _requestLogs.remove(context.id);
  }

  void _clearRequestLogs(String contextUuid) {
    _requestLogs.remove(contextUuid);
  }

  List<_RequestLogEntry> _getRequestLogs(String contextId) {
    return _requestLogs[contextId] ?? [];
  }

  void logRequest(ApiServerContext context, LogRequest request) {
    final entry = _RequestLogEntry(request: request);
    _logRequestEntry(LogLevel.verbose, entry);
    if (_requestLogs.containsKey(context.id)) _requestLogs[context.id]!.add(entry);
  }
}

// eof
import "package:core_dart/core_dart.dart";

class LogLevelConfiguration {
  final Map<LogLevel, bool> _config;

  LogLevelConfiguration({
    required bool error,
    required bool warning,
    required bool debug,
    required bool verbose,
  }) : _config = {
          LogLevel.error: error,
          LogLevel.warning: warning,
          LogLevel.debug: debug,
          LogLevel.verbose: verbose,
        };

  bool operator [](LogLevel level) => _config[level]!;

  @override
  String toString() =>
      "error: ${_config[LogLevel.error]}, warning: ${_config[LogLevel.warning]}, debug: ${_config[LogLevel.debug]}, verbose: ${_config[LogLevel.verbose]}";
}

final developmentLogLevelConfiguration = {
  LogLevel.error: true,
  LogLevel.warning: true,
  LogLevel.debug: true,
  LogLevel.verbose: true,
};

final productionLogLevelConfiguration = {
  LogLevel.error: true,
  LogLevel.warning: true,
  LogLevel.debug: false,
  LogLevel.verbose: false,
};

enum LogKeys {
  date,
  level,
  source,
  message,
  stackTrace,
  userId,
  sessionId,
  installationId,
  info,
  payload,
}

class Log {
  final DateTime date;
  final LogLevel level;
  final LogSource source;
  final String message;
  StackTrace? stackTrace;
  String? userId;
  String? sessionId;
  String? installationId;
  final List<String> info;
  final JsonObject? payload;

  Log({
    DateTime? date,
    required this.level,
    required this.source,
    required this.message,
    this.stackTrace,
    this.userId,
    this.sessionId,
    this.installationId,
    this.info = const [],
    this.payload,
  }) : date = date ?? DateTime.now();

  static const camel = {
    LogKeys.date: "date",
    LogKeys.level: "level",
    LogKeys.source: "source",
    LogKeys.message: "message",
    LogKeys.stackTrace: "stackTrace",
    LogKeys.userId: "userId",
    LogKeys.sessionId: "sessionId",
    LogKeys.installationId: "installationId",
    LogKeys.info: "info",
    LogKeys.payload: "payload",
  };

  static const snake = {
    LogKeys.date: "date",
    LogKeys.level: "level",
    LogKeys.source: "source",
    LogKeys.message: "message",
    LogKeys.stackTrace: "stack_trace",
    LogKeys.userId: "user_id",
    LogKeys.sessionId: "session_id",
    LogKeys.installationId: "installation_id",
    LogKeys.info: "info",
    LogKeys.payload: "payload",
  };

  factory Log.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.snake ? snake : camel;
    return Log(
      date: DateTime.parse(map[mapper[LogKeys.date]!] as String),
      level: LogLevelCode.fromCode(map[mapper[LogKeys.level]!] as int),
      source: LogSourceCode.fromCode(map[mapper[LogKeys.source]!] as int),
      message: map[mapper[LogKeys.message]!] as String,
      stackTrace: map[mapper[LogKeys.stackTrace]!] != null
          ? StackTrace.fromString(map[mapper[LogKeys.stackTrace]!] as String)
          : null,
      userId: map[mapper[LogKeys.userId]!] as String?,
      sessionId: map[mapper[LogKeys.sessionId]!] as String?,
      installationId: map[mapper[LogKeys.installationId]!] as String?,
      info: (map[mapper[LogKeys.info]!] as List<dynamic>?)?.cast<String>() ?? const [],
      payload: map[mapper[LogKeys.payload]!],
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.snake ? snake : camel;
    return {
      mapper[LogKeys.date]!: date.toIso8601String(),
      mapper[LogKeys.level]!: level.code,
      mapper[LogKeys.source]!: source.code,
      mapper[LogKeys.message]!: message,
      if (stackTrace != null) mapper[LogKeys.stackTrace]!: stackTrace!.toString(),
      if (userId != null) mapper[LogKeys.userId]!: userId,
      if (sessionId != null) mapper[LogKeys.sessionId]!: sessionId,
      if (installationId != null) mapper[LogKeys.installationId]!: installationId,
      if (info.isNotEmpty) mapper[LogKeys.info]!: info,
      if (payload != null) mapper[LogKeys.payload]!: payload,
    };
  }

  /*
  Log.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json["date"]),
        level = LogLevelCode.fromCode(json["level"]),
        source = LogSourceCode.fromCode(json["source"]),
        message = json["message"],
        stackTrace = json["stackTrace"] != null ? StackTrace.fromString(json["stackTrace"]) : null,
        userId = json["userId"],
        sessionId = json["sessionId"],
        installationId = json["installationId"],
        info = List<String>.from(json["info"]),
        payload = json["payload"];

  Map<String, dynamic> toJson() {
    return {
      "date": date.toIso8601String(),
      "level": level.code,
      "source": source.code,
      "message": message,
      if (stackTrace != null) "stackTrace": stackTrace!.toString(),
      if (userId != null) "userId": userId,
      if (sessionId != null) "sessionId": sessionId,
      if (installationId != null) "installationId": installationId,
      "info": info,
      if (payload != null) "payload": payload,
    };
  }
  */
}

// eof

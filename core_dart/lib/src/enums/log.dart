enum LogLevel { verbose, debug, warning, error }

extension LogLevelName on LogLevel {
  static const Map<LogLevel, String> _names = {
    LogLevel.error: "error",
    LogLevel.warning: "warning",
    LogLevel.debug: "debug",
    LogLevel.verbose: "verbose",
  };
  String get name => _names[this]!;
}

extension LogLevelPrefix on LogLevel {
  static const Map<LogLevel, String> _prefix = {
    LogLevel.error: "[E]",
    LogLevel.warning: "[W]",
    LogLevel.debug: "[D]",
    LogLevel.verbose: "[V]",
  };
  String get prefix => _prefix[this]!;
}

extension LogLevelCode on LogLevel {
  static final _codeMap = {
    LogLevel.error: 1,
    LogLevel.warning: 2,
    LogLevel.debug: 3,
    LogLevel.verbose: 4,
  };

  int get code => _codeMap[this]!;

  static LogLevel fromCode(int? code, {LogLevel def = LogLevel.verbose}) =>
      LogLevel.values.firstWhere((r) => r.code == code, orElse: () => def);
}

enum LogSource { mobile, dashboard, apiMobile, apiCron }

extension LogSourceCode on LogSource {
  static final _codeMap = {
    LogSource.mobile: 1,
    LogSource.dashboard: 2,
    LogSource.apiMobile: 3,
    LogSource.apiCron: 4,
  };

  int get code => _codeMap[this]!;

  static LogSource fromCode(int? code, {LogSource def = LogSource.apiMobile}) =>
      LogSource.values.firstWhere((r) => r.code == code, orElse: () => def);
}

// eof

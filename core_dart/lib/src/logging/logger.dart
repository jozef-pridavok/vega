import "package:logger/logger.dart" as impl;

typedef MessageFunction = String Function();

class Logger {
  static Logger? _instance;

  final bool releaseMode;
  final impl.Logger logger;

  Logger._internal({
    required this.logger,
    required this.releaseMode,
  });

  factory Logger() {
    assert(_instance != null);
    return _instance!;
  }

  factory Logger.setup({
    required bool releaseMode,
  }) {
    _instance ??= Logger._internal(
      logger: impl.Logger(
        //printer: impl.PrettyPrinter(methodCount: 0),
        level: impl.Level.trace,
        printer: impl.SimplePrinter(colors: false),
        filter: impl.ProductionFilter(),
      ),
      releaseMode: releaseMode,
    );
    return _instance!;
  }

  void verbose(MessageFunction message) {
    if (releaseMode) return;
    logger.t(message());
  }

  void debug(MessageFunction message) {
    if (releaseMode) return;
    logger.d(message());
  }

  void info(String message) {
    logger.i(message);
  }

  void warning(String message) {
    logger.w(message);
  }

  void error(String message) {
    logger.e(message);
  }
}

// eof

import "package:core_dart/core_dart.dart";

mixin LoggerMixin {
  final _logger = Logger();

  void verbose(MessageFunction message) => _logger.verbose(message);

  void debug(MessageFunction message) => _logger.debug(message);

  void info(String message) => _logger.info(message);

  void warning(String message) => _logger.warning(message);

  void error(String message) => _logger.error(message);
}

// eof

import "../data_models/session.dart";
import "package:core_dart/core_api_server.dart";

class DAO {
  final ApiServer api;
  final Session session;

  DAO(this.api, this.session);

  void debug(String message) => api.log.debug(message);
  void verbose(String message) => api.log.verbose(message);
  void warning(String message) => api.log.warning(message);
  void error(String message) => api.log.error(message);
}

// eof

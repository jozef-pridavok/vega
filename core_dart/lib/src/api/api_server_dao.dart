/*
// V handleri:
try {
  final client = await ClientDAO(_api, session).select(session.clientId!);
  if (client == null) return _api.noContent();
} catch (ex, st) {
  return _api.log.logError(
    'Failed to fetch client details',
    ex,
    st,
    _api,
  );
}
*/
import "../../core_api_server2.dart";

class ApiServerDAO {
  final ApiServer2 api;
  ApiLogger get log => api.log;

  ApiServerDAO(this.api);

  Future<T> withSqlLog<T>(ApiServerContext context, Future<T> Function() operation) async {
    log.startSqlLogging(context);
    try {
      final result = await operation();
      log.clearSqlLogs(context);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

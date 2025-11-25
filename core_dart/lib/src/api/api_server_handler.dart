import "../../core_api_server2.dart";

class ApiServerHandler {
  final ApiServer2 api;
  ApiLogger get log => api.log;

  ApiServerHandler(this.api);

  Future<T> withRequestLog<T>(Future<T> Function(ApiServerContext) operation) async {
    final context = ApiServerContext(api);
    log.startRequestLogging(context);
    try {
      final result = await operation(context);
      log.clearRequestLogs(context);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

// eof

import "dart:convert";

import "package:intl/intl.dart";

import "../../core_dart.dart";
import "api_server_config.dart";
import "api_server_logger.dart";

typedef Redis = Future<dynamic> Function(List<Object?> commands);

abstract class ApiServer2<R> {
  ApiLogger<R> get log;
  ApiServerConfig get config;

  ApiServer2();

  Future<void> serve();

  // redis methods

  Future<dynamic> redis(List<Object?> commands);

  // sql methods

  Future<List<JsonObject>> select(String sql, {Map<String, dynamic>? params});

  Future<int> insert(String sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> insertWithResult(String sql, {Map<String, dynamic>? params});

  Future<int> update(String sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> updateWithResult(String sql, {Map<String, dynamic>? params});

  Future<int> delete(String sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> deleteWithResult(String sql, {Map<String, dynamic>? params});

  // i18n methods

  String tr(String locale, String key, {List<String>? args, Map<String, String>? namedArgs, String? gender});

  String plural(String locale, String key, num value,
      {List<String>? args, Map<String, String>? namedArgs, String? name, NumberFormat? format});

  String? formatAmount(String locale, Plural? plural, num amount, {int? digits});

  // rest methods

  R response(
    int statusCode, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  });

  /// 200 - OK
  R json(JsonObject json);
  R html(String html);
  R ok();

  /// 201 - Created
  R created(JsonObject json);

  /// 202 - Accepted
  R accepted(JsonObject json);

  /// 204 - No content
  R noContent({JsonObject? json});

  /// 208
  R cached();

  /// 400 - The server cannot or will not process the request due to something that is perceived to be a Program error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing)
  R badRequest(CoreError error);

  /// 401 - Although the HTTP standard specifies "unauthorized", semantically this response means "unauthenticated". That is, the client must authenticate itself to get the requested response.
  R unauthorized(CoreError error);

  /// 403 - The client does not have access rights to the content; that is, it is unauthorized, so the server is refusing to give the requested resource. Unlike 401 Unauthorized, the client's identity is known to the server.
  R forbidden(CoreError error);

  /// 404 - The server cannot find the requested resource. In the browser, this means the URL is not recognized. In an API, this can also mean that the endpoint is valid but the resource itself does not exist. Servers may also send this response instead of 403 Forbidden to hide the existence of a resource from an unauthorized client. This response code is probably the most well known due to its frequent occurrence on the web.
  R notFound(CoreError error);

  /// 405 - The request method is known by the server but is not supported by the target resource. For example, an API may not allow calling DELETE to remove a resource.
  R notAllowed(CoreError error);

  /// 409 - This response is sent when a request conflicts with the current state of the server.
  R conflict(CoreError error);

  /// 500 - A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
  R internalError(CoreError error);

  /// 501 - The server either does not recognize the request method, or it lacks the ability to fulfil the request. Usually this implies future availability (e.g., a new feature of a web-service API).
  R notImplemented(CoreError error);
}

class ApiServerContext {
  final ApiServer2 api;
  final String id;

  ApiServerContext(this.api) : id = uuid();
}

// eof


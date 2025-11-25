import "dart:async";
import "dart:convert";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:core_dart/core_redis.dart";
import "package:intl/intl.dart";
import "package:postgres/postgres.dart" as psql;
import "package:shelf/shelf.dart";

import "api_shelf_cron.dart";
import "api_shelf_http_server.dart";
import "api_shelf_postgres.dart";
import "api_shelf_redis.dart";
import "api_shelf_translator.dart";
import "api_shelf_v1.dart";
import "configuration_yaml.dart";

extension RequestToLog on Request {
  LogRequest toLogRequest() => LogRequest(
        method: method,
        path: handlerPath + url.path,
        headers: headers,
        params: url.queryParameters,
      );
}

class CronApi extends ApiServer2<Response> with CronApiV1 {
  static const headerApiKey = "x-api-key";
  static const headerRefreshToken = "x-refresh-token";
  static const headerAccessToken = "Authorization";
  static const headerDevUserId = "x-dev-user-id";
  static const headerDevInstallationId = "x-dev-installation-id";
  static final bearerRegExp = RegExp(r"^Bearer [A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+$");

  @override
  late final ApiLogger<Response> log;

  @override
  late final CronApiConfig config;

  late String idRegExp;

  late psql.Connection _psql;
  late RedisCommand _redisCommand;
  late Translator _translator;

  CronApi(this.config) {
    final isProduction = config.isProduction;
    idRegExp = isProduction ? "[0-9a-fA-F-]{36}" : ".{1,36}";

    log = ApiLogger<Response>(logConfiguration: config.logLevelConfiguration);
    log.print("Cron API on ${config.host}:${config.port}");
    log.print("Environment: ${config.environment.code}");
    log.print("Production environment: ${isProduction ? "yes" : "no, allowed object id reg exp: \"$idRegExp\""}");
    log.print("Log level: ${config.logLevelConfiguration}");
  }

  @override
  Future<void> serve() async {
    log.debug("Connecting to Postgres");
    _psql = await connectPostgres();

    log.debug("Connecting to Redis");
    _redisCommand = await connectRedis();

    log.debug("Loading translator dictionary");
    _translator = loadTranslator();

    log.debug("Scheduling cron jobs");
    cron();

    log.debug("Starting HTTP server");
    await httpServer();
  }

  // redis methods

  @override
  Future<dynamic> redis(List<Object?> commands) async => await executeRedisCommand(_redisCommand, commands);

  // sql methods

  @override
  Future<List<JsonObject>> select(String sql, {Map<String, dynamic>? params}) async {
    final rows = await executeSqlCommand(_psql, sql, params: params);
    return rows.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<int> insert(String sql, {Map<String, dynamic>? params}) async =>
      (await executeSqlCommand(_psql, sql, params: params)).affectedRows;

  @override
  Future<(int, List<JsonObject>)> insertWithResult(String sql, {Map<String, dynamic>? params}) async {
    final result = await executeSqlCommand(_psql, sql, params: params);
    return (result.affectedRows, result.map((row) => row.toColumnMap()).toList());
  }

  @override
  Future<int> update(String sql, {Map<String, dynamic>? params}) async =>
      (await executeSqlCommand(_psql, sql, params: params)).affectedRows;

  @override
  Future<(int, List<JsonObject>)> updateWithResult(String sql, {Map<String, dynamic>? params}) async {
    final result = await executeSqlCommand(_psql, sql, params: params);
    return (result.affectedRows, result.map((row) => row.toColumnMap()).toList());
  }

  @override
  Future<int> delete(String sql, {Map<String, dynamic>? params}) async =>
      (await executeSqlCommand(_psql, sql, params: params)).affectedRows;

  @override
  Future<(int, List<JsonObject>)> deleteWithResult(String sql, {Map<String, dynamic>? params}) async {
    final result = await executeSqlCommand(_psql, sql, params: params);
    return (result.affectedRows, result.map((row) => row.toColumnMap()).toList());
  }

  /*
  Future<int> transaction(dynamic sql, {Map<String, dynamic>? params}) async {
    await _psql.runTx((session) async {
      await session.query(psql.Sql.named(sql), substitutionValues: params);
    }); 
  }
  */

  // i18n methods

  @override
  String tr(String locale, String key, {List<String>? args, Map<String, String>? namedArgs, String? gender}) =>
      _translator.tr(locale, key, args: args, namedArgs: namedArgs, gender: gender);

  @override
  String plural(String locale, String key, num value,
          {List<String>? args, Map<String, String>? namedArgs, String? name, NumberFormat? format}) =>
      _translator.plural(locale, key, value, args: args, namedArgs: namedArgs, name: name, format: format);

  @override
  String? formatAmount(String locale, Plural? plural, num amount, {int? digits}) =>
      formatAmountWithTranslator(_translator, locale, plural, amount, digits: digits);

  // rest methods

  @override
  Response response(
    int statusCode, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return Response(statusCode, body: body, headers: headers, encoding: encoding, context: context);
  }

  /// 200 - OK
  @override
  Response json(JsonObject json) {
    const headers = {"Content-Type": "application/json"};
    return Response(200, body: jsonEncode(json), headers: headers);
  }

  @override
  Response html(String html) {
    const headers = {"Content-Type": "text/html"};
    return Response(200, body: html, headers: headers);
  }

  @override
  Response ok() {
    return Response(200);
  }

  /// 201 - Created
  @override
  Response created(JsonObject json) {
    const headers = {"Content-Type": "application/json"};
    return Response(201, body: jsonEncode(json), headers: headers);
  }

  /// 202 - Accepted
  @override
  Response accepted(JsonObject json) {
    const headers = {"Content-Type": "application/json"};
    return Response(202, body: jsonEncode(json), headers: headers);
  }

  /// 204 - No content
  @override
  Response noContent({JsonObject? json}) {
    const headers = {"Content-Type": "application/json"};
    return Response(204, body: json != null ? jsonEncode(json) : null, headers: headers);
  }

  /// 208 - Already reported
  @override
  Response cached() {
    const headers = {"Content-Type": "application/json"};
    return Response(208, headers: headers);
  }

  JsonObject _errorToJson(int status, CoreError error) {
    final json = <String, dynamic>{"code": error.code};
    if (config.isNotProduction) {
      json["message"] = error.message;
      if (error.innerException != null) json["inner"] = error.innerException.toString();
      if (error.payload != null) json["payload"] = error.payload;
    }
    return json;
  }

  /// 400 - The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing)
  @override
  Response badRequest(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(400, error);
    return Response(400, body: jsonEncode(body), headers: headers);
  }

  /// 401 - Although the HTTP standard specifies "unauthorized", semantically this response means "unauthenticated". That is, the client must authenticate itself to get the requested response.
  @override
  Response unauthorized(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(401, error);
    return Response(401, body: jsonEncode(body), headers: headers);
  }

  /// 403 - The client does not have access rights to the content; that is, it is unauthorized, so the server is refusing to give the requested resource. Unlike 401 Unauthorized, the client's identity is known to the server.
  @override
  Response forbidden(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(403, error);
    return Response(403, body: jsonEncode(body), headers: headers);
  }

  /// 404 - The server cannot find the requested resource. In the browser, this means the URL is not recognized. In an API, this can also mean that the endpoint is valid but the resource itself does not exist. Servers may also send this response instead of 403 Forbidden to hide the existence of a resource from an unauthorized client. This response code is probably the most well known due to its frequent occurrence on the web.
  @override
  Response notFound(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(404, error);
    return Response(404, body: jsonEncode(body), headers: headers);
  }

  /// 405 - The request method is known by the server but is not supported by the target resource. For example, an API may not allow calling DELETE to remove a resource.
  @override
  Response notAllowed(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(405, error);
    return Response(405, body: jsonEncode(body), headers: headers);
  }

  /// 409 - This response is sent when a request conflicts with the current state of the server.
  @override
  Response conflict(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(409, error);
    return Response(409, body: jsonEncode(body), headers: headers);
  }

  /// 500 - A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
  @override
  Response internalError(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(500, error);
    return Response(500, body: jsonEncode(body), headers: headers);
  }

  /// 501 - The server either does not recognize the request method, or it lacks the ability to fulfil the request. Usually this implies future availability (e.g., a new feature of a web-service API).
  @override
  Response notImplemented(CoreError error) {
    const headers = {"Content-Type": "application/json"};
    final body = _errorToJson(501, error);
    return Response(501, body: jsonEncode(body), headers: headers);
  }
}

// eof

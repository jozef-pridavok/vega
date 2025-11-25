import "dart:convert";

import "package:core_dart/core_dart.dart";
import "package:intl/intl.dart";

abstract class Configuration {
  String get host;
  int get port;
  Flavor get environment;
  int get build;
  String get localPath;
  String get cronApiHost;
  String get mobileApiHost;

  String get redisHost;
  int get redisPort;
  bool get redisUseSsl;
  String get redisUsername;
  String get redisPassword;
  int get redisDatabase;

  String get postgresHost;
  int get postgresPort;
  String get postgresUsername;
  String get postgresPassword;
  String get postgresDatabase;
  String get postgresSslMode;

  String get storagePath;
  String get storageUrl;
  String get storageDev2Local;

  String get secretReceiptKey;
  String get secretQrCodeKey;
  String get secretQrCodeEnv;
  String get secretJwt;

  bool get logError;
  bool get logWarning;
  bool get logDebug;
  bool get logVerbose;

  String get keyV1;
  String get keyV2;

  // 3rd parties

  String get trdJesoftKey;
  List<String> get trdJesoftAddresses;

  // Cron API

  String get pushServiceUrl;
  String get pushServiceApiKey;

  String get smtpHost;
  String get smtpFrom;
  String get smtpUsername;
  String get smtpPassword;
  int get smtpPort;
  bool get smtpUseSsl;

  String get apnKeyId;
  String get apnTeamId;
  String get apnPrivateKey;

  // Mobile Api

  int get jwtAccessTokenExpirationMinutes;
  int get jwtRefreshTokenExpirationDays;

  String get whatsappClientId;
  String get whatsappClientSecret;
  String get whatsappConfigId;

  //

  bool get isDev => environment == Flavor.dev;
  bool get isQa => environment == Flavor.qa;
  bool get isDemo => environment == Flavor.demo;
  bool get isProd => environment == Flavor.prod;
}

abstract class Logging {
  void verbose(String message);
  void debug(String message);
  void warning(String message);
  void error(String message, [StackTrace? stackTrace]);
  void print(String message);
}

class LogBag {
  // singleton instance

  static final LogBag _instance = LogBag._internal();
  factory LogBag() => _instance;
  LogBag._internal();

  final List<Logging> chain = [];

  void verbose(String message) {
    for (final log in chain) log.verbose(message);
  }

  void debug(String message) {
    for (final log in chain) log.debug(message);
  }

  void warning(String message) {
    for (final log in chain) log.warning(message);
  }

  void error(String message, [StackTrace? stackTrace]) {
    for (final log in chain) log.error(message, stackTrace);
  }

  void print(String message) {
    for (final log in chain) log.print(message);
  }

  void add(Logging log) => chain.add(log);
}

// TODO: just for 'vtc' tool
extension StringTranslation on String {
  String tr() => this;
}

abstract class ApiServer<RESPONSE> {
  Future<dynamic> redis(List<Object?> commands);

  Future<List<JsonObject>> select(dynamic sql, {Map<String, dynamic>? params});

  Future<int> insert(dynamic sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> insertWithResult(dynamic sql, {Map<String, dynamic>? params});

  Future<int> update(dynamic sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> updateWithResult(dynamic sql, {Map<String, dynamic>? params});

  Future<int> delete(dynamic sql, {Map<String, dynamic>? params});
  Future<(int, List<JsonObject>)> deleteWithResult(dynamic sql, {Map<String, dynamic>? params});

  String tr(
    String language,
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  });

  String plural(
    String language,
    String key,
    num value, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  });

  //String amount(String language, Plural? plural, num amount);
  String? formatAmount(String locale, Plural? plural, num amount, {int? digits});

  Future<void> serve();

  RESPONSE response(
    int statusCode, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  });

  /// 200 - OK
  RESPONSE json(JsonObject json);
  RESPONSE html(String html);
  RESPONSE ok();

  /// 201 - Created
  RESPONSE created(JsonObject json);

  /// 202 - Accepted
  RESPONSE accepted(JsonObject json);

  /// 204 - No content
  RESPONSE noContent({JsonObject? json});

  /// 208
  RESPONSE cached();

  /// 400 - The server cannot or will not process the request due to something that is perceived to be a Program error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing)
  RESPONSE badRequest(CoreError error);

  /// 401 - Although the HTTP standard specifies "unauthorized", semantically this response means "unauthenticated". That is, the client must authenticate itself to get the requested response.
  RESPONSE unauthorized(CoreError error);

  /// 403 - The client does not have access rights to the content; that is, it is unauthorized, so the server is refusing to give the requested resource. Unlike 401 Unauthorized, the client's identity is known to the server.
  RESPONSE forbidden(CoreError error);

  /// 404 - The server cannot find the requested resource. In the browser, this means the URL is not recognized. In an API, this can also mean that the endpoint is valid but the resource itself does not exist. Servers may also send this response instead of 403 Forbidden to hide the existence of a resource from an unauthorized client. This response code is probably the most well known due to its frequent occurrence on the web.
  RESPONSE notFound(CoreError error);

  /// 405 - The request method is known by the server but is not supported by the target resource. For example, an API may not allow calling DELETE to remove a resource.
  RESPONSE notAllowed(CoreError error);

  /// 409 - This response is sent when a request conflicts with the current state of the server.
  RESPONSE conflict(CoreError error);

  /// 500 - A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
  RESPONSE internalError(CoreError error);

  /// 501 - The server either does not recognize the request method, or it lacks the ability to fulfil the request. Usually this implies future availability (e.g., a new feature of a web-service API).
  RESPONSE notImplemented(CoreError error);

  LogBag get log;
  Configuration get config;
  String get idRegExp;
}


// eof

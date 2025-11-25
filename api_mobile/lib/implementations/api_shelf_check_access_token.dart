import "package:core_dart/core_dart.dart";
import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:shelf/shelf.dart";

import "../utils/storage.dart";
import "api_shelf2.dart";
import "api_shelf_http_server.dart";

extension MobileApiCheckToken on MobileApi {
  Middleware get checkAccessToken {
    return (innerHandler) {
      return (request) async {
        if (request.method == "OPTIONS") return innerHandler(request);

        final headers = request.headers;
        final url = request.url.path;

        // Skip to check access token for local storage
        if (config.isDev && config.storageDev2Local.isNotEmpty && urlIsRelativeStorage(url))
          return innerHandler(request);

        if (accessWithoutToken(url)) return innerHandler(request);

        if (config.environment == Flavor.dev) {
          final userId = headers[MobileApi.headerDevUserId];
          final installationId = headers[MobileApi.headerDevInstallationId];
          if (userId != null && installationId != null) {
            request = request.change(context: {"uid": userId});
            request = request.change(context: {"iid": installationId});
            return innerHandler(request);
          }
        }

        final hasAccessToken = headers.containsKey(MobileApi.headerAccessToken);
        if (!hasAccessToken) {
          log.verbose("No access token found in the request headers. Url: $url");
          return forbidden(errorNoAccessToken);
        }

        final authHeader = headers[MobileApi.headerAccessToken];
        if (authHeader == null || authHeader.isEmpty || !MobileApi.bearerRegExp.hasMatch(authHeader)) {
          log.verbose("Invalid access token format: $authHeader");
          return badRequest(errorInvalidAccessToken);
        }

        try {
          final payload = verifyAccessToken(authHeader.split(" ")[1]);
          final userId = payload?["uid"] as String;
          final installationId = payload?["iid"] as String;
          request = request.change(context: {"uid": userId});
          request = request.change(context: {"iid": installationId});
        } on CoreError catch (ex) {
          return badRequest(ex);
        }
        return innerHandler(request);
      };
    };
  }

  /// Returns payload of the access token.
  JsonObject? verifyAccessToken(String token, {String? userId}) {
    try {
      final jwt = JWT.verify(token, SecretKey(config.secretJwt));
      log.verbose("JWT access token payload: ${jwt.payload}");
      if (userId != null && jwt.payload["uid"] != null && userId != jwt.payload["uid"]) throw errorTokenIsStolen;
      return jwt.payload;
    } on JWTExpiredException {
      throw errorInvalidAccessTokenEx("JWT access token is expired.");
    } on JWTException catch (ex) {
      log.error("JWT access token has invalid signature, exception: ${ex.toString()}");
      throw errorInvalidAccessToken;
    }
  }

  /// Returns payload of the refresh token and its family.
  Future<(JsonObject, String)> verifyRefreshToken(String refreshToken, {String? userId}) async {
    try {
      final jwt = JWT.verify(refreshToken, SecretKey(config.secretJwt));
      final payload = jwt.payload;
      log.verbose("JWT refresh token payload: $payload");
      if (payload is! Map || !(jwt.payload as JsonObject).containsKey("fam")) throw errorInvalidRefreshTokenPayload;
      if (userId != null && payload["uid"] != null && userId != payload["uid"]) throw errorTokenIsStolen;

      final sql = """
        SELECT refresh_token
        FROM tokens
        WHERE family = @family AND blocked = FALSE
        ORDER BY created_at DESC LIMIT 1
      """
          .tidyCode();

      final sqlParams = <String, dynamic>{"family": payload["fam"]};

      log.verbose(sql);
      log.verbose(sqlParams.toString());

      final rows = await select(sql, params: sqlParams);
      if (rows.isEmpty) throw errorInvalidRefreshToken;

      final JsonObject dbToken = rows.first;
      if (dbToken["refresh_token"] != refreshToken) {
        final sql = """
          UPDATE tokens
          SET blocked = TRUE, updated_at = NOW()
          WHERE family = @family AND blocked = FALSE
        """
            .tidyCode();
        final sqlParams = <String, dynamic>{"family": payload["fam"]};
        log.verbose(sql);
        log.verbose(sqlParams.toString());
        final _ = await update(sql, params: sqlParams);
        throw errorRefreshTokenReuseDetected;
      }
      return (jwt.payload as JsonObject, payload["fam"] as String);
    } on JWTExpiredException {
      throw errorInvalidRefreshTokenEx("JWT refresh token is expired.");
    } on JWTException catch (ex) {
      log.error("JWT refresh token has invalid signature, exception: ${ex.toString()}");
      throw errorInvalidRefreshToken;
    }
  }

  /// Returns a new access token.
  String issueAccessToken({JsonObject? payload}) {
    final jwt = JWT(payload ?? {});
    Duration expiresIn = Duration(minutes: config.jwtAccessTokenExpirationMinutes);
    final token = jwt.sign(SecretKey(config.secretJwt), algorithm: JWTAlgorithm.HS512, expiresIn: expiresIn);
    return token;
  }

  /// Returns a new refresh token.
  Future<String> issueRefreshToken({String? userId, String? fromFamily, JsonObject? payload}) async {
    final family = fromFamily ?? uuid();
    final jwt = JWT({"fam": family, if (userId != null) "uid": userId, ...(payload ?? {})});
    Duration expiresIn = Duration(days: config.jwtRefreshTokenExpirationDays);
    //Duration expiresIn = Duration(seconds: 5);
    final token = jwt.sign(SecretKey(config.secretJwt), algorithm: JWTAlgorithm.HS512, expiresIn: expiresIn);
    final decoded = JWT.decode(token);

    final sql = """
      INSERT INTO tokens(token_id, user_id, refresh_token, family, expires_at)
      VALUES(@token_id, @user_id, @refresh_token, @family, @expires_in) 
    """
        .tidyCode();

    final sqlParams = <String, dynamic>{
      "token_id": uuid(),
      "user_id": userId,
      "refresh_token": token,
      "family": family,
      "expires_in": DateTime.fromMillisecondsSinceEpoch(decoded.payload["exp"] * 1000)
    };

    log.verbose(sql);
    log.verbose(sqlParams.toString());

    final insertedTokens = await insert(sql, params: sqlParams);
    if (insertedTokens != 1) throw errorBrokenLogicEx("issueRefreshToken: insertedTokens != 1");
    return token;
  }
}

// eof

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";

import "../implementations/api_shelf2.dart";

/// Returns payload of the access token.
JsonObject? verifyAccessToken(ApiServer2 api, String token, {String? userId}) {
  try {
    final jwt = JWT.verify(token, SecretKey((api as MobileApi).config.secretJwt));
    api.log.verbose("JWT access token payload: ${jwt.payload}");
    if (userId != null && jwt.payload["uid"] != null && userId != jwt.payload["uid"]) throw errorTokenIsStolen;
    return jwt.payload;
  } on JWTExpiredException {
    throw errorInvalidAccessTokenEx("JWT access token is expired.");
  } on JWTException catch (ex) {
    api.log.error("JWT access token has invalid signature, exception: ${ex.toString()}");
    throw errorInvalidAccessToken;
  }
}

/// Returns payload of the refresh token and its family.
Future<(JsonObject, String)> verifyRefreshToken(ApiServer2 api, String refreshToken, {String? userId}) async {
  try {
    final jwt = JWT.verify(refreshToken, SecretKey((api as MobileApi).config.secretJwt));
    final payload = jwt.payload;
    api.log.verbose("JWT refresh token payload: $payload");
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

    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());

    final rows = await api.select(sql, params: sqlParams);
    if (rows.isEmpty) throw errorInvalidRefreshToken;

    final JsonObject dbToken = rows.first;
    if (dbToken["refresh_token"] != refreshToken) {
      final sql = """
        UPDATE tokens
        SET blocked = TRUE, updated_at = NOW()
        WHERE family = @family AND blocked = FALSE
      """;
      final sqlParams = <String, dynamic>{"family": payload["fam"]};
      api.log.verbose(sql);
      api.log.verbose(sqlParams.toString());
      final _ = await api.update(sql, params: sqlParams);
      throw errorRefreshTokenReuseDetected;
    }
    return (jwt.payload as JsonObject, payload["fam"] as String);
  } on JWTExpiredException {
    throw errorInvalidRefreshTokenEx("JWT refresh token is expired.");
  } on JWTException catch (ex) {
    api.log.error("JWT refresh token has invalid signature, exception: ${ex.toString()}");
    throw errorInvalidRefreshToken;
  }
}

/// Returns a new access token.
String issueAccessToken(ApiServer2 api, {JsonObject? payload}) {
  final jwt = JWT(payload ?? {});
  Duration expiresIn = Duration(minutes: (api as MobileApi).config.jwtAccessTokenExpirationMinutes);
  final token = jwt.sign(SecretKey(api.config.secretJwt), algorithm: JWTAlgorithm.HS512, expiresIn: expiresIn);
  return token;
}

/// Returns a new refresh token.
Future<String> issueRefreshToken(ApiServer2 api, {String? userId, String? fromFamily, JsonObject? payload}) async {
  final family = fromFamily ?? uuid();
  final jwt = JWT({"fam": family, if (userId != null) "uid": userId, ...(payload ?? {})});
  Duration expiresIn = Duration(days: (api as MobileApi).config.jwtRefreshTokenExpirationDays);
  //Duration expiresIn = Duration(seconds: 5);
  final token = jwt.sign(SecretKey(api.config.secretJwt), algorithm: JWTAlgorithm.HS512, expiresIn: expiresIn);
  final decoded = JWT.decode(token);

  final sql = """
    INSERT INTO tokens(token_id, user_id, refresh_token, family, expires_at)
    VALUES(@token_id, @user_id, @refresh_token, @family, @expires_in) 
  """;
  final sqlParams = <String, dynamic>{
    "token_id": uuid(),
    "user_id": userId,
    "refresh_token": token,
    "family": family,
    "expires_in": DateTime.fromMillisecondsSinceEpoch(decoded.payload["exp"] * 1000)
  };
  api.log.verbose(sql);
  api.log.verbose(sqlParams.toString());
  final insertedTokens = await api.insert(sql, params: sqlParams);
  if (insertedTokens != 1) throw errorBrokenLogicEx("issueRefreshToken: insertedTokens != 1");
  return token;
}

// eof

import "dart:io";

import "package:bcrypt/bcrypt.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../api_v1/session.dart";
import "../api_v1/token.dart";
import "../cache.dart";
import "../data_access_objects/user_address.dart";
import "../extensions/request_body.dart";
import "../implementations/api_shelf2.dart";
import "../strings.dart";
import "../utils/send_message.dart";
import "../utils/template_generator.dart";

class UserHandler extends ApiServerHandler {
  final MobileApi _api;
  UserHandler(this._api) : super(_api);

  static const int maxLoginAttempts = 5;
  static const Duration loginAttemptsExpiration = Duration(minutes: 1);

  Future<void> _incrementLoginAttempts(String ipAddress) async {
    final key = CacheKeys.loginAttempts(ipAddress);
    final exists = await _api.redis(["EXISTS", key]);
    if (exists == 0) {
      await _api.redis(["SET", key, 1, "EX", loginAttemptsExpiration.inSeconds]);
    } else {
      await _api.redis(["INCR", key]);
    }
  }

  Future<int> _getNumberOfLoginAttempts(String ipAddress) async {
    final key = CacheKeys.loginAttempts(ipAddress);
    final value = await _api.redis(["GET", key]);
    return tryParseInt(value) ?? 0;
  }

  /// Updates application installation. Should be called on application startup with new device token
  /// and device info.
  ///
  /// Http status codes: 200, 400, 403, 500
  Future<Response> _startup(Request request) async => withRequestLog((context) async {
        final body = cast<JsonObject>(await request.body.asJson);
        final currentRefreshToken = body?["refreshToken"];
        if (currentRefreshToken == null) return _api.badRequest(errorInvalidRefreshToken);

        final installationId = request.context["iid"] as String;
        final userId = request.context["uid"] as String;

        // Issue new access and refresh token
        final String accessToken, newRefreshToken;
        try {
          final (_, family) = await verifyRefreshToken(_api, currentRefreshToken, userId: userId);
          newRefreshToken = await issueRefreshToken(_api, userId: userId, fromFamily: family);
          accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});
        } on CoreError catch (ex, st) {
          // TODO: ak bol anonymný, tak ho mám označiť ako vymazaný (má smolu)
          _api.log.error(ex.toString());
          _api.log.error(st.toString());
          if (ex.code == errorRefreshTokenReuseDetected.code) {
            return _api.forbidden(ex);
          } else if (ex.code == errorBrokenLogic.code) {
            return _api.internalError(ex);
          }
          return _api.badRequest(ex);
        }

        final sql = """
          UPDATE installations
          SET  
            device_token = COALESCE(@device_token, device_token),
            device_info = COALESCE(@device_info, device_info),
            updated_at = NOW()
          WHERE installation_id = @installation_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "installation_id": installationId,
          "device_token": body?["deviceToken"],
          "device_info": body?["deviceInfo"],
        };

        /*
      if (deviceToken != null)
        await _api.redis(
          ["SET", "user:${session.userId}:deviceToken", body?["deviceToken"]],
        );

      if (locale != null)
        await _api.redis(
          ["SET", "user:${session.userId}:locale", body?["locale"]],
        );
      */

        log.logSql(context, sql, sqlParams);

        final affected = await _api.update(sql, params: sqlParams);
        if (affected != 1) return _api.internalError(errorNoInstallation);

        return _api.json({"userId": userId, "refreshToken": newRefreshToken, "accessToken": accessToken});
      });

  Future<Response> _updateDeviceToken(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final body = cast<JsonObject>(await request.body.asJson);
        final deviceToken = cast<String>(body?["deviceToken"]);

        final sql = """
          UPDATE installations
          SET  
            ${(deviceToken?.isNotEmpty ?? true) ? 'device_token = @device_token,' : 'device_token = NULL, '}
            updated_at = NOW()
          WHERE installation_id = @installation_id AND user_id = @user_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "installation_id": installationId,
          "device_token": deviceToken,
          "user_id": session.userId,
        };

        log.logSql(context, sql, sqlParams);

        final affected = await _api.update(sql, params: sqlParams);
        return _api.json({"affected": affected});
      });

  Future<Response> _anonymous(Request request) async => withRequestLog((context) async {
        final connectionInfo = cast<HttpConnectionInfo>(
          request.context["shelf.io.connection_info"],
        );
        final String? ipAddress =
            request.headers["x-forwarded-for"]?.split(", ")[0] ?? connectionInfo?.remoteAddress.address;
        if (ipAddress != null) {
          int attempts = await _getNumberOfLoginAttempts(ipAddress);
          if (attempts > maxLoginAttempts) return _api.forbidden(errorToManyAttempts);
          await _incrementLoginAttempts(ipAddress);
        }

        final body = cast<JsonObject>(await request.body.asJson);

        final installationId = cast<String>(body?["installationId"]);
        if (installationId == null) return _api.badRequest(errorMissingParameter("installationId"));

        final country = cast<String>(body?["country"]);
        if (country == null) return _api.badRequest(errorMissingParameter("country"));

        final language = cast<String>(body?["language"]);
        if (language == null) return _api.badRequest(errorMissingParameter("language"));

        final userId = uuid();
        String sql = """
          INSERT INTO users
          (user_id, country, language, created_at)
            VALUES
          (@user_id, @country, @language, NOW())
        """
            .tidyCode();
        var sqlParams = <String, dynamic>{"user_id": userId, "country": country, "language": language};

        log.logSql(context, sql, sqlParams);

        final insertedUsers = await _api.insert(sql, params: sqlParams);
        if (insertedUsers != 1) return _api.internalError(errorBrokenLogicEx("User not created"));

        sql = """
          INSERT INTO installations(installation_id, user_id, device_token, device_info, updated_at)
          VALUES (@installation_id, @user_id, @device_token, @device_info, NOW())
          ON CONFLICT (installation_id) DO UPDATE SET
              user_id = EXCLUDED.user_id,
              device_token = EXCLUDED.device_token,
              device_info = EXCLUDED.device_info,
              updated_at = EXCLUDED.updated_at
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "installation_id": installationId,
          "user_id": userId,
          "device_token": body?["deviceToken"],
          "device_info": body?["deviceInfo"],
        };
        log.logSql(context, sql, sqlParams);
        final affectedInstallations = await _api.insert(sql, params: sqlParams);
        if (affectedInstallations != 1) return _api.internalError(errorBrokenLogic);

        final refreshToken = await issueRefreshToken(_api, userId: userId);
        final accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});

        return _api.json({"userId": userId, "refreshToken": refreshToken, "accessToken": accessToken});
      });

  ///
  /// Register new user.
  ///
  /// Http status codes: 200, 400, 401, 500
  ///
  Future<Response> _register(Request request) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;

        final body = cast<JsonObject>(await request.body.asJson);
        final login = cast<String>(body?["login"]);
        final email = cast<String>(body?["email"]);

        if (login == null && email == null) return _api.badRequest(errorMissingParameter("login, email"));

        final password = cast<String>(body?["password"]);
        if (password == null) return _api.badRequest(errorMissingParameter("password"));

        if (installationId != cast<String>(body?["installationId"])) return _api.unauthorized(errorInvalidInstallation);

        var sql = "SELECT user_id FROM users WHERE login = @login OR email = @email";
        var sqlParams = <String, dynamic>{"login": login, "email": email};
        log.logSql(context, sql, sqlParams);
        final results = await _api.select(sql, params: sqlParams);
        if (results.isNotEmpty) return _api.badRequest(errorUserAlreadyExists);

        final passwordSalt = BCrypt.gensalt();
        final passwordHash = BCrypt.hashpw(password, passwordSalt);

        final emailConfirmationTokenDuration = const Duration(days: 3);
        final emailConfirmationToken = uuid();
        sql = """
          UPDATE users
          SET login = @login, email = @email, password_hash = @password_hash, password_salt = @password_salt, 
              meta = COALESCE(meta, '{}')::jsonb || 
                '{  "emailConfirmationToken": "$emailConfirmationToken",
                    "emailConfirmationExpiration": "${DateTime.now().toUtc().add(emailConfirmationTokenDuration).toIso8601String()}"
                 }'::jsonb,        
              updated_at = NOW()
          WHERE user_id = @user_id
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "user_id": userId,
          "login": login,
          "email": email,
          "password_hash": passwordHash,
          "password_salt": passwordSalt,
        };
        log.logSql(context, sql, sqlParams);

        final insertedUsers = await _api.insert(sql, params: sqlParams);
        if (insertedUsers != 1) return _api.internalError(errorBrokenLogicEx("User not created"));

        sql = """
          UPDATE installations 
          SET user_id = @userId, updated_at = NOW()
          WHERE installation_id = @installationId
        """
            .tidyCode();

        sqlParams = <String, dynamic>{"userId": userId, "installationId": installationId};
        log.logSql(context, sql, sqlParams);
        final updatedInstallations = await _api.update(sql, params: sqlParams);
        if (updatedInstallations != 1) return _api.internalError(errorNoInstallation);

        //await SqlCache().clear(_api.redis, "user:$userId");
        await Cache().clearAll(_api.redis, CacheKeys.user(userId));
        await _api.clearSession(installationId);
        final session = await _api.getSession(installationId);
        final userLanguage = session.language ?? "en";

        final refreshToken = await issueRefreshToken(_api, userId: userId);
        final accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});

        // TODO: move to cron
        //  get all users where (email_verified = FALSE AND meta->>'emailConfirmationSentAt' IS NULL)
        //  - set new emailConfirmationToken
        //  - set emailConfirmationSentAt = NOW()
        // email confirmation

        final html = await TemplateGenerator(_api).confirmEmail(userLanguage, emailConfirmationToken);

        await sendMessageToUser(
          _api,
          session,
          messageTypes: [MessageType.email],
          userId: userId,
          subject: _api.tr(userLanguage, LangKeys.mailConfirmEmailSubject.tr()),
          body: html,
          bodyIsHtml: true,
          //body: _api.tr(userLanguage, LangKeys.mailConfirmEmailBody.tr(),
          //    args: [link, emailConfirmationTokenDuration.inDays.toString()]),
        );

        //

        return _api.json({"userId": userId, "refreshToken": refreshToken, "accessToken": accessToken});
      });

  Future<Response> _confirmEmail(Request request, String token) async => withRequestLog((context) async {
        String sql = """
          SELECT user_id, language,
            meta->>'emailConfirmationExpiration' > NOW()::text AS valid
          FROM users
          WHERE meta->>'emailConfirmationToken' = @token
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {"token": token};

        log.logSql(context, sql, sqlParams);

        final rows = await _api.select(sql, params: sqlParams);
        final valid = (rows.firstOrNull?["valid"] as bool?) ?? false;
        final userLanguage = (rows.firstOrNull?["language"] as String?) ?? "en";

        if (!valid || rows.isEmpty) return _api.html(await TemplateGenerator(_api).linkExpired(userLanguage));

        final userId = rows.first["user_id"] as String;

        sql = """
          UPDATE users
          SET email_verified = TRUE, meta = meta - 'emailConfirmationToken' - 'emailConfirmationExpiration' - 'emailConfirmationSentAt',
              updated_at = NOW()
          WHERE user_id = @user_id
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "user_id": userId,
          "email_verified": true,
        };
        log.logSql(context, sql, sqlParams);

        final updated = await _api.update(sql, params: sqlParams);
        if (updated != 1) return _api.html(await TemplateGenerator(_api).operationFailed(userLanguage));

        final html = await TemplateGenerator(_api).emailConfirmed(userLanguage);
        return _api.html(html);
      });

  /// Sign in user.
  /// Http status codes: 200, 400, 401, 500
  ///
  Future<Response> _logIn(Request request) async => withRequestLog((context) async {
        final previousUserId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;

        final body = cast<JsonObject>(await request.body.asJson);
        final login = cast<String>(body?["login"]);
        final email = cast<String>(body?["email"]);

        if (login == null && email == null) return _api.badRequest(errorMissingParameter("login, email"));

        final password = cast<String>(body?["password"]);
        if (password == null) return _api.badRequest(errorMissingParameter("password"));

        if (installationId != cast<String>(body?["installationId"])) return _api.unauthorized(errorInvalidInstallation);

        var sql = """
          SELECT user_id, password_hash, password_salt, blocked
          FROM users
          WHERE (login = @login OR email = @email) AND deleted_at IS NULL
        """
            .tidyCode();

        var sqlParams = <String, dynamic>{"login": login, "email": email};

        log.logSql(context, sql, sqlParams);

        final results = await _api.select(sql, params: sqlParams);
        if (results.length != 1) return _api.unauthorized(errorInvalidCredentials);

        final row = results.first;
        final blocked = row["blocked"] as bool;
        if (blocked) return _api.unauthorized(errorAccountBlocked);
        final userId = row["user_id"] as String;
        final passwordHash = row["password_hash"] as String;
        final checkPassword = BCrypt.checkpw(password, passwordHash);
        if (!checkPassword) return _api.unauthorized(errorInvalidCredentials);

        // Update installation

        sql = """
          UPDATE installations
          SET user_id = @user_id, updated_at = NOW()
          WHERE installation_id = @installation_id
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "installation_id": installationId,
          "user_id": userId,
        };

        log.logSql(context, sql, sqlParams);

        final affectedInstallations = await _api.update(sql, params: sqlParams);
        if (affectedInstallations != 1) return _api.internalError(errorNoInstallation);

        if (previousUserId != userId) {
          sql = "UPDATE users SET deleted_at = NOW() WHERE user_id = @user_id AND login IS NULL AND email IS NULL";
          sqlParams = {"user_id": previousUserId};
          log.logSql(context, sql, sqlParams);
          final anonymousUserAffected = await _api.update(sql, params: sqlParams);
          if (anonymousUserAffected != 1) {
            // TODO: to bol prihlásený user, dalo mu invalid refresh token, takže sa išiel prihlásiť ako iný user
            // ale UPDATE nezbehne, lebo má email... => nebol anonymný... chyba bude pri spracovaní v startup
            log.warning("User not deleted. previousUserId = $previousUserId");
            //return _api.internalError(errorBrokenLogicEx("User not deleted"));
          }
        }

        //await SqlCache().clear(_api.redis, "user:$userId");
        await Cache().clearAll(_api.redis, CacheKeys.user(userId));
        await _api.clearSession(installationId);
        await _api.getSession(installationId);

        final refreshToken = await issueRefreshToken(_api, userId: userId);
        final accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});

        return _api.json({"userId": userId, "refreshToken": refreshToken, "accessToken": accessToken});
      });

  ///
  /// Http status codes: 200, 400, 401, 500
  ///
  Future<Response> _logOut(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        await _api.clearSession(installationId);
        //await SqlCache().clear(_api.redis, "user:${session.userId}");
        await Cache().clearAll(_api.redis, CacheKeys.user(session.userId));

        // TODO: zneplatniť accessToken a refreshToken

        // Create new anonymous user

        final userId = uuid();
        String sql = """
          INSERT INTO users(user_id, language, country, created_at) 
          VALUES (@user_id, @language, @country, NOW())
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {
          "user_id": userId,
          "language": session.language,
          "country": session.country?.code,
        };

        log.logSql(context, sql, sqlParams);

        final insertedUsers = await _api.insert(sql, params: sqlParams);
        if (insertedUsers != 1) return _api.internalError(errorBrokenLogicEx("User not created"));

        // Update installation

        sql =
            "UPDATE installations SET user_id = @user_id, updated_at = NOW() WHERE installation_id = @installation_id";
        sqlParams = <String, dynamic>{"installation_id": installationId, "user_id": userId};

        log.logSql(context, sql, sqlParams);

        final affectedInstallations = await _api.update(sql, params: sqlParams);
        if (affectedInstallations != 1) return _api.internalError(errorNoInstallation);

        // Clear previous cache... Why? User is newly created!
        // await SqlCache().clear(_api.redis, "user:$userId");
        await _api.getSession(installationId);

        final refreshToken = await issueRefreshToken(_api, userId: userId);
        final accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});

        return _api.json({"userId": userId, "refreshToken": refreshToken, "accessToken": accessToken});
      });

  Future<Response> _detail(Request request) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;

        final sql = """
          SELECT user_id, email, login, user_type, nick, gender, yob, language, country, 
            theme, folders, client_id, roles,
            jsonb_build_object('rating', meta->'rating') AS meta
          FROM users
          WHERE user_id = @user_id AND deleted_at IS NULL AND blocked = FALSE
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"user_id": userId};

        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.user(userId);
        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          log.logSql(context, sql, sqlParams);

          final rows = await _api.select(sql, params: sqlParams);
          if (rows.length != 1) return _api.notFound(errorNoUser);

          final user = User.fromMap(rows.first, User.snake);

          json = user.toMap(User.camel);
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, "user": json});
      });

  Future<Response> _update(Request request) async => withRequestLog((context) async {
        //final installationId = request.context["iid"] as String;
        final userId = request.context["uid"] as String;

        final body = (await request.body.asJson) as JsonObject;
        if (userId != body["userId"]) return _api.badRequest(errorBrokenLogic);

        final sql = """
          UPDATE users
          SET nick = @nick, gender = @gender, yob = COALESCE(@yob, yob), language = COALESCE(@language, language),
              country = COALESCE(@country, country), theme = COALESCE(@theme, theme), 
              folders = COALESCE(@folders, folders),
              meta = COALESCE(@meta, meta),
              updated_at = NOW()
          WHERE user_id = @user_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_id": userId,
          "nick": body["nick"] as String?,
          "gender": body["gender"] as int?,
          "yob": body["yob"] as int?,
          "language": body["language"] as String?,
          "country": body["country"] as String?,
          "theme": body["theme"] as int?,
          "folders": body["folders"] as Map<String, dynamic>?,
          "meta": body["meta"] as Map<String, dynamic>?,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await _api.update(sql, params: sqlParams);
        if (updated != 1) return _api.internalError(errorBrokenLogicEx("User not updated"));

        //await SqlCache().clear(_api.redis, "user:$userId");
        //await clearSession(_api, installationId);
        final cacheKey = CacheKeys.user(userId);
        await Cache().clearAll(_api.redis, cacheKey);

        return _api.json({"affected": updated});
      });

  Future<Response> _delete(Request request) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;

        final sql = "UPDATE users SET deleted_at = NOW() WHERE user_id = @user_id".tidyCode();
        final sqlParams = <String, dynamic>{"user_id": userId};

        log.logSql(context, sql, sqlParams);

        final updated = await _api.update(sql, params: sqlParams);
        if (updated != 1) return _api.internalError(errorBrokenLogicEx("User not deleted"));

        //await SqlCache().clear(_api.redis, "user:$userId");
        await Cache().clearAll(_api.redis, CacheKeys.user(userId));

        return _api.json({"affected": updated});
      });

  Future<Response> _listAddresses(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final cached = int.tryParse(query["cache"] ?? "");
        final noCache = tryParseBool(query["noCache"]) ?? false;

        final (json, isCached) = await UserAddressDAO(session, context).list(cached, noCache);
        if (isCached) return _api.cached();

        if (json == null) return _api.noContent();

        return _api.json(json);
      });

  Future<Response> _createAddress(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = (await request.body.asJson) as JsonObject;
        body[UserAddress.camel[UserAddressKeys.userId]!] = session.userId;
        if (body[UserAddress.camel[UserAddressKeys.userAddressId]!] == null) {
          body[UserAddress.camel[UserAddressKeys.userAddressId]!] = uuid();
        }
        final address = UserAddress.fromMap(body, Convention.camel);

        final inserted = await UserAddressDAO(session, context).insert(address);
        if (inserted != 1) return _api.internalError(errorBrokenLogicEx("User card not created"));

        await Cache().clearAll(_api.redis, CacheKeys.userUserAddress(session.userId));

        return _api.created({"affected": inserted});
      });

  Future<Response> _updateAddress(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = (await request.body.asJson) as JsonObject;
        body[UserAddress.camel[UserAddressKeys.userId]!] = session.userId;
        final address = UserAddress.fromMap(body, Convention.camel);

        final updated = await UserAddressDAO(session, context).update(address);
        if (updated != 1) return _api.internalError(errorBrokenLogicEx("User card not updated"));

        await Cache().clearAll(_api.redis, CacheKeys.userUserAddress(session.userId));

        return _api.accepted({"affected": updated});
      });

  Future<Response> _deleteAddress(Request request, String addressId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final deleted = await UserAddressDAO(session, context).delete(addressId);
        if (deleted != 1) return _api.internalError(errorBrokenLogicEx("User card not deleted"));

        await Cache().clearAll(_api.redis, CacheKeys.userUserAddress(session.userId));

        return _api.accepted({"affected": deleted});
      });

  Future<Response> _changePasswordRequest(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = (await request.body.asJson) as JsonObject;
        final email = body["email"] as String?;
        final password = body["password"] as String?;

        if (email == null) return _api.badRequest(errorMissingParameter("email"));
        if (password == null) return _api.badRequest(errorMissingParameter("password"));

        final passwordSalt = BCrypt.gensalt();
        final passwordHash = BCrypt.hashpw(password, passwordSalt);

        final changePasswordToken = uuid();

        String sql = """
          UPDATE users 
          SET meta = COALESCE(meta, '{}')::jsonb || 
                '{  "changedPasswordHash": "$passwordHash", 
                    "changedPasswordSalt": "$passwordSalt",
                    "changedPasswordToken": "$changePasswordToken",
                    "changedPasswordExpiration": "${DateTime.now().toUtc().add(Duration(days: 1)).toIso8601String()}"
                 }'::jsonb,
              updated_at = NOW() 
          WHERE email = @email AND deleted_at IS NULL
        """
            .tidyCode();
        Map<String, dynamic> sqlParams = {"email": email};

        log.verbose(sql);
        log.verbose(sqlParams.toString());

        final updated = await _api.update(sql, params: sqlParams);
        if (updated != 1) return _api.internalError(errorBrokenLogicEx("Request not updated"));

        sql = "SELECT user_id, language FROM users WHERE email = @email AND deleted_at IS NULL";
        final results = await _api.select(sql, params: sqlParams);
        if (results.isNotEmpty) {
          final row = results.first;
          final userId = row["user_id"] as String;
          final userLanguage = (row["language"] as String?) ?? "en";

          final html = await TemplateGenerator(_api).changePasswordRequest(userLanguage, changePasswordToken);

          await sendMessageToUser(
            _api,
            session,
            messageTypes: [MessageType.email],
            userId: userId,
            subject: _api.tr(userLanguage, LangKeys.mailChangePasswordRequestSubject.tr()),
            body: html,
            bodyIsHtml: true,
          );
        }

        return _api.json({"affected": updated});
      });

  Future<Response> _changePassword(Request request, String token) async => withRequestLog((context) async {
        String sql = """
          SELECT user_id, language, 
            meta->>'changedPasswordHash' AS password_hash, meta->>'changedPasswordSalt' AS password_salt,
            password_salt, meta->>'changedPasswordExpiration' > NOW()::TEXT AS valid
          FROM users
          WHERE meta->>'changedPasswordToken' = @token
      """
            .tidyCode();

        Map<String, dynamic> sqlParams = {"token": token};

        log.logSql(context, sql, sqlParams);

        final rows = await _api.select(sql, params: sqlParams);
        final valid = (rows.firstOrNull?["valid"] as bool?) ?? false;
        final userLanguage = (rows.firstOrNull?["language"] as String?) ?? "en";

        if (!valid) return _api.html(await TemplateGenerator(_api).linkExpired(userLanguage));

        final row = rows.first;
        final language = row["language"] as String;

        final html = await TemplateGenerator(_api).changePassword(language, token);
        return _api.html(html);
      });

  Future<Response> _confirmPassword(Request request, String token) async => withRequestLog((context) async {
        String sql = """
          SELECT user_id, language, 
            meta->>'changedPasswordHash' AS password_hash, meta->>'changedPasswordSalt' AS password_salt,
            meta->>'changedPasswordExpiration' > NOW()::text AS valid
          FROM users
          WHERE meta->>'changedPasswordToken' = @token
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {"token": token};

        log.logSql(context, sql, sqlParams);

        final rows = await _api.select(sql, params: sqlParams);
        final valid = (rows.firstOrNull?["valid"] as bool?) ?? false;
        final userLanguage = (rows.firstOrNull?["language"] as String?) ?? "en";

        if (!valid) return _api.html(await TemplateGenerator(_api).linkExpired(userLanguage));

        final row = rows.first;
        final userId = row["user_id"] as String;
        final language = row["language"] as String;
        final passwordHash = row["password_hash"] as String;
        final passwordSalt = row["password_salt"] as String;

        sql = """
          UPDATE users
          SET 
            password_hash = @password_hash, 
            password_salt = @password_salt, 
            meta = meta - 'changedPasswordHash' - 'changedPasswordSalt' - 'changedPasswordToken'- 'changedPasswordExpiration',
            updated_at = NOW()
          WHERE user_id = @user_id
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "user_id": userId,
          "password_hash": passwordHash,
          "password_salt": passwordSalt,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await _api.update(sql, params: sqlParams);
        if (updated != 1) return _api.html(await TemplateGenerator(_api).operationFailed(userLanguage));

        final html = await TemplateGenerator(_api).passwordChanged(language);
        return _api.html(html);
      });

  // /v1/user
  Router get router {
    final router = Router();

    router.post("/startup", _startup);
    router.post("/anonymous", _anonymous);
    router.post("/register", _register);
    router.post("/login", _logIn);
    router.post("/logout", _logOut);
    router.put("/device_token", _updateDeviceToken);
    router.get("/address", _listAddresses);
    router.post("/address", _createAddress);
    router.put("/address", _updateAddress);
    router.delete("/address/<id|${_api.idRegExp}>", _deleteAddress);
    router.get("/", _detail);
    router.put("/", _update);
    router.delete("/", _delete);
    router.patch("/password", _changePasswordRequest);
    router.get("/password/confirm/<token|${_api.idRegExp}>", _changePassword);
    router.post("/password/confirm/<token|${_api.idRegExp}>", _confirmPassword);
    router.get("/email/confirm/<token|${_api.idRegExp}>", _confirmEmail);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

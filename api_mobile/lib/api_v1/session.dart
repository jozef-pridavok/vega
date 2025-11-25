import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../cache.dart";
import "../data_models/session.dart";

const String _getSessionQuery = """
  SELECT i.installation_id, i.device_token,
    u.user_id, u.user_type, u.login, u.email, u.client_id, u.roles, u.language, u.country, i.device_info,
    COALESCE((device_info#>'{timeZoneOffset}')::INT, 0) as time_zone_offset
  FROM installations i    
  INNER JOIN users AS u ON i.user_id = u.user_id
  WHERE i.installation_id = @installation_id AND i.deleted_at IS NULL AND u.deleted_at IS NULL
""";

//

extension ApiServer2Session on ApiServer2 {
  Future<Session?> _getSession(String installationId) async {
    try {
      final json = await Cache().getJson(redis, CacheKeys.session(installationId));
      if (json == null) return null;
      return Session.fromJson(json);
    } catch (ex) {
      log.error("Error getting session: $ex");
      return null;
    }
  }

  Future<Session> getSession(String installationId) async {
    var session = await _getSession(installationId);
    if (session != null) return session;

    final rows = await select(
      _getSessionQuery,
      params: {"installation_id": installationId},
    );

    if (rows.isEmpty) return throw errorInvalidInstallation;
    final row = rows.first;

    session = Session(
      installationId: row["installation_id"] as String,
      userId: row["user_id"] as String,
      userType: UserTypeCode.fromCodeOrNull(row["user_type"] as int?),
      login: row["login"] as String?,
      email: row["email"] as String?,
      userRoles: UserRoleCode.fromCodes(row["roles"] as List<int>?),
      language: row["language"] as String?,
      country: CountryCode.fromCodeOrNull(row["country"] as String?),
      clientId: row["client_id"] as String?,
      timeZoneOffset: row["time_zone_offset"] as int,
    );

    await Cache().putJson(redis, CacheKeys.session(installationId), session.toJson());
    return session;
  }

  Future<void> clearSession(String installationId) async {
    final key = CacheKeys.session(installationId);
    await redis(["DEL", key]);
  }
}

// eof

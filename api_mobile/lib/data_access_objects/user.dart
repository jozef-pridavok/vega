import "package:bcrypt/bcrypt.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class UserDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  UserDAO(this.session, this.context) : super(context.api);

  Future<bool> isLoginAvailable(String login, {String? exceptUserId}) async => withSqlLog(context, () async {
        final sql = """
          SELECT COUNT(*) 
          FROM users 
          WHERE login = @login 
          ${exceptUserId != null ? ' AND user_id != @except_user_id' : ''}
          AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"login": login};
        if (exceptUserId != null) sqlParams["except_user_id"] = exceptUserId;

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return cast<int>(rows.firstOrNull?["count"]) == 0;
      });

  Future<bool> isEmailAvailable(String email) async => withSqlLog(context, () async {
        final sql = "SELECT COUNT(*) FROM users WHERE email = @email AND deleted_at IS NULL";
        final sqlParams = <String, dynamic>{"email": email};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return cast<int>(rows.firstOrNull?["count"]) == 0;
      });

  Future<User?> selectById(String userId) async => withSqlLog(context, () async {
        final sql = """
          SELECT user_id, client_id, login, email, nick, roles, user_type, 
            language, folders, blocked, meta
          FROM users
          WHERE user_id = @user_id AND deleted_at IS NULL
        """;
        final sqlParams = <String, dynamic>{
          "user_id": userId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return User.fromMap(rows.first, User.snake);
      });

  Future<User?> selectByUserCardNumber(String number) async => withSqlLog(context, () async {
        final sql = """
          SELECT u.*
          FROM users u
          INNER JOIN user_cards uc ON uc.user_id = u.user_id
          WHERE u.deleted_at IS NULL AND uc.active = TRUE AND uc.client_id = @client_id AND uc.number = @number
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"number": number, "client_id": session.clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        final row = rows.firstOrNull;
        return row != null ? User.fromMap(row, User.snake) : null;
      });

  Future<int> createForClient(User user, String password) async => withSqlLog(context, () async {
        final login = user.login?.toLowerCase();
        if (login == null) return throw errorMissingParameter("login");

        if (await isLoginAvailable(login) == false) throw errorUserAlreadyExists;

        final passwordSalt = BCrypt.gensalt();
        final passwordHash = BCrypt.hashpw(password, passwordSalt);

        user.roles.removeWhere((role) => role == UserRole.owner || role == UserRole.seller);

        final sql = """
          INSERT INTO users(user_id, client_id, login, nick, password_hash, password_salt, user_type, roles, meta, created_at, updated_at)
          VALUES (@user_id, @client_id, @login, @nick, @password_hash, @password_salt, @user_type, @roles, @meta, NOW(), NOW())
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_id": user.userId,
          "client_id": user.clientId,
          "login": user.login,
          "nick": user.nick,
          "password_hash": passwordHash,
          "password_salt": passwordSalt,
          "user_type": UserType.client.code,
          "roles": "{${user.roles.map((e) => e.code).join(',')}}",
          "meta": user.meta,
        };

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> updateForClient(User user, String? password) async => withSqlLog(context, () async {
        final login = user.login?.toLowerCase();
        if (login == null) return throw errorMissingParameter("login");

        if (await isLoginAvailable(login, exceptUserId: user.userId) == false) throw errorUserAlreadyExists;

        user.roles.removeWhere((role) => role == UserRole.owner || role == UserRole.seller);

        final changePassword = password != null;
        final passwordSalt = changePassword ? BCrypt.gensalt() : null;
        final passwordHash = changePassword ? BCrypt.hashpw(password, passwordSalt!) : null;

        final sql = """
          UPDATE users SET
            login = COALESCE(@login, login), 
            nick = COALESCE(@nick, nick),
            roles = COALESCE(@roles, roles),
            meta = COALESCE(@meta, meta),
            ${changePassword ? 'password_hash = @password_hash, password_salt = @password_salt, ' : ''}          
            updated_at = NOW()
          WHERE user_id = @user_id AND client_id = @client_id AND deleted_at IS NULL
        """;

        final sqlParams = <String, dynamic>{
          "user_id": user.userId,
          "client_id": user.clientId,
          "login": user.login,
          "nick": user.nick,
          "roles": "{${user.roles.map((e) => e.code).join(',')}}",
          if (changePassword) "password_hash": passwordHash,
          if (changePassword) "password_salt": passwordSalt,
          "meta": user.meta,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> updateDataForClientUser(User user) async => withSqlLog(context, () async {
        final sql = """
          UPDATE users SET
            meta = COALESCE(@meta, meta),
            roles = COALESCE(@roles, roles),
            updated_at = NOW()
          WHERE user_id = @user_id
        """;

        final sqlParams = <String, dynamic>{
          "user_id": user.userId,
          "roles": "{${user.roles.map((e) => e.code).join(',')}}",
          "meta": user.meta,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patchForClient(String userId, {bool? blocked, bool? archived}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE users SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE user_id = @user_id
        """;

        final sqlParams = <String, dynamic>{"user_id": userId};
        if (blocked != null) sqlParams["blocked"] = blocked ? 1 : 0;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> updateUserRating(String userId, int rating) async => withSqlLog(context, () async {
        final sql = """
          UPDATE users 
          SET 
            meta = jsonb_set(
              meta, 
              '{rating}', 
              to_jsonb(@rating), 
              true
            ),
            updated_at = NOW()
          WHERE user_id = @user_id
        """;

        final sqlParams = <String, dynamic>{"user_id": userId, "rating": rating};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof

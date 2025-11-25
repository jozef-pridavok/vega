import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../cache.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../data_access_objects/user.dart";
import "../../data_access_objects/user_rating.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class ClientUserHandler extends ApiServerHandler {
  ClientUserHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos, UserRole.seller]))
          return api.forbidden(errorUserRoleMissing);

        String? clientId = session.clientId;

        if (session.userRoles.contains(UserRole.seller)) {
          final query = request.url.queryParameters;
          clientId = query["clientId"];
        }

        if (clientId == null) return api.forbidden(errorNoClientId);

        final clientDao = ClientDAO(session, context);
        final users = await clientDao.selectUsers(clientId);

        if (users.isEmpty) return api.noContent();

        return api.json({
          "length": users.length,
          "users": users.map((e) => e.toMap(User.camel)).toList(),
        });
      });

  Future<Response> _create(Request request, String userId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["userId"] != userId)
          return api.badRequest(errorBrokenLogicEx("User id in body is not same as in url"));

        if (session.userRoles.contains(UserRole.admin) && body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final password = body["password"] as String?;
        if ((password?.length ?? 0) < 6) return api.badRequest(errorBrokenLogicEx("Password is too short"));

        final user = User.fromMap(body, User.camel);
        final inserted = await UserDAO(session, context).createForClient(user, password!);

        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String userId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["userId"] != userId)
          return api.badRequest(errorBrokenLogicEx("User id in body is not same as in url"));

        final user = User.fromMap(body, User.camel);

        final updated = body["password"] != null
            ? await UserDAO(session, context).updateForClient(user, body["password"] as String?)
            : await UserDAO(session, context).updateDataForClientUser(user);

        if (updated > 0) {
          await Cache().clear(api.redis, CacheKeys.user(userId));
          // TODO: refactor session to use only user cache
          await Cache().clearAll(api.redis, CacheKeys.session("*"));
        }

        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String userId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        if (userId == session.userId) return api.badRequest(errorBrokenLogicEx("Can not block or archive yourself"));

        final body = await request.body.asJson;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (blocked == null && archived == null) return api.badRequest(errorBrokenLogicEx("blocked or archived"));

        final patched = await UserDAO(session, context).patchForClient(userId, blocked: blocked, archived: archived);
        return api.accepted({"affected": patched});
      });

  Future<Response> _rating(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final clientId = session.clientId!;
        final body = await request.body.asJson;
        final userId = body["userId"] as String;

        final rating = tryParseInt(body["rating"]);
        if (rating == null || rating < 0 || rating > 5)
          return api.badRequest(errorInvalidParameterType("Invalid rating", "value between 0 and 5"));
        final dao = UserRatingDAO(context);
        await dao.upsert(
          clientId: clientId,
          userId: userId,
          rating: body["rating"] as int,
          language: session.language!,
          comment: body["comment"] as String?,
        );

        final newUserRating = await dao.getUserRating(userId: userId);

        int? updated;
        if (newUserRating != null) {
          updated = await UserDAO(session, context).updateUserRating(userId, newUserRating);

          final cacheKey = CacheKeys.user(userId);
          await Cache().clearAll(api.redis, cacheKey);
        }

        return api.accepted({"affected": updated ?? 0});
      });

  // /v1/dashboard/client_user
  Router get router {
    final router = Router();

    router.patch("/<userId|$idRegExp>", _patch);
    router.put("/<userId|$idRegExp>", _update);
    router.post("/<userId|$idRegExp>", _create);
    router.post("/rating", _rating);

    router.get("/", _list);

    return router;
  }
}

// eof

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../cache.dart";
import "../../data_access_objects/location.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class LocationHandler extends ApiServerHandler {
  LocationHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final locations = await LocationDAO(session, context).list();

        final dataObject = locations.map((e) => e.toMap(Location.snake)).toList();
        return api.json({
          "length": dataObject.length,
          "locations": dataObject,
        });
      });

  Future<Response> _create(Request request, String locationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final location = Location.fromMap(body, Location.camel);
        final inserted = await LocationDAO(session, context).insert(location);

        if (inserted > 0) {
          final cacheKey = CacheKeys.locations(session.clientId!);
          await Cache().clear(api.redis, cacheKey);
        }

        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String locationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final location = Location.fromMap(body, Location.camel);
        final updated = await LocationDAO(session, context).update(location);

        if (updated > 0) {
          final cacheKey = CacheKeys.locations(session.clientId!);
          await Cache().clear(api.redis, cacheKey);
        }

        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String locationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        if (archived == null) return api.badRequest(errorBrokenLogicEx("archived is null"));

        final patched = await LocationDAO(session, context).patch(locationId, archived: archived);

        if (patched > 0) {
          final cacheKey = CacheKeys.locations(session.clientId!);
          await Cache().clear(api.redis, cacheKey);
        }

        return api.accepted({"affected": patched});
      });

  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final locations = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (locations?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));

        final reordered = await LocationDAO(session, context).reorder(locations!);

        if (reordered > 0) {
          final cacheKey = CacheKeys.locations(session.clientId!);
          await Cache().clear(api.redis, cacheKey);
        }

        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/location
  Router get router {
    final router = Router();

    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.get("/", _list);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

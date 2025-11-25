import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../check_role.dart";
import "../session.dart";

class LogHandler extends ApiServerHandler {
  LogHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.development])) return api.forbidden(errorUserRoleMissing);

        return api.internalError(errorCancelled);
      });

  Future<Response> _random(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.development])) return api.forbidden(errorUserRoleMissing);

        throw Exception("Random error :${DateTime.now()}");
      });

  // /v1/dashboard/log/
  Router get router {
    final router = Router();

    router.post("/random", _random);

    router.get("/", _list);

    return router;
  }
}

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/qr_tag.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";
import "../session.dart";

class QrTagHandler extends ApiServerHandler {
  QrTagHandler(super.api);

  /// Returns list of qr_tags for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Parameters: filter, limit.
  ///   filter: 1 - unused, 2 - used. Default is 1.
  ///   limit: number of records to return. Skip to return all qr_tags.
  ///   period: number of days to query used tags (used tags only) (optional, default: 30)
  Future<Response> _list(Request request, String programId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final query = request.url.queryParameters;
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");
        final period = tryParseInt(query["period"]) ?? 7;
        final dao = QrTagDAO(session, context);
        final qrTags = await dao.list(programId, filter: filter, limit: limit, period: period);
        final json = qrTags.map((qrTag) {
          return qrTag.toMap(QrTag.camel);
        }).toList();
        return api.json({
          "length": json.length,
          "qr_tags": json,
        });
      });

  /// Creates new qr_tag(s).
  /// Required roles: pos or admin
  /// Response status codes: 201, 400, 401, 403, 500
  /// Required body parameters: qrTagId, programId, points
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _createMany(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final List<QrTag> newQrTags = (body["qrTagIds"] as List<dynamic>).map<QrTag>((qrTagId) {
          return QrTag(
            qrTagId: qrTagId as String,
            clientId: session.clientId!,
            programId: body["programId"] as String,
            points: body["points"] as int,
          );
        }).toList();

        final dao = QrTagDAO(session, context);
        final inserted = await dao.insertMany(newQrTags);
        return api.created({"affected": inserted});
      });

  Future<Response> _deleteMany(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        if (!body.containsKey("qrTagIds") || body["qrTagIds"] is! List)
          return api.badRequest(errorBrokenLogicEx("qrTagIds list is missing or not a list"));
        final List<String> qrTagIds = [];
        for (final qrTagId in body["qrTagIds"]) {
          if (qrTagId is! String) return api.badRequest(errorBrokenLogicEx("qrTagIds list contains non-string items"));
          qrTagIds.add(qrTagId);
        }
        final dao = QrTagDAO(session, context);
        final deleted = await dao.deleteMany(qrTagIds);
        return api.accepted({"affected": deleted});
      });

  // /v1/dashboard/qr_tag
  Router get router {
    final router = Router();

    router.get("/<id|$idRegExp>", _list);
    router.post("/create_many", _createMany);
    router.put("/delete_many", _deleteMany);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

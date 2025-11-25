import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/dashboard/product_item_modification.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class ProductItemModificationHandler extends ApiServerHandler {
  ProductItemModificationHandler(super.api);

  Future<Response> _listForItem(Request request, String productItemId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final productItemModifications =
            await ProductItemModificationDAO(session, context).listForItem(productItemId: productItemId);
        final dataObject = productItemModifications.map((e) => e.toMap(Convention.snake)).toList();
        return api.json({
          "length": dataObject.length,
          "productItemModifications": dataObject,
        });
      });

  Future<Response> _create(Request request, String productItemModificationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productItemModification = ProductItemModification.fromMap(body, Convention.camel);
        final inserted = await ProductItemModificationDAO(session, context).insert(productItemModification);
        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String productItemModificationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productItemModification = ProductItemModification.fromMap(body, Convention.camel);
        final updated = await ProductItemModificationDAO(session, context).update(productItemModification);
        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String productItemModificationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        final blocked = tryParseBool(body["blocked"]);
        if (archived == null && blocked == null)
          return api.badRequest(errorBrokenLogicEx("archived and blocked are both null"));
        final patched = await ProductItemModificationDAO(session, context).patch(
          productItemModificationId,
          archived: archived,
          blocked: blocked,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple ProductItemModification(s).
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reorder": ["modificationId9", "modificationId6", "modificationId1" ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final modifications = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (modifications?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ProductItemModificationDAO(session, context).reorder(modifications!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/product_item_modification
  Router get router {
    final router = Router();

    router.get("/<id|$idRegExp>", _listForItem);
    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

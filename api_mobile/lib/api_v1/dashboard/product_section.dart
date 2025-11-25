import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/dashboard/product_section.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class ProductSectionHandler extends ApiServerHandler {
  ProductSectionHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final productSections = await ProductSectionDAO(session, context).list();

        final dataObject = productSections.map((e) => e.toMap(Convention.snake)).toList();
        return api.json({
          "length": dataObject.length,
          "productSections": dataObject,
        });
      });

  Future<Response> _create(Request request, String productSectionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productSection = ProductSection.fromMap(body, Convention.camel);
        final inserted = await ProductSectionDAO(session, context).insert(productSection);
        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String productSectionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productSection = ProductSection.fromMap(body, Convention.camel);
        final updated = await ProductSectionDAO(session, context).update(productSection);
        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String productSectionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        final blocked = tryParseBool(body["blocked"]);
        if (archived == null && blocked == null)
          return api.badRequest(errorBrokenLogicEx("archived and blocked are both null"));
        final patched = await ProductSectionDAO(session, context).patch(
          productSectionId,
          archived: archived,
          blocked: blocked,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple programs.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reorder": ["productSection6", "productSection1", "productSection3" ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final productSections = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (productSections?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final updated = await ProductSectionDAO(session, context).reorder(productSections!);
        return api.accepted({"affected": updated});
      });

  // /v1/dashboard/product_section
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

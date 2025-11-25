import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/dashboard/product_item_option.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class ProductItemOptionHandler extends ApiServerHandler {
  ProductItemOptionHandler(super.api);

  Future<Response> _list(Request request, String itemId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final options = await ProductItemOptionDAO(session, context).list(itemId: itemId);
        final dataObject = options.map((e) => e.toMap(Convention.snake)).toList();
        return api.json({
          "length": dataObject.length,
          "productItemOptions": dataObject,
        });
      });

  Future<Response> _create(Request request, String productItemOptionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        final productItemOption = ProductItemOption.fromMap(body, Convention.camel);
        final inserted = await ProductItemOptionDAO(session, context).insert(productItemOption);
        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String productItemOptionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        final productItemOption = ProductItemOption.fromMap(body, Convention.camel);
        final updated = await ProductItemOptionDAO(session, context).update(productItemOption);
        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String productItemOptionId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        final blocked = tryParseBool(body["blocked"]);
        if (archived == null && blocked == null)
          return api.badRequest(errorBrokenLogicEx("archived and blocked are both null"));
        final patched = await ProductItemOptionDAO(session, context).patch(
          productItemOptionId,
          archived: archived,
          blocked: blocked,
        );
        return api.accepted({"affected": patched});
      });

  // /v1/dashboard/product_item_option
  Router get router {
    final router = Router();

    router.get("/<id|$idRegExp>", _list);
    router.post("/<id|$idRegExp>", _create);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

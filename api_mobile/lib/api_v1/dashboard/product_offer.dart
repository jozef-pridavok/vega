import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/dashboard/product_offer.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";

class ProductOfferHandler extends ApiServerHandler {
  ProductOfferHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final productOffers = await ProductOfferDAO(session, context).list(filter: filter);

        final dataObject = productOffers.map((e) => e.toMap(Convention.snake)).toList();
        return api.json({
          "length": dataObject.length,
          "productOffers": dataObject,
        });
      });

  Future<Response> _create(Request request, String productOfferId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productOffer = ProductOffer.fromMap(body, Convention.camel);
        final inserted = await ProductOfferDAO(session, context).insert(productOffer);
        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String productOfferId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);

        final body = await request.body.asJson;

        if (body["clientId"] != session.clientId)
          return api.badRequest(errorBrokenLogicEx("Client id in body is not same as in session"));

        final productOffer = ProductOffer.fromMap(body, Convention.camel);
        final updated = await ProductOfferDAO(session, context).update(productOffer);
        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String productOfferId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        final blocked = tryParseBool(body["blocked"]);
        if (archived == null && blocked == null)
          return api.badRequest(errorBrokenLogicEx("archived and blocked are both null"));
        final patched = await ProductOfferDAO(session, context).patch(
          productOfferId,
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
  /// { "reorder": ["productOffer6", "productOffer1", "productOffer3" ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final productItems = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (productItems?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ProductOfferDAO(session, context).reorder(productItems!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/product_offer
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

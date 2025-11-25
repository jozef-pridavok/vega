import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/product_order.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";
import "../session.dart";

class ProductOrderHandler extends ApiServerHandler {
  ProductOrderHandler(super.api);

  /// Returns list of product orders for client.
  /// Required roles: pos or admin
  /// Parameters: filter, limit.
  ///   filter: 1 - orders in created, accepted, ready, inProgress, dispatched, delivered state
  ///           2 - orders in cancelled, returned, closed state
  ///   limit: number of records to return. Skip to return all product orders.
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");

        final orders = await ProductOrderDAO(session, context).list(filter: filter, limit: limit);

        final json = orders.map((e) => e.toMap(Convention.camel)).toList();
        return api.json({
          "length": json.length,
          "userOrders": json,
        });
      });

  Future<Response> _listItems(Request request, String productOrderId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final productOrderDAO = ProductOrderDAO(session, context);
        final userOrderItems = await productOrderDAO.listOrderItems(productOrderId);

        final dataObject = userOrderItems.map((e) => e.toMap(Convention.camel)).toList();
        return api.json({
          "length": dataObject.length,
          "userOrderItems": dataObject,
        });
      });

  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 500
  /// Notes:
  ///  product_order_id is determined by the path parameter.
  ///  client_id is determined by the session.
  Future<Response> _patch(Request request, String productOrderId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final status = tryParseInt(body["status"]);
        final cancelledReason = body["cancelledReason"] as String?;
        final deliveryEstimate = body["deliveryEstimate"] as String?;
        if (status == null) return api.badRequest(errorBrokenLogicEx("status must not be null"));
        final patched = await ProductOrderDAO(session, context).patch(
          productOrderId,
          status: status,
          cancelledReason: cancelledReason,
          deliveryEstimate: deliveryEstimate,
        );
        return api.accepted({"affected": patched});
      });

  // /v1/dashboard/product_order
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.get("/items/<productOrderId|$idRegExp>", _listItems);
    router.patch("/<productOrderId|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

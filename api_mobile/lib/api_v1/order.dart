import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../data_access_objects/order.dart";
import "../extensions/request_body.dart";
import "../implementations/api_shelf2.dart";
import "session.dart";

class OrderHandler extends ApiServerHandler {
  final MobileApi _api;
  OrderHandler(this._api) : super(_api);

  Future<Response> _listCurrent(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final orders = await OrderDAO(session, context).list(clientId);
        if (orders.isEmpty) return _api.noContent();
        return _api.json({
          "length": orders.length,
          "orders": orders.map((e) => e.toMap(Convention.camel)).toList(),
        });
      });

  Future<Response> _create(Request request, String orderId) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = (await request.body.asJson) as JsonObject;

        final order = UserOrder.fromMap(body, Convention.camel);
        if (order.userId != userId) return _api.forbidden(errorBrokenSecurity);

        final orderDAO = OrderDAO(session, context);

        final created = await orderDAO.insert(order);
        return _api.created({"affected": created});
      });

  Future<Response> _patch(Request request, String orderId) async => withRequestLog((context) async {
        try {
          //final installationId = request.context["iid"] as String;
          //final session = await getSession(_api, installationId);

          final body = await request.body.asJson;
          final confirm = tryParseBool(body["confirm"]);
          if (confirm == null) return _api.badRequest(errorBrokenLogicEx("confirm"));
          /*
      final patched = await ReservationDateDAO(_api, session).patchReservation(dateId, confirm: confirm);
      return _api.accepted({"affected": patched});
      */
          throw UnimplementedError();
        } on CoreError catch (err, st) {
          log.error(err.toString());
          log.error(st.toString());
          return _api.internalError(err);
        } catch (ex, st) {
          log.error(ex.toString());
          log.error(st.toString());
          return _api.internalError(errorUnexpectedException(ex));
        }
      });

  // /v1/order
  Router get router {
    final router = Router();
    router.get("/current/<clientId|${_api.idRegExp}>", _listCurrent);
    //router.get("/items/<orderId|${_api.idRegExp}>", _listOrder);
    router.post("/<orderId|${_api.idRegExp}>", _create);
    router.patch("/<orderId|${_api.idRegExp}>", _patch);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

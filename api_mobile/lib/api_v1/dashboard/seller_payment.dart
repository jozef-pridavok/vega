import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/check_role.dart";
import "../../data_access_objects/client_payment.dart";
import "../../data_access_objects/seller_payment.dart";
import "../../extensions/request_body.dart";
import "../session.dart";

class SellerPaymentHandler extends ApiServerHandler {
  SellerPaymentHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;

        final dateFrom = IntDate.parseString(query["dateFrom"]);
        final dateTo = IntDate.parseString(query["dateTo"]);

        final onlyUnpaid = tryParseBool(query["onlyUnpaid"]) ?? false;

        final paymentDAO = SellerPaymentDAO(session, context);
        final paymentRows = await paymentDAO.readAll(
          onlyUnpaid: onlyUnpaid,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
        final payments = paymentRows.map((e) => e.toMap(SellerPayment.camel)).toList();

        return api.json({
          "length": payments.length,
          "payments": payments,
        });
      });

  Future<Response> _eligible(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final userId = request.context["uid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;

        final dateFrom = IntDate.parseString(query["dateFrom"]);
        final dateTo = IntDate.parseString(query["dateTo"]);
        final onlyReadyForRequest = tryParseBool(query["onlyReadyForRequest"]) ?? false;
        final onlyWaitingForClient = tryParseBool(query["onlyWaitingForClient"]) ?? false;

        final paymentDAO = ClientPaymentDAO(session, context);
        final paymentRows = await paymentDAO.forSeller(
          userId,
          onlyReadyForRequest: onlyReadyForRequest,
          onlyWaitingForClient: onlyWaitingForClient,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
        final payments = paymentRows.map((e) => e.toMap(ClientPayment.camel)).toList();

        return api.json({
          "length": payments.length,
          "payments": payments,
        });
      });

  Future<Response> _request(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final clientPaymentIds = cast<JsonArray>(body["payments"])?.cast<String>();
        if (clientPaymentIds == null) return api.badRequest(errorInvalidParameterType("payments", "Array of strings"));
        if (clientPaymentIds.isEmpty) return api.badRequest(errorInvalidParameterRange("payments", "Non empty array"));
        final invoiceNumber = cast<String>(body["invoiceNumber"]);
        if (invoiceNumber == null) return api.badRequest(errorInvalidParameterType("invoiceNumber", "String"));
        final dueDate = IntDate.parseInt(body["dueDate"] as int?);

        final paymentDAO = SellerPaymentDAO(session, context);
        final payment = await paymentDAO.request(clientPaymentIds, invoiceNumber, dueDate);

        return api.json(payment.toMap(SellerPayment.camel));
      });

  // /v1/dashboard/seller/payment
  Router get router {
    final router = Router();

    router.post("/request", _request);
    router.get("/eligible", _eligible);
    router.get("/", _list);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

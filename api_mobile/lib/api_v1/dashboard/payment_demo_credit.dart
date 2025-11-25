import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/client.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../session.dart";

class DemoCreditHandler extends ApiServerHandler {
  DemoCreditHandler(super.api);

  Future<Response> _start(Request request, String providerId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final dao = ClientDAO(session, context);
        var demoCredit = await dao.getDemoCredit(clientId);
        if (demoCredit == null || demoCredit <= 0) return api.noContent();

        final body = (await request.body.asJson) as JsonObject;
        final payments = cast<JsonArray>(body["payments"])?.cast<String>();
        if (payments == null) return api.badRequest(errorInvalidParameterType("payments", "Array of strings"));

        final amount = cast<int>(body["amount"]);
        if (amount == null) return api.badRequest(errorInvalidParameterType("amount", "Number"));

        final currency = CurrencyCode.fromCodeOrNull(body["currency"] as String?);
        if (currency == null) return api.badRequest(errorInvalidParameterType("currency", "String"));

        if (demoCredit < amount) return api.notAllowed(errorUnexpectedState);
        demoCredit -= amount;

        final updated = (await dao.setDemoCredit(clientId, demoCredit)) == 1;
        return updated ? api.ok() : api.forbidden(errorUnexpectedState);
      });

  // "/v1/dashboard/payment/demo_credit",
  Router get router {
    final router = Router();

    router.post("/start/<providerId|$idRegExp>", _start);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

import "dart:convert";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../implementations/api_shelf.dart";
import "cron_handler.dart";
import "data_access_objects/client_payment.dart";

class ClientPaymentHandler extends CronHandler<void> {
  ClientPaymentHandler(ApiServer2 api) : super("ClientPayments", api);

  @override
  Future<JsonObject> process(ApiServerContext context, void param) async {
    final paymentDAO = ClientPaymentDAO(context);
    final json = await paymentDAO.recalculate();
    await recordLastRun(json);
    return json;
  }

  Future<Response> _recalculate(Request req) async => withRequestLog((context) async {
        log.logRequest(context, req.toLogRequest());
        final json = await execute(context, null);
        log.verbose(json, jsonEncode);
        return api.json(json);
      });

  // /v1/client/payment
  Router get router {
    final router = Router();

    router.get("/recalculate", _recalculate);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

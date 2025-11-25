import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/client_payment.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../extensions/request_body.dart";
import "../session.dart";

class ClientPaymentHandler extends ApiServerHandler {
  ClientPaymentHandler(super.api);

  Future<Response> _list(Request request) => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final hasAdminRole = session.userRoles.contains(UserRole.admin);
        final allowedRole = hasAdminRole;
        if (!allowedRole) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;

        final dateFrom = IntDate.parseString(query["dateFrom"]);
        final dateTo = IntDate.parseString(query["dateTo"]);
        final onlyUnpaid = tryParseBool(query["unpaidOnly"]) ?? false;

        final paymentDAO = ClientPaymentDAO(session, context);
        final paymentRows = await paymentDAO.readAll(dateFrom: dateFrom, dateTo: dateTo, onlyUnpaid: onlyUnpaid);
        final payments = paymentRows.map((e) => e.toMap(ClientPayment.camel)).toList();

        final clientDAO = ClientDAO(session, context);
        final providerRows = await clientDAO.readPaymentProviders(session.clientId!);
        final providers = providerRows.map((e) => e.toMap(ClientPaymentProvider.camel)).toList();

        return api.json({
          "providers_length": providers.length,
          "providers": providers,
          "payments_length": payments.length,
          "payments": payments,
        });
      });

  Future<Response> _confirm(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final body = cast<JsonObject>(await request.body.asJson);

        final provider = body?["providerId"] as String?;
        if (provider == null) return api.badRequest(errorInvalidParameterType("providerId", "String"));

        final payments = cast<JsonArray>(body?["payments"])?.cast<String>();
        if (payments == null) return api.badRequest(errorInvalidParameterType("payments", "Array of strings"));

        final payload = cast<JsonObject>(body?["payload"]);

        final paymentDAO = ClientPaymentDAO(session, context);
        final (affectedPayments, affectedClient) = await paymentDAO.updatePayment(
          provider,
          clientId,
          payments,
          payload,
          ClientPaymentStatus.paid,
        );

        await Cache().clear(api.redis, CacheKeys.user(session.userId));
        await Cache().clearAll(api.redis, CacheKeys.client(clientId));

        return api.json({
          "affectedPayments": affectedPayments,
          "affectedClient": affectedClient,
        });
      });

  Future<Response> _cancel(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final body = cast<JsonObject>(await request.body.asJson);

        final provider = body?["providerId"] as String?;
        if (provider == null) return api.badRequest(errorInvalidParameterType("providerId", "String"));

        final payments = cast<JsonArray>(body?["payments"])?.cast<String>();
        if (payments == null) return api.badRequest(errorInvalidParameterType("payments", "Array of strings"));

        final payload = cast<JsonObject>(body?["payload"]);

        final paymentDAO = ClientPaymentDAO(session, context);
        final (affectedPayments, affectedClient) = await paymentDAO.updatePayment(
          provider,
          clientId,
          payments,
          payload,
          ClientPaymentStatus.canceled,
        );

        return api.json({
          "affectedPayments": affectedPayments,
          "affectedClient": affectedClient,
        });
      });

  // /v1/dashboard/client_payment
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.put("/confirm", _confirm);
    router.put("/cancel", _cancel);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

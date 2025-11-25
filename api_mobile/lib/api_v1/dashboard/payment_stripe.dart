import "package:core_dart/core_algorithm.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";
import "package:stripe/stripe.dart";

import "../../data_access_objects/client_payment.dart";
import "../../data_access_objects/client_payment_provider.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../data_models/session.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";

import "../session.dart";

class StripeHandler extends ApiServerHandler {
  StripeHandler(super.api);

  Future<Stripe> getStripeForProvider(ApiServerContext context, String providerId, Session session) async {
    final providerDAO = ClientPaymentProviderDAO(context);
    final stripePrivateKey = await providerDAO.getStripePrivateKey(providerId);
    if (stripePrivateKey == null) throw Exception("Stripe private key not found for provider $providerId");
    final cryptex = SimpleCipher(api.config.environment.name);
    final stripePrivateKeyDecrypted = cryptex.decrypt(stripePrivateKey);
    return Stripe(stripePrivateKeyDecrypted);
  }

  Future<Response> _start(Request request, String providerId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final clientDAO = ClientDAO(session, context);
        var (clientName, stripeCustomerId, invoicing) = await clientDAO.getStripeCustomerId(clientId);

        final stripe = await getStripeForProvider(context, providerId, session);

        if (stripeCustomerId == null) {
          final customerRequest = CreateCustomerRequest(
            name: invoicing?["name"] ?? clientName,
            email: invoicing?["email"],
            metadata: {"userId": session.userId, "clientId": clientId},
          );

          final customer = await stripe.customer.create(customerRequest);
          stripeCustomerId = customer.id;

          final stripeCustomerCreated = await clientDAO.setStripeCustomerId(clientId, stripeCustomerId);
          if (!stripeCustomerCreated) return api.internalError(errorBrokenLogicEx("Stripe customer not created"));
        }

        final body = (await request.body.asJson) as JsonObject;
        final payments = cast<JsonArray>(body["payments"])?.cast<String>();
        if (payments == null) return api.badRequest(errorInvalidParameterType("payments", "Array of strings"));

        final amount = cast<int>(body["amount"]);
        if (amount == null) return api.badRequest(errorInvalidParameterType("amount", "Number"));

        final currency = CurrencyCode.fromCodeOrNull(body["currency"] as String?);
        if (currency == null) return api.badRequest(errorInvalidParameterType("currency", "String"));

        // TODO: načítaj payments z DB a skontroluj či sedia ID-ečka a celková suma

        final paymentIntentRequest = CreatePaymentIntentRequest(
          amount: amount,
          currency: currency.code,
          customer: stripeCustomerId,
          setupFutureUsage: SetupFutureUsage.off_session,
          paymentMethodTypes: {PaymentMethodType.card},
          metadata: {"payments": payments.join(",")},
        );

        final paymentIntent = await stripe.paymentIntent.create(paymentIntentRequest);

        final paymentDAO = ClientPaymentDAO(session, context);
        await paymentDAO.updatePayment(
          providerId,
          clientId,
          payments,
          paymentIntent.toJson(),
          ClientPaymentStatus.processing,
        );

        return api.json({
          "paymentIntentId": paymentIntent.id,
          "status": paymentIntent.status,
          "clientSecret": paymentIntent.clientSecret,
        });
      });

  // "/v1/dashboard/payment/stripe",
  Router get router {
    final router = Router();

    router.post("/start/<providerId|$idRegExp>", _start);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

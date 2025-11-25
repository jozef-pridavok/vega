import "package:api_cron/api_v1/notify_reservations.dart";
import "package:shelf_router/shelf_router.dart";

import "../api_v1/client_payments.dart";
import "../api_v1/delivery_messages.dart";
import "../api_v1/update_currency_rates.dart";
import "api_shelf.dart";

mixin CronApiV1 {
  void installV1(CronApi api, Router router) {
    router.mount("/v1/currencyRates", UpdateCurrencyRatesHandler(api).router.call);
    router.mount("/v1/delivery_messages", DeliveryMessageHandler(api).router.call);
    router.mount("/v1/client/payment/", ClientPaymentHandler(api).router.call);
    router.mount("/v1/user/notify_reservations/", NotifyReservationsHandler(api).router.call);
  }
}

// eof

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf_router/shelf_router.dart";
import "package:shelf_static/shelf_static.dart";

import "../api_v1/auth.dart" as v1;
import "../api_v1/client_location.dart" as v1;
import "../api_v1/dashboard/card.dart" as v1d;
import "../api_v1/dashboard/client.dart" as v1d;
import "../api_v1/dashboard/client_payment.dart" as v1d;
import "../api_v1/dashboard/client_report.dart" as v1d;
import "../api_v1/dashboard/client_user.dart" as v1d;
import "../api_v1/dashboard/client_user_card.dart" as v1d;
import "../api_v1/dashboard/client_user_coupon.dart" as v1d;
import "../api_v1/dashboard/coupon.dart" as v1d;
import "../api_v1/dashboard/currency.dart" as v1d;
import "../api_v1/dashboard/dashboard.dart" as v1d;
import "../api_v1/dashboard/leaflet.dart" as v1d;
import "../api_v1/dashboard/location.dart" as v1d;
import "../api_v1/dashboard/log.dart" as v1d;
import "../api_v1/dashboard/message.dart" as v1d;
import "../api_v1/dashboard/payment_demo_credit.dart" as v1d;
import "../api_v1/dashboard/payment_provider.dart" as v1d;
import "../api_v1/dashboard/payment_stripe.dart" as v1d;
import "../api_v1/dashboard/product_item.dart" as v1d;
import "../api_v1/dashboard/product_item_modification.dart" as v1d;
import "../api_v1/dashboard/product_item_option.dart" as v1d;
import "../api_v1/dashboard/product_offer.dart" as v1d;
import "../api_v1/dashboard/product_order.dart" as v1d;
import "../api_v1/dashboard/product_section.dart" as v1d;
import "../api_v1/dashboard/program.dart" as v1d;
import "../api_v1/dashboard/program_reward.dart" as v1d;
import "../api_v1/dashboard/qr_tag.dart" as v1d;
import "../api_v1/dashboard/reservation.dart" as v1d;
import "../api_v1/dashboard/reservation_date.dart" as v1d;
import "../api_v1/dashboard/reservation_slot.dart" as v1d;
import "../api_v1/dashboard/seller_client.dart" as v1d;
import "../api_v1/dashboard/seller_payment.dart" as v1d;
import "../api_v1/dashboard/seller_template.dart" as v1d;
import "../api_v1/dashboard/transaction.dart" as v1;
import "../api_v1/dashboard/user.dart" as v1d;
import "../api_v1/integrations/whatsapp.dart" as v1i;
import "../api_v1/item.dart" as v1;
import "../api_v1/leaflet.dart" as v1;
import "../api_v1/location.dart" as v1;
import "../api_v1/message.dart" as v1;
import "../api_v1/mobile/card.dart" as v1;
import "../api_v1/mobile/client.dart" as v1;
import "../api_v1/mobile/coupon.dart" as v1;
import "../api_v1/mobile/program.dart" as v1;
import "../api_v1/mobile/reservation.dart" as v1;
import "../api_v1/mobile/user_card.dart" as v1;
import "../api_v1/offer.dart" as v1;
import "../api_v1/order.dart" as v1;
import "../api_v1/user.dart" as v1;
import "../utils/storage.dart";
import "api_shelf2.dart";

extension ApiServerHandlerId on ApiServerHandler {
  static String? _idRegExp;
  String get idRegExp => _idRegExp ??= _getIdRegExp();

  String _getIdRegExp() {
    final isDev = api.config.environment == Flavor.dev || api.config.environment == Flavor.qa;
    return isDev ? ".{1,36}" : "[0-9a-fA-F-]{36}";
  }
}

mixin MobileApiV1 {
  void installV1(MobileApi api, Router router) {
    _installV1Dev(api, router);
    _installV1Mobile(api, router);
    _installV1Dashboard(api, router);
    _installV1Integrations(api, router);
  }

  void _installV1Dev(MobileApi api, Router router) {
    if (!api.config.isDev) return;

    //router.mount("/v1/debug", v1.DebugHandler(api).router.call);

    // Serve local files

    if (api.config.storageDev2Local.isEmpty) {
      api.log.verbose("Hey dev, you can set storage.dev2Local in config.yaml to serve local files");
      return;
    }
    api.log.verbose("Serving local files from ${api.config.storagePath}");
    for (final type in StorageObject.values) {
      router.mount(
          "/${type.name}", createStaticHandler(storagePath(api.config, "", type), serveFilesOutsidePath: true));
    }
  }

  void _installV1Mobile(MobileApi api, Router router) {
    router.mount("/v1/auth", v1.AuthHandler(api).router.call);
    router.mount("/v1/card", v1.CardHandler(api).router.call);
    router.mount("/v1/user_card", v1.UserCardHandler(api).router.call);
    router.mount("/v1/user", v1.UserHandler(api).router.call);
    router.mount("/v1/client", v1.ClientHandler(api).router.call);
    router.mount("/v1/client_location", v1.ClientLocationHandler2(api).router.call);
    router.mount("/v1/program", v1.ProgramHandler(api).router.call);
    router.mount("/v1/message", v1.MessageHandler(api).router.call);
    router.mount("/v1/leaflet", v1.LeafletHandler(api).router.call);
    router.mount("/v1/coupon", v1.CouponHandler(api).router.call);
    router.mount("/v1/location", v1.LocationHandler(api).router.call);
    router.mount("/v1/reservation", v1.ReservationHandler(api).router.call);
    router.mount("/v1/order", v1.OrderHandler(api).router.call);
    router.mount("/v1/offer", v1.OfferHandler(api).router.call);
    router.mount("/v1/item", v1.ItemHandler(api).router.call);
  }

  void _installV1Dashboard(MobileApi api, Router router) {
    router.mount("/v1/dashboard", v1d.DashboardHandler(api).router.call);
    router.mount("/v1/dashboard/card", v1d.CardHandler(api).router.call);
    router.mount("/v1/dashboard/client", v1d.ClientHandler(api).router.call);
    router.mount("/v1/dashboard/user", v1d.UserHandler(api).router.call);
    router.mount("/v1/dashboard/client_report", v1d.ClientReportHandler(api).router.call);
    router.mount("/v1/dashboard/client_payment", v1d.ClientPaymentHandler(api).router.call);
    router.mount("/v1/dashboard/client_user", v1d.ClientUserHandler(api).router.call);
    router.mount("/v1/dashboard/client_user_card", v1d.ClientUserCardHandler(api).router.call);
    router.mount("/v1/dashboard/client_user_coupon", v1d.ClientUserCouponHandler(api).router.call);
    router.mount("/v1/dashboard/client/payment", v1d.ClientPaymentHandler(api).router.call);
    router.mount("/v1/dashboard/coupon", v1d.CouponHandler(api).router.call);
    router.mount("/v1/dashboard/currency", v1d.CurrencyHandler(api).router.call);
    router.mount("/v1/dashboard/leaflet", v1d.LeafletHandler(api).router.call);
    router.mount("/v1/dashboard/location", v1d.LocationHandler(api).router.call);
    router.mount("/v1/dashboard/message", v1d.MessageHandler(api).router.call);
    router.mount("/v1/dashboard/payment_provider", v1d.PaymentProviderHandler(api).router.call);
    router.mount("/v1/dashboard/pos_transaction", v1.TransactionHandler(api).router.call);
    router.mount("/v1/dashboard/product_item", v1d.ProductItemHandler(api).router.call);
    router.mount("/v1/dashboard/product_item_modification", v1d.ProductItemModificationHandler(api).router.call);
    router.mount("/v1/dashboard/product_item_option", v1d.ProductItemOptionHandler(api).router.call);
    router.mount("/v1/dashboard/product_offer", v1d.ProductOfferHandler(api).router.call);
    router.mount("/v1/dashboard/product_order", v1d.ProductOrderHandler(api).router.call);
    router.mount("/v1/dashboard/product_section", v1d.ProductSectionHandler(api).router.call);
    router.mount("/v1/dashboard/program", v1d.ProgramHandler(api).router.call);
    router.mount("/v1/dashboard/program_reward", v1d.ProgramRewardHandler(api).router.call);
    router.mount("/v1/dashboard/qr_tag", v1d.QrTagHandler(api).router.call);
    router.mount("/v1/dashboard/reservation", v1d.ReservationHandler(api).router.call);
    router.mount("/v1/dashboard/reservation_date", v1d.ReservationDateHandler(api).router.call);
    router.mount("/v1/dashboard/reservation_slot", v1d.ReservationSlotHandler(api).router.call);
    router.mount("/v1/dashboard/seller_client", v1d.SellerClientHandler(api).router.call);
    router.mount("/v1/dashboard/seller_payment", v1d.SellerPaymentHandler(api).router.call);
    router.mount("/v1/dashboard/seller/template", v1d.SellerTemplateHandler(api).router.call);
    router.mount("/v1/dashboard/payment/stripe", v1d.StripeHandler(api).router.call);
    router.mount("/v1/dashboard/payment/demo_credit", v1d.DemoCreditHandler(api).router.call);
    router.mount("/v1/dashboard/log", v1d.LogHandler(api).router.call);
    router.mount("/v1/dashboard/integrations", v1d.DashboardHandler(api).router.call);

    router.mount("/v1/pos/transaction", v1.TransactionHandler(api).router.call);
  }

  void _installV1Integrations(MobileApi api, Router router) {
    router.mount("/v1/integrations/whatsapp", v1i.WhatsappHandler(api).router.call);
  }
}




// eof

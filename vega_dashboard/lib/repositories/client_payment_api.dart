import "dart:io";

import "package:core_flutter/core_dart.dart";

import "client_payment.dart";

class ApiClientPaymentRepository implements ClientPaymentRepository {
  @override
  Future<List<ClientPayment>> forSeller(SellerPaymentRepositoryClientFilter filter) async {
    final path = "/v1/dashboard/seller_payment/eligible";

    final onlyReadyForRequest = filter == SellerPaymentRepositoryClientFilter.onlyReadyForRequest;
    final onlyWaitingForClient = filter == SellerPaymentRepositoryClientFilter.onlyWaitingForClient;

    final params = <String, dynamic>{
      "onlyReadyForRequest": onlyReadyForRequest,
      "onlyWaitingForClient": onlyWaitingForClient,
    };

    final res = await ApiClient().get(path, params: params);
    final json = await res.handleStatusCodeWithJson();

    final paymentsJsonArray = (json?["payments"] as JsonArray?);
    final payments = paymentsJsonArray?.map((e) => ClientPayment.fromMap(e, ClientPayment.camel));

    return payments?.toList() ?? [];
  }

  @override
  Future<(List<ClientPaymentProvider>, List<ClientPayment>)> read({
    bool onlyUnpaid = false,
    IntDate? dateFrom,
    IntDate? dateTo,
  }) async {
    final path = "/v1/dashboard/client_payment";

    final params = <String, dynamic>{"onlyUnpaid": onlyUnpaid};
    if (dateFrom != null) params["dateFrom"] = dateFrom.value;
    if (dateTo != null) params["dateTo"] = dateTo.value;

    final res = await ApiClient().get(path, params: params);
    final json = await res.handleStatusCodeWithJson();

    final providersJsonArray = (json?["providers"] as JsonArray?);
    final providers = providersJsonArray?.map((e) => ClientPaymentProvider.fromMap(e, ClientPaymentProvider.camel));

    final paymentsJsonArray = (json?["payments"] as JsonArray?);
    final payments = paymentsJsonArray?.map((e) => ClientPayment.fromMap(e, ClientPayment.camel));

    return (providers?.toList() ?? [], payments?.toList() ?? []);
  }

  @override
  Future<String> startStripePayment(ClientPaymentProvider provider, List<ClientPayment> payments, Price price) async {
    if (provider.type != ClientPaymentProviderType.stripe) return Future.error("Invalid provider type");
    final res = await ApiClient().post(
      "/v1/dashboard/payment/stripe/start/${provider.clientPaymentProviderId}",
      data: {
        "payments": payments.map((e) => e.clientPaymentId).toList(),
        "amount": price.fraction,
        "currency": price.currency.code,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return Future.error("Invalid data");
    return json["clientSecret"];
  }

  @override
  Future<bool> startDemoCreditPayment(ClientPaymentProvider provider, List<ClientPayment> payments, Price price) async {
    if (provider.type != ClientPaymentProviderType.demoCredit) return Future.error("Invalid provider type");
    final res = await ApiClient().post(
      "/v1/dashboard/payment/demo_credit/start/${provider.clientPaymentProviderId}",
      data: {
        "payments": payments.map((e) => e.clientPaymentId).toList(),
        "amount": price.fraction,
        "currency": price.currency.code,
      },
    );
    return res.statusCode == HttpStatus.ok;
  }

  @override
  Future<int> confirm(ClientPaymentProvider provider, List<ClientPayment> payments, JsonObject? payload) async {
    final res = await ApiClient().put(
      "/v1/dashboard/client_payment/confirm",
      data: {
        "providerId": provider.clientPaymentProviderId,
        "payments": payments.map((e) => e.clientPaymentId).toList(),
        "payload": payload,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affectedPayments"] as int?) ?? 0;
  }

  @override
  Future<int> cancel(ClientPaymentProvider provider, List<ClientPayment> payments, JsonObject? payload) async {
    const path = "/v1/dashboard/client_payment/cancel";
    final api = ApiClient();
    final res = await api.put(
      path,
      data: {
        "providerId": provider.clientPaymentProviderId,
        "payments": payments.map((e) => e.clientPaymentId).toList(),
        "payload": payload,
      },
    );

    final json = await res.handleStatusCodeWithJson();
    return (json?["affectedPayments"] as int?) ?? 0;
  }
}

// eof

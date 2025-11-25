import "package:core_flutter/core_dart.dart";

import "client_payment_provider.dart";

class ApiClientPaymentProviderRepository with LoggerMixin implements ClientPaymentProviderRepository {
  @override
  Future<List<ClientPaymentProvider>> readAll() async {
    final res = await ApiClient().get("/v1/dashboard/payment_provider/");
    final json = await res.handleStatusCodeWithJson();
    return (json?["providers"] as JsonArray?)
            ?.map((e) => ClientPaymentProvider.fromMap(e, ClientPaymentProvider.camel))
            .toList() ??
        [];
  }
}

// eof

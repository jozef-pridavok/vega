import "package:core_flutter/core_dart.dart";

import "seller_payment.dart";

class ApiSellerPaymentRepository implements SellerPaymentRepository {
  @override
  Future<List<SellerPayment>> read(SellerPaymentRepositoryFilter filter) async {
    final path = "/v1/dashboard/seller_payment/";

    final onlyUnpaid = filter == SellerPaymentRepositoryFilter.onlyUnpaid;
    final dateFrom = onlyUnpaid ? null : filter.from;
    final dateTo = onlyUnpaid ? null : filter.to;

    final params = <String, dynamic>{"onlyUnpaid": onlyUnpaid};
    if (dateFrom != null) params["dateFrom"] = dateFrom.value;
    if (dateTo != null) params["dateTo"] = dateTo.value;

    final res = await ApiClient().get(path, params: params);

    final json = await res.handleStatusCodeWithJson();

    final paymentsJsonArray = (json?["payments"] as JsonArray?);
    final payments = paymentsJsonArray?.map((e) => SellerPayment.fromMap(e, SellerPayment.camel));

    return payments?.toList() ?? [];
  }

  @override
  Future<SellerPayment> request(List<ClientPayment> payments, String invoiceNumber, IntDate? dueDate) async {
    final res = await ApiClient().post("/v1/dashboard/seller_payment/request", data: {
      "payments": payments.map((e) => e.clientPaymentId).toList(),
      "invoiceNumber": invoiceNumber,
      "dueDate": dueDate?.value,
    });
    final json = await res.handleStatusCodeWithJson();
    if (json == null) throw res;
    return SellerPayment.fromMap(json, SellerPayment.camel);
  }
}

// eof

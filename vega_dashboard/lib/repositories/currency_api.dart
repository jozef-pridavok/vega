import "package:core_flutter/core_dart.dart";

import "currency.dart";

class ApiCurrencyRepository extends CurrencyRepository {
  @override
  Future<double> latest(String pair) async {
    try {
      final res = await ApiClient().get("/v1/dashboard/currency/latest/$pair");
      final json = await res.handleStatusCodeWithJson();
      return jsonDouble(json!, "rate"); // cast<double>(json["rate"]);
    } catch (ex) {
      return Future.error(ex);
    }
  }
}

// eof

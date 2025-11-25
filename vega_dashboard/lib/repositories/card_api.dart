import "package:core_flutter/core_dart.dart";

import "card.dart";

class ApiCardRepository with LoggerMixin implements CardRepository {
  @override
  Future<List<Card>> readAll() async {
    final res = await ApiClient().get("/v1/dashboard/card/");
    final json = await res.handleStatusCodeWithJson();
    return (json?["cards"] as JsonArray?)?.map((e) => Card.fromMap(e, Convention.camel)).toList() ?? [];
  }
}

// eof

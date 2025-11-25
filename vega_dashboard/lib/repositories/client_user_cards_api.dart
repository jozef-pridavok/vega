import "package:core_flutter/core_dart.dart";

import "client_user_cards.dart";

class ApiClientUserCardsRepository implements ClientUserCardsRepository {
  @override
  Future<List<UserCard>> readAll({int? period, String? filter, String? programId, String? cardId}) async {
    final path = "/v1/dashboard/client_user_card";

    final params = <String, dynamic>{};
    if (period != null) params["period"] = period;
    if (filter != null) params["filter"] = filter;
    if (programId != null) params["programId"] = programId;
    if (cardId != null) params["cardId"] = cardId;

    final res = await ApiClient().get(path, params: params);
    final json = await res.handleStatusCodeWithJson();

    final userCardsJsonArray = (json?["userCards"] as JsonArray?);
    final userCards = userCardsJsonArray?.map((e) => UserCard.fromMap(e, Convention.camel));

    return userCards?.toList() ?? [];
  }

  @override
  Future<List<LoyaltyTransaction>> transactions(String userCardId) async {
    final res = await ApiClient().get("/v1/dashboard/client_user_card/transactions/$userCardId");
    final json = await res.handleStatusCodeWithJson();
    final transactions = (json?["transactions"] as JsonArray?);
    return transactions?.map((e) => LoyaltyTransaction.fromMap(e, LoyaltyTransaction.camel)).toList() ?? [];
  }
}

// eof

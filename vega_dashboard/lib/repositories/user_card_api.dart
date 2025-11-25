import "package:core_flutter/core_dart.dart";

import "user_card.dart";

class ApiUserCardRepository with LoggerMixin implements UserCardRepository {
  @override
  Future<UserCard> issue(Card card, CodeType type, String value) async {
    final res = await ApiClient().post("/v1/dashboard/client_user_card/issue/${card.cardId}/${type.code}/$value");
    final json = await res.handleStatusCodeWithJson();
    if (json == null) throw res;
    final jsonObject = json["userCard"];
    return UserCard.fromMap(jsonObject, Convention.camel);
  }
}

// eof

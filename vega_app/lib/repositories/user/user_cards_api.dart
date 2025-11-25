import "dart:io";

import "package:core_flutter/core_dart.dart";

import "user_cards.dart";

class ApiUserCardsRepository extends UserCardsRepository with LoggerMixin implements SyncedRemoteRepository<UserCard> {
  final DeviceRepository? deviceRepository;

  ApiUserCardsRepository({this.deviceRepository});

  @override
  Future<bool> create(UserCard userCard, {bool alreadySyncedRemotely = true}) async {
    final res = await ApiClient().post("/v1/user_card/${userCard.userCardId}", data: <String, dynamic>{
      "codeType": userCard.codeType.code,
      "cardId": userCard.cardId,
      "number": userCard.number,
      "name": userCard.name,
      "notes": userCard.notes,
      "color": userCard.color?.toHex(),
    });

    final json = (await res.handleStatusCodeWithJson(HttpStatus.created));
    return cast<int>(json?["affected"]) == 1;
  }

  @override
  Future<UserCard> createByClient(String clientId, {bool alreadySyncedRemotely = true}) async {
    final res = await ApiClient().post("/v1/user_card/by_client/$clientId", data: {});
    final json = (await res.handleStatusCodeWithJson(HttpStatus.created));
    return UserCard.fromMap(json!, Convention.camel);
  }

  @override
  Future<UserCard> createByCard(String cardId, {bool alreadySyncedRemotely = true}) async {
    final res = await ApiClient().post("/v1/user_card/by_card/$cardId", data: {});
    final json = (await res.handleStatusCodeWithJson(HttpStatus.created));
    return UserCard.fromMap(json!, Convention.camel);
  }

  @override
  Future<UserCard?> read(String userCardId, {bool ignoreCache = false}) async {
    final cacheKey = "3e38c8d4-c1c9-49c7-91e3-429b70352069-$userCardId";
    final cached = deviceRepository?.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/user_card/detail/$userCardId", params: {
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = await res.handleStatusCodeWithJson();
    if (json == null) return null;

    final detail = json["detail"] as JsonObject;
    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository?.putCacheKey(cacheKey, timestamp);

    return UserCard.fromMap(detail, Convention.camel);
  }

  @override
  Future<List<UserCard>?> readAll({bool ignoreCache = false}) async {
    const cacheKey = "3b71c752-9619-4733-ba41-3adcd2c2e786";
    final cached = deviceRepository?.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/user_card", params: {
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;
    if (json.isEmpty) return [];

    final cards = json["userCards"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository?.putCacheKey(cacheKey, timestamp);

    return cards.map((e) => UserCard.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<bool> update(UserCard userCard) async {
    final res = await ApiClient().put("/v1/user_card/${userCard.userCardId}", data: <String, dynamic>{
      "cardId": userCard.cardId,
      "clientId": userCard.clientId,
      "codeType": userCard.codeType.code,
      "number": userCard.number,
      "name": userCard.name,
      "notes": userCard.notes,
      "color": userCard.color?.toHex(),
    });
    final json = (await res.handleStatusCodeWithJson(HttpStatus.accepted));
    return cast<int>(json?["affected"]) == 1;
  }

  @override
  Future<bool> delete(UserCard userCard) async {
    final res = await ApiClient().delete("/v1/user_card/${userCard.userCardId}");
    final json = (await res.handleStatusCodeWithJson(HttpStatus.accepted));
    return cast<int>(json?["affected"]) == 1;
  }

  @override
  Future<UserCardByReceipt?> fromReceipt(String receipt, String secretReceiptKey) async {
    final cryptex = SimpleCipher(secretReceiptKey);
    final res = await ApiClient().post("/v1/user_card/receipt/${cryptex.encrypt(receipt)}");

    final json = (await res.handleStatusCodeWithJson(HttpStatus.accepted));
    if (json == null) return null;

    return UserCardByReceipt.fromMap(json, Convention.camel);
  }
}

// eof

import "package:core_flutter/core_dart.dart";

abstract class UserCardsRepository {
  Future<UserCard?> read(String userCardId, {bool ignoreCache = false});
  Future<List<UserCard>?> readAll({bool ignoreCache = false});
  Future<UserCard> createByClient(String clientId);
  Future<UserCard> createByCard(String cardId);
  Future<bool> create(UserCard userCard);
  Future<bool> update(UserCard userCard);
  Future<bool> delete(UserCard userCard);

  Future<UserCardByReceipt?> fromReceipt(String receipt, String secretReceiptKey);
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "user_cards.dart";

class HiveUserCardsRepository extends UserCardsRepository implements SyncedLocalRepository<UserCard> {
  static late Box<UserCard> _box;

  static Future<void> init() async {
    _box = await Hive.openBox("05013eb4-04f3-4d20-8560-e4f6b9f1510a");
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk("05013eb4-04f3-4d20-8560-e4f6b9f1510a");
  }

  static void clear() => _box.clear();

  @override
  Future<void> synced(UserCard userCard) {
    userCard.synced();
    return _box.put(userCard.userCardId, userCard);
  }

  @override
  Future<bool> create(UserCard userCard) async {
    userCard.syncCreated();
    await _box.put(userCard.userCardId, userCard);
    return true;
  }

  @override
  Future<UserCard> createByCard(String cardId) => throw UnimplementedError();

  @override
  Future<UserCard> createByClient(String clientId) => throw UnimplementedError();

  @override
  Future<UserCard?> read(String userCardId, {bool ignoreCache = false}) async => _box.get(userCardId);

  @override
  Future<List<UserCard>?> readAll({bool ignoreCache = false, bool includeDeleted = false}) async =>
      _box.values.toList();
  /*{
    var res = _box.values;
    final clientId = client?.clientId;
    if (clientId != null) res = res.where((e) => e.clientId == clientId);
    if (includeDeleted) return res.toList();
    return res.where((e) => e.syncIsActive).toList();
  }
  */

  @override
  Future<bool> update(UserCard userCard) async {
    userCard.syncUpdated();
    await _box.put(userCard.userCardId, userCard);
    return true;
  }

  @override
  Future<bool> delete(UserCard userCard) async {
    userCard.syncDeleted();
    await _box.put(userCard.userCardId, userCard);
    //_box.delete(userCard.userCardId);
    return true;
  }

  @override
  Future<void> deleteAll() => _box.clear();

  @override
  Future<UserCardByReceipt?> fromReceipt(String receipt, String secretReceiptKey) => throw UnimplementedError();
}

// eof

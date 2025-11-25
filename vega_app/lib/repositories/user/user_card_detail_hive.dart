/*
import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "user_card_detail.dart";

class HiveUserCardRepository extends UserCardRepository {
  static late Box<UserCard> _box;

  static Future<void> init() async {
    _box = await Hive.openBox("dbb08c5c-a5b8-4180-896b-a23880cd1f78");
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk("dbb08c5c-a5b8-4180-896b-a23880cd1f78");
  }

  static void clear() {
    _box.clear();
  }

  @override
  Future<void> create(UserCard userCard) => _box.put(userCard.userCardId, userCard);

  @override
  Future<UserCard?> read(String userCardId, {bool ignoreCache = false}) async => _box.get(userCardId);
}
*/
// eof

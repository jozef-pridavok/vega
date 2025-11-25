import "package:core_flutter/core_dart.dart";

abstract class UserCardRepository {
  Future<UserCard> issue(Card card, CodeType type, String value);
}

// eof

import "package:core_flutter/core_dart.dart";

abstract class ClientUserCardsRepository {
  Future<List<UserCard>> readAll({int? period, String? filter, String? programId, String? cardId});
  Future<List<LoyaltyTransaction>> transactions(String userCardId);
}

// eof

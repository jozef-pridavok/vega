import "package:core_flutter/core_dart.dart";

enum ClientCardRepositoryFilter {
  active,
  archived,
}

abstract class ClientCardRepository {
  Future<List<Card>> readAll({ClientCardRepositoryFilter filter});
  Future<bool> create(Card card, {List<int>? image});
  Future<bool> update(Card card, {List<int>? image});

  Future<bool> block(Card card);
  Future<bool> unblock(Card card);
  Future<bool> archive(Card card);

  Future<bool> reorder(List<Card> cards);
}

// eof

import "package:core_flutter/core_dart.dart";

enum SellerClientRepositoryFilter {
  active,
  archived,
}

abstract class SellerClientRepository {
  Future<List<Client>> readAll({SellerClientRepositoryFilter filter});

  Future<bool> update(Client client, {List<int>? images});
  Future<bool> create(Client client, {List<int>? images});

  Future<bool> block(Client client);
  Future<bool> unblock(Client client);
  Future<bool> archive(Client client);

  Future<bool> setDemoCredit(Client client, int fraction);
}

// eof

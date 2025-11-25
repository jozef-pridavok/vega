import "package:core_flutter/core_dart.dart";

enum ClientSettingsRepositoryFilter {
  basic,
  contact,
  invoicing,
  delivery,
}

abstract class ClientRepository {
  Future<Client?> detail();
  Future<bool> update(Client client, {List<int>? image});
}

// eof

import "../../data_models/client.dart";

abstract class ClientRepository {
  Future<void> create(Client client);
  Future<Client?> read(String clientId, {bool ignoreCache});
}

// eof

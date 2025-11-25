import "package:core_flutter/core_dart.dart";

abstract class ClientPaymentProviderRepository {
  Future<List<ClientPaymentProvider>> readAll();
}

// eof

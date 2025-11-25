import "package:core_flutter/core_dart.dart";

abstract class OrdersRepository {
  Future<List<UserOrder>> readAll(String clientId);
}

// eof

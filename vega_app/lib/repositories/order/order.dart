import "package:core_flutter/core_dart.dart";

abstract class OrderRepository {
  Future<bool> create(UserOrder order);
}

// eof

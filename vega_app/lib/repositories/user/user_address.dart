import "package:core_flutter/core_dart.dart";

abstract class UserAddressRepository {
  Future<List<UserAddress>?> readAll();
  Future<bool> create(UserAddress address);
  Future<bool> update(UserAddress address);
  Future<bool> delete(UserAddress address);
}

// eof

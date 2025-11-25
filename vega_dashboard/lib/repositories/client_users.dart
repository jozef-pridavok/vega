import "package:core_flutter/core_dart.dart";

abstract class ClientUserRepository {
  Future<List<User>> readAll(String clientId);

  Future<bool> create(User user, String password);
  Future<bool> update(User user, String password);
  Future<bool> updateMeta(User user);

  Future<bool> block(User user);
  Future<bool> unblock(User user);
  Future<bool> archive(User user);
}

// eof

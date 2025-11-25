import "package:core_flutter/core_dart.dart";

abstract class UserRepository {
  Future<User?> read(String userId);
  Future<bool> sendMessage(String userId, String subject, String body, List<MessageType> messageTypes);
}

// eof

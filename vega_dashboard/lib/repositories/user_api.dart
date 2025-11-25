import "package:core_flutter/core_dart.dart" hide UserRepository;

import "user.dart";

class ApiUserRepository extends UserRepository {
  @override
  Future<User?> read(String userId) async {
    final path = "/v1/dashboard/user/$userId";
    final res = await ApiClient().get(path);
    final json = await res.handleStatusCodeWithJson();
    if (json == null || json.isEmpty) return null;
    return User.fromMap((json["user"] as JsonObject), User.camel);
  }

  @override
  Future<bool> sendMessage(String userId, String subject, String body, List<MessageType> messageTypes) async {
    final res = await ApiClient().post(
      "/v1/dashboard/user/message/$userId",
      data: {
        "subject": subject,
        "body": body,
        "messageTypes": messageTypes.map((e) => e.code).toList(),
      },
    );

    final json = await res.handleStatusCodeWithJson();

    final succeed = (json?["ok"] as bool?) ?? false;
    if (succeed) return true;

    final errorJson = json?["error"] as JsonObject?;
    final errorCode = errorJson?["code"] as int?;
    final errorMessage = errorJson?["message"] as String?;
    if (errorCode == null || errorMessage == null) return Future.error(errorInvalidResponseFormat);

    return Future.error(CoreError(code: errorCode, message: errorMessage));
  }
}

// eof

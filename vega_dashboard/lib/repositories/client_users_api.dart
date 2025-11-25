import "dart:io";

import "package:core_flutter/core_dart.dart";

import "client_users.dart";

class ApiClientUserRepository with LoggerMixin implements ClientUserRepository {
  @override
  Future<List<User>> readAll(String clientId) async {
    final res = await ApiClient().get("/v1/dashboard/client_user", params: {"clientId": clientId});
    final json = await res.handleStatusCodeWithJson();
    return (json?["users"] as JsonArray?)?.map((e) => User.fromMap(e, User.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(User user, String password) async {
    final res = await ApiClient().post("/v1/dashboard/client_user/${user.userId}", data: {
      ...user.toMap(User.camel),
      ...{"password": password},
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(User user, String password) async {
    final res = await ApiClient().put("/v1/dashboard/client_user/${user.userId}", data: {
      ...user.toMap(User.camel),
      if (password.isNotEmpty) ...{"password": password},
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> updateMeta(User user) async {
    final res = await ApiClient().put("/v1/dashboard/client_user/${user.userId}", data: {
      ...user.toMap(User.camel),
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(User user, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/client_user/${user.userId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> block(User user) => _patch(user, {"blocked": true});

  @override
  Future<bool> unblock(User user) => _patch(user, {"blocked": false});

  @override
  Future<bool> archive(User user) => _patch(user, {"archived": true});
}

// eof

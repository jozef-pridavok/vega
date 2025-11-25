import "dart:io";

import "package:core_flutter/core_dart.dart";

import "client.dart" as dashboard;

class ApiClientRepository with LoggerMixin implements dashboard.ClientRepository {
  @override
  Future<Client?> detail() async {
    final res = await ApiClient().get("/v1/dashboard/client/detail/");
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return null;
    return Client.fromMap(json["client"], Client.camel);
  }

  @override
  Future<bool> update(Client client, {List<int>? image}) async {
    final path = "/v1/dashboard/client/";
    final api = ApiClient();

    final res = image != null
        ? await api.putMultipart(path, [image, client.toMap(Client.camel)])
        : await api.put(path, data: client.toMap(Client.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }
}

// eof

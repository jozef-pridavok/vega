import "dart:io";

import "package:core_flutter/core_dart.dart";

import "seller_client.dart";

extension SellerClientRepositoryFilterCode on SellerClientRepositoryFilter {
  static final _codeMap = {
    SellerClientRepositoryFilter.active: 1,
    SellerClientRepositoryFilter.archived: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiSellerClientRepository with LoggerMixin implements SellerClientRepository {
  @override
  Future<List<Client>> readAll({SellerClientRepositoryFilter filter = SellerClientRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/seller_client/?filter=${filter.code}");
    final json = await res.handleStatusCodeWithJson();
    return (json?["clients"] as JsonArray?)?.map((e) => Client.fromMap(e, Client.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Client client, {List<int>? images}) async {
    final path = "/v1/dashboard/seller_client/${client.clientId}";
    final api = ApiClient();

    final res = images != null
        ? await api.postMultipart(path, [images, client.toMap(Client.camel)])
        : await api.post(path, data: client.toMap(Client.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Client client, {List<int>? images}) async {
    final path = "/v1/dashboard/seller_client/${client.clientId}";
    final api = ApiClient();

    final res = images != null
        ? await api.putMultipart(path, [images, client.toMap(Client.camel)])
        : await api.put(path, data: client.toMap(Client.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(Client client, Map<String, dynamic> data) async {
    final res = await ApiClient().patch(
      "/v1/dashboard/seller_client/${client.clientId}",
      data: data,
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> block(Client client) => _patch(client, {"blocked": true});

  @override
  Future<bool> unblock(Client client) => _patch(client, {"blocked": false});

  @override
  Future<bool> archive(Client client) => _patch(client, {"archived": true});

  @override
  Future<bool> setDemoCredit(Client client, int fraction) => _patch(client, {"demoCredit": fraction});
}

// eof

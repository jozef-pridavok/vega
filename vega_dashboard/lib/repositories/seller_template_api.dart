import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../enums/seller_template.dart";
import "seller_template.dart";

class ApiSellerTemplateRepository with LoggerMixin implements SellerTemplateRepository {
  @override
  Future<bool> create(Client client, SellerTemplate template) async {
    final path = switch (template) {
      SellerTemplate.barber => "/v1/dashboard/seller/template/es-py.barber.01",
      _ => "/v1/dashboard/seller/template/es-py.barber.01",
    };
    final api = ApiClient();
    final res = await api.post(path, data: {
      "clientId": client.clientId,
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }
}

// eof

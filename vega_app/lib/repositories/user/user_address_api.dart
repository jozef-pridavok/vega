import "dart:io";

import "package:core_flutter/core_dart.dart";

import "user_address.dart";

class ApiUserAddressRepository extends UserAddressRepository with LoggerMixin {
  final DeviceRepository? deviceRepository;

  ApiUserAddressRepository({this.deviceRepository});

  @override
  Future<List<UserAddress>?> readAll() async {
    final res = await ApiClient().get("/v1/user/address");
    final json = await res.handleStatusCodeWithJson();
    return (json?["addresses"] as JsonArray?)?.map((e) => UserAddress.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(UserAddress address) async {
    final res = await ApiClient().post("/v1/user/address", data: address.toMap(Convention.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(UserAddress address) async {
    final res = await ApiClient().put("/v1/user/address", data: address.toMap(Convention.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> delete(UserAddress address) async {
    final res = await ApiClient().delete("/v1/user/address/${address.userAddressId}");
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }
}

// eof

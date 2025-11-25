import "dart:io";

import "package:core_flutter/core_dart.dart";

import "../repositories/location.dart";

class ApiLocationRepository with LoggerMixin implements LocationsRepository {
  @override
  Future<List<Location>> readAll() async {
    final res = await ApiClient().get("/v1/dashboard/location");
    final json = await res.handleStatusCodeWithJson();
    return (json?["locations"] as JsonArray?)?.map((e) => Location.fromMap(e, Location.snake)).toList() ?? [];
  }

  @override
  Future<bool> create(Location location) async {
    final res =
        await ApiClient().post("/v1/dashboard/location/${location.locationId}", data: location.toMap(Location.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Location location) async {
    final res =
        await ApiClient().put("/v1/dashboard/location/${location.locationId}", data: location.toMap(Location.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(Location location, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/location/${location.locationId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> archive(Location location) => _patch(location, {"archived": true});

  @override
  Future<bool> reorder(List<Location> locations) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/location/reorder",
      data: {"reorder": locations.map((e) => e.locationId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == locations.length;
  }
}

// eof

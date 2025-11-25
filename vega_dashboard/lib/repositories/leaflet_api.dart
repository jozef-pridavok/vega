import "dart:io";

import "package:core_flutter/core_dart.dart";

import "leaflet.dart";

extension _CouponRepositoryFilterCode on LeafletRepositoryFilter {
  static final _codeMap = {
    LeafletRepositoryFilter.active: 1,
    LeafletRepositoryFilter.prepared: 2,
    LeafletRepositoryFilter.finished: 3,
    LeafletRepositoryFilter.archived: 4,
  };
  int get code => _codeMap[this]!;
}

class ApiLeafletRepository with LoggerMixin implements LeafletsRepository {
  @override
  Future<List<Leaflet>> readAll({filter = LeafletRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/leaflet", params: {"filter": filter.code});
    final json = await res.handleStatusCodeWithJson();
    return (json?["leaflets"] as JsonArray?)?.map((e) => Leaflet.fromMap(e, Leaflet.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Leaflet leaflet, {List<dynamic>? pages}) async {
    final res = await ApiClient().post("/v1/dashboard/leaflet/${leaflet.leafletId}", data: {
      ...leaflet.toMap(Leaflet.camel),
      "pages": pages,
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Leaflet leaflet, {List<dynamic>? pages}) async {
    final res = await ApiClient().put("/v1/dashboard/leaflet/${leaflet.leafletId}", data: {
      ...leaflet.toMap(Leaflet.camel),
      "pages": pages,
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(Leaflet leaflet, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/leaflet/${leaflet.leafletId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> start(Leaflet leaflet) => _patch(leaflet, {"start": true});

  @override
  Future<bool> finish(Leaflet leaflet) => _patch(leaflet, {"finish": true});

  @override
  Future<bool> block(Leaflet leaflet) => _patch(leaflet, {"blocked": true});

  @override
  Future<bool> unblock(Leaflet leaflet) => _patch(leaflet, {"blocked": false});

  @override
  Future<bool> archive(Leaflet leaflet) => _patch(leaflet, {"archived": true});

  @override
  Future<bool> reorder(List<Leaflet> leaflets) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/leaflet/reorder",
      data: {"reorder": leaflets.map((e) => e.leafletId).toList()},
    );

    final statusCode = res.statusCode;

    if (statusCode == HttpStatus.networkConnectTimeoutError) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final affected = json["affected"] as int;
    return affected == leaflets.length;
  }
}

// eof

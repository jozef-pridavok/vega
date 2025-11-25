import "dart:io";

import "package:core_flutter/core_dart.dart";

import "leaflet_overview.dart";

class ApiLeafletOverviewRepository extends LeafletOverviewRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiLeafletOverviewRepository({required this.deviceRepository});

  @override
  Future<List<LeafletOverview>?> newest(Country country, {int? limit, bool noCache = false}) async {
    final cacheKey = "0f1770b6-b619-4f63-902e-cfdd341f4d24-${country.code}-$limit";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/leaflet/newest", params: {
      "country": country.code,
      if (limit != null) "limit": limit,
      if (noCache) "noCache": true,
      if (cached != null) "cache": cached,
    });

    switch (res.statusCode) {
      case -1:
        return Future.error(errorConnectionTimeout);
      case HttpStatus.noContent:
        return null;
      case HttpStatus.alreadyReported:
        return null;
      case HttpStatus.ok:
        break;
      default:
        return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));
    }

    final json = res.json!;
    final clientLeaflets = json["clients"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return clientLeaflets.map((e) => LeafletOverview.fromMap(e, LeafletOverview.camel)).toList();
  }

  @override
  Future<LeafletOverview?> read(String clientId, {bool noCache = false}) => throw UnimplementedError();

  @override
  Future<bool> create(Object leafletDetail) => throw UnimplementedError();

  @override
  Future<void> createAll(List<LeafletOverview> leaflets) => throw UnimplementedError();
}

// eof

import "dart:io";

import "package:core_flutter/core_dart.dart";

import "leaflet_detail.dart";

class ApiLeafletDetailRepository extends LeafletDetailRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiLeafletDetailRepository({required this.deviceRepository});

  @override
  Future<bool> create(Object detail) => throw UnimplementedError();

  @override
  Future<void> createAll(List<LeafletDetail> details) => throw UnimplementedError();

  @override
  Future<List<LeafletDetail>?> readAll(String clientId, {bool noCache = false}) async {
    final cacheKey = "b6fc047c-52b2-4f25-8edc-3d5e14ed40f1-$clientId";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/leaflet/$clientId", params: {
      if (noCache) "noCache": true,
      if (cached != null) "cache": cached,
    });
    final statusCode = res.statusCode;

    if (statusCode == -1) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));
    final json = res.json!;
    final leaflets = json["leaflets"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) {
      debug(() => "Hive: put new cache cache=$timestamp for $cacheKey");
      deviceRepository.putCacheKey(cacheKey, timestamp);
    }

    return leaflets.map((e) => LeafletDetail.fromMap(e, LeafletDetail.camel)).toList();
  }

  @override
  Future<LeafletDetail?> read(String leafletId, {bool noCache = false}) => throw UnimplementedError();
}

// eof

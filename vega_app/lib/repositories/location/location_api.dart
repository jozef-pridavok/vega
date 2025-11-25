import "package:core_flutter/core_dart.dart";

import "location.dart";

class ApiLocationRepository extends LocationRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiLocationRepository({required this.deviceRepository});

  @override
  Future<void> create(Location location) => throw UnimplementedError();

  @override
  Future<void> createAll(List<Location> locations) => throw UnimplementedError();

  @override
  Future<List<Location>?> readAll(String clientId, {bool ignoreCache = false}) async {
    final cacheKey = "8fcf4fa9-5b44-4e22-8e8a-17ac2894529a-$clientId";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/client_location/$clientId", params: {
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;

    final locations = json["locations"] as JsonArray;
    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return locations.map((e) => Location.fromMap(e, Location.camel)).toList();

    /*
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
    final locations = json["locations"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return locations.map((e) => Location.fromMap(e, Location.camel)).toList();
    */
  }

  @override
  Future<Location?> read(String locationId, {bool ignoreCache = true}) async {
    final cacheKey = "9d10660d-f987-45c0-b446-1497e28926a6-$locationId";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/location/$locationId", params: {
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;

    final location = json["location"] as JsonObject;
    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return Location.fromMap(location, Location.camel);

    /*
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
    final location = json["location"] as JsonObject;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return Location.fromMap(location, Location.camel);
    */
  }
}

// eof

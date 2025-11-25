import "package:core_flutter/core_dart.dart";

abstract class LocationRepository {
  Future<void> create(Location location);
  Future<void> createAll(List<Location> locations);
  Future<List<Location>?> readAll(String clientId, {bool ignoreCache});

  Future<Location?> read(String locationId, {bool ignoreCache});
}

// eof

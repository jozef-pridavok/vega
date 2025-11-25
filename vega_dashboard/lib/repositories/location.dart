import "package:core_flutter/core_dart.dart";

abstract class LocationsRepository {
  Future<List<Location>> readAll();

  Future<bool> create(Location location);
  Future<bool> update(Location location);

  Future<bool> archive(Location location);

  Future<bool> reorder(List<Location> locations);
}

// eof

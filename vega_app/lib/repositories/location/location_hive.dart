import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "location.dart";

class HiveLocationRepository extends LocationRepository {
  static const String _boxKey = "4953cbba-668d-4f9b-9820-e50dc1131c76";

  final DeviceRepository deviceRepository;

  HiveLocationRepository({required this.deviceRepository});

  static late Box<Location> _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxKey);
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk(_boxKey);
  }

  static void clear() => _box.clear();

  @override
  Future<void> create(Location location) async => await _box.put(location.locationId, location);

  @override
  Future<void> createAll(List<Location> locations) async =>
      await Future.wait(locations.map((e) => _box.put(e.locationId, e)));

  @override
  Future<List<Location>?> readAll(String clientId, {bool ignoreCache = true}) async =>
      _box.values.where((e) => e.clientId == clientId).toList();

  @override
  Future<Location?> read(String locationId, {bool ignoreCache = true}) async => _box.get(locationId);
}

// eof

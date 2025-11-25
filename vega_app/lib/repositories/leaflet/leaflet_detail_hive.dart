import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "leaflet_detail.dart";

class HiveLeafletDetailRepository extends LeafletDetailRepository {
  static late Box<LeafletDetail> _box;

  static Future<void> init() async {
    _box = await Hive.openBox("7b7d5bed-82b1-4d5b-93cd-605f4f2975a3");
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk("7b7d5bed-82b1-4d5b-93cd-605f4f2975a3");
  }

  static void clear() {
    _box.clear();
  }

  @override
  Future<void> create(LeafletDetail detail) async => _box.put(detail.leafletId, detail);

  @override
  Future<void> createAll(List<LeafletDetail> details) async {
    for (final e in details) await create(e);
  }

  @override
  Future<LeafletDetail?> read(String leafletId, {bool noCache = false}) async => _box.get(leafletId);

  @override
  Future<List<LeafletDetail>?> readAll(String clientId, {bool noCache = false}) async =>
      _box.values.where((e) => e.clientId == clientId).toList();
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "leaflet_overview.dart";

class HiveLeafletOverviewRepository extends LeafletOverviewRepository {
  static late Box<LeafletOverview> _box;

  static Future<void> init() async {
    _box = await Hive.openBox("241ba3dc-2034-4fbb-a4bd-89d5edfb3a98");
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk("241ba3dc-2034-4fbb-a4bd-89d5edfb3a98");
  }

  static void clear() {
    _box.clear();
  }

  @override
  Future<List<LeafletOverview>?> newest(Country country, {int? limit, bool noCache = false}) async =>
      _box.values.where((leaflet) => leaflet.country == country).toList();

  @override
  Future<LeafletOverview?> read(String clientId, {bool noCache = false}) async => _box.get(clientId);

  @override
  Future<void> create(LeafletOverview leafletDetail) async => _box.put(leafletDetail.clientId, leafletDetail);

  @override
  Future<void> createAll(List<LeafletOverview> leaflets) async {
    await Future.wait(leaflets.map((e) => create(e)));
  }
}

// eof

import "package:core_flutter/core_dart.dart";

abstract class LeafletOverviewRepository {
  Future<void> create(LeafletOverview leafletDetail);
  Future<void> createAll(List<LeafletOverview> leaflets);

  Future<List<LeafletOverview>?> newest(Country country, {int? limit, bool noCache = false});
  Future<LeafletOverview?> read(String clientId, {bool noCache = false});
}

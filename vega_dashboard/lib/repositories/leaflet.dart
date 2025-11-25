import "package:core_flutter/core_dart.dart";

enum LeafletRepositoryFilter {
  active,
  prepared,
  finished,
  archived,
}

abstract class LeafletsRepository {
  Future<List<Leaflet>> readAll({LeafletRepositoryFilter filter});

  Future<bool> create(Leaflet leaflet, {List<dynamic>? pages});
  Future<bool> update(Leaflet leaflet, {List<dynamic>? pages});

  Future<bool> start(Leaflet leaflet);
  Future<bool> finish(Leaflet leaflet);
  Future<bool> block(Leaflet leaflet);
  Future<bool> unblock(Leaflet leaflet);
  Future<bool> archive(Leaflet leaflet);

  Future<bool> reorder(List<Leaflet> leaflets);
}

// eof

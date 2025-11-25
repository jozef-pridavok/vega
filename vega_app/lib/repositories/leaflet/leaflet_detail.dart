import "package:core_flutter/core_dart.dart";

abstract class LeafletDetailRepository {
  Future<void> create(LeafletDetail detail);
  Future<void> createAll(List<LeafletDetail> details);

  Future<List<LeafletDetail>?> readAll(String clientId, {bool noCache = false});
  Future<LeafletDetail?> read(String leafletId, {bool noCache = false});
}

// eof

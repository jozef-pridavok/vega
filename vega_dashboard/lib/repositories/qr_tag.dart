import "package:core_flutter/core_dart.dart";

enum QrTagRepositoryFilter {
  unused,
  used,
}

abstract class QrTagRepository {
  Future<List<QrTag>> readAll(String programId, {QrTagRepositoryFilter filter, int? period});
  Future<bool> createMany(List<String> qrTagIds, String programId, int points);
  Future<int> archiveMany(List<String> qrTagIds);
}

// eof

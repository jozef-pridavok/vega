import "dart:io";

import "package:core_flutter/core_dart.dart";

import "qr_tag.dart";

extension _QrTagRepositoryFilterCode on QrTagRepositoryFilter {
  static final _codeMap = {
    QrTagRepositoryFilter.unused: 1,
    QrTagRepositoryFilter.used: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiQrTagRepository with LoggerMixin implements QrTagRepository {
  @override
  Future<List<QrTag>> readAll(
    String programId, {
    QrTagRepositoryFilter filter = QrTagRepositoryFilter.unused,
    int? period,
  }) async {
    final params = <String, dynamic>{"filter": filter.code};
    if (period != null) params["period"] = period;

    final res = await ApiClient().get("/v1/dashboard/qr_tag/$programId", params: params);
    final json = await res.handleStatusCodeWithJson();
    return (json?["qr_tags"] as JsonArray?)?.map((e) => QrTag.fromMap(e, QrTag.camel)).toList() ?? [];
  }

  @override
  Future<bool> createMany(List<String> qrTagIds, String programId, int points) async {
    final res = await ApiClient().post(
      "/v1/dashboard/qr_tag/create_many",
      data: {"qrTagIds": qrTagIds, "programId": programId, "points": points},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == qrTagIds.length;
  }

  @override
  Future<int> archiveMany(List<String> qrTagIds) async {
    final res = await ApiClient().put(
      "/v1/dashboard/qr_tag/delete_many",
      data: {"qrTagIds": qrTagIds},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) ?? 0;
  }
}

// eof

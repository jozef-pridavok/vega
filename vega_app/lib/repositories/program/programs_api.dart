import "dart:io";

import "package:core_flutter/core_dart.dart";

import "programs.dart";

class ApiProgramsRepository extends ProgramsRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiProgramsRepository({required this.deviceRepository});

  @override
  Future<Program?> read(String programId, {bool ignoreCache = false}) async {
    final cacheKey = "7b28c78a-965d-4412-a9f9-fb4c439f9cff-$programId";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/program/detail/$programId", params: {
      if (cached != null && !ignoreCache) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    // cached
    if (json == null) return null;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return Program.fromMap(json["detail"], Convention.camel);
  }

  @override
  Future<bool> create(Object program) => throw UnimplementedError();

  @override
  Future<(String?, List<String>?)> applyTag(String tagId, {String? cardId, String? userCardId}) async {
    final res = await ApiClient().post("/v1/program/tag/$tagId", data: {
      if (cardId != null) "cardId": cardId,
      if (userCardId != null) "userCardId": userCardId,
    });
    final json = (await res.handleStatusesCodeWithJson([HttpStatus.accepted, HttpStatus.created]));

    /*
    { "userCardId": "" }

    or

    { "userCards": ["uc1", "uc2"] }    
    */

    return (cast<String>(json?["userCardId"]), cast<JsonArray>(json?["userCards"])?.cast<String>());
  }
}

// eof

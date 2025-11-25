import "dart:io";

import "package:core_flutter/core_dart.dart";

import "cards.dart";

class ApiCardsRepository extends CardsRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiCardsRepository({required this.deviceRepository});

  @override
  Future<List<Card>?> readAll({Country? country}) async {
    const cacheKey = "41766163-7750-4fad-bcfe-399006b729be";
    final cached = deviceRepository.getCacheKey(cacheKey);
    debug(() => "Hive: get returned cached=$cached for $cacheKey ($cacheKey)");

    const path = "/v1/card";
    final data = <String, dynamic>{"cache": cached};
    final res = await ApiClient().get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == -1) return Future.error(errorConnectionTimeout);

    // User card not found
    if (statusCode == HttpStatus.noContent) return null;

    // Valid previously cached data
    if (statusCode == HttpStatus.alreadyReported) return null;

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final cards = json["cards"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    debug(() => "Hive: put new cache cache=$timestamp for $cacheKey");
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return cards.map((e) => Card.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<List<Card>?> readTop({int? limit}) async {
    const path = "/v1/card/top";
    final api = ApiClient();
    final data = <String, dynamic>{"limit": limit};

    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == -1) return Future.error(errorConnectionTimeout);

    // User card not found
    if (statusCode == HttpStatus.noContent) return null;

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final cards = json["cards"] as JsonArray;

    return cards.map((e) => Card.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<List<Card>?> search(String term) async {
    const path = "/v1/card/search";
    final api = ApiClient();
    final data = <String, dynamic>{"term": term};

    final res = await api.get(path, params: data);
    final statusCode = res.statusCode;

    if (statusCode == -1) return Future.error(errorConnectionTimeout);

    // User card not found
    if (statusCode == HttpStatus.noContent) return null;

    if (statusCode != HttpStatus.ok)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    final json = res.json!;
    final cards = json["cards"] as JsonArray;

    return cards.map((e) => Card.fromMap(e, Convention.camel)).toList();
  }
}

// eof

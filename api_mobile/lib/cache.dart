import "dart:convert";
import "dart:math";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class Cache {
  static final Cache _instance = Cache._internal();
  factory Cache() => _instance;
  Cache._internal();

  late final CacheKey _timestamps = CacheKeys.turboKey.join("timestamps");
  CacheKey _timestampKey(CacheKey key) => _timestamps.join(key.toString().replaceAll(":", "_"));

  /// Checks if a cache key is cached with
  /*
  Future<(bool, int?)> isCached(ApiServer api, CacheKey key, int? timestamp) async {
    final check = tryParseInt(await api.redis(["GET", _timestampKey(key)]));
    if (timestamp == null) return (false, check);
    return (check != null && timestamp == check, check);
  }
  */
  Future<(bool, int?)> isCached(Redis redis, CacheKey key, int? timestamp) async {
    final check = tryParseInt(await redis(["GET", _timestampKey(key)]));
    if (timestamp == null) return (false, check);
    return (check != null && timestamp == check, check);
  }

  /// Puts a JSON object into the cache with an optional expiration time.
  /// If the expiration time is zero (Duration.zero), the cache will not expire.
  /*
  Future<int> putJson(ApiServer api, CacheKey key, JsonObject json, {Duration? expiration}) async {
    if (expiration == Duration.zero) {
      await api.redis(["SET", key, jsonEncode(json)]);
      return 0;
    }

    final duration = expiration ?? (api.config.isDev ? const Duration(minutes: 30) : const Duration(days: 7));

    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    await api.redis(["SET", _timestampKey(key), timestamp, "EX", duration.inSeconds]);
    await api.redis(["SET", key, jsonEncode(json), "EX", duration.inSeconds]);
    return timestamp;
  }
  */
  Future<int> putJson(Redis redis, CacheKey key, JsonObject json, {Duration? expiration}) async {
    if (expiration == Duration.zero) {
      await redis(["SET", key, jsonEncode(json)]);
      return 0;
    }

    final duration = expiration ?? /*(api.config.isDev ? const Duration(minutes: 30) :*/ const Duration(days: 7);

    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    await redis(["SET", _timestampKey(key), timestamp, "EX", duration.inSeconds]);
    await redis(["SET", key, jsonEncode(json), "EX", duration.inSeconds]);
    return timestamp;
  }

  Future<JsonObject?> getJson<T>(Redis redis, CacheKey key) async {
    final json = await redis(["GET", key]);
    if (json == null) return null;
    return cast<JsonObject>(jsonDecode(json));
  }

  Future<void> clear(Redis redis, CacheKey key) async {
    await redis(["DEL", key]);
    await redis(["DEL", _timestampKey(key)]);
  }

  Future<void> clearAll(Redis redis, CacheKey key) async {
    await clear(redis, key);
    final allKeys = key.join("*");
    final res = await redis(["KEYS", allKeys]);
    final keysToDelete = (res as List<dynamic>).cast<String>();
    if (keysToDelete.isNotEmpty) {
      await redis(["DEL", ...keysToDelete]);
      await redis(["DEL", ...keysToDelete.map((k) => _timestampKey(CacheKey.fromString(k)))]);
    }
    /*

  slow version:
  
  var cursor = "0";
  final allKeys = <String>[];
  do {
    final res = await api.redis(["SCAN", cursor, "MATCH", key]);
    cursor = res[0] as String;
    final keys = (res[1] as List<dynamic>).cast<String>();
    if (keys.isNotEmpty) allKeys.addAll(keys);
  } while (cursor != "0");
  if (allKeys.isNotEmpty) await api.redis(["DEL", ...allKeys]);
  */
  }

  Future<List<String>> members(Redis redis, CacheKey key) async {
    final res = await redis(["SMEMBERS", key]);
    return (res as List<dynamic>).cast<String>();
  }

  Future<void> addMember(Redis redis, CacheKey key, String member) async {
    await redis(["SADD", key, member]);
  }

  Future<void> removeMember(Redis redis, CacheKey key, String member) async {
    await redis(["SREM", key, member]);
  }
}

class CacheKeys {
  static final CacheKey sessionKey = CacheKey.app("session");
  static CacheKey session(String installationId) {
    if (installationId == "*") return sessionKey;
    return sessionKey.join(installationId);
  }

  static final CacheKey loginAttemptsKey = CacheKey.app("loginAttempts");
  static CacheKey loginAttempts(String ipAddress) => loginAttemptsKey.join(ipAddress);

  //

  static final CacheKey turboKey = CacheKey.sql("turbo");
  static final CacheKey reportsKey = CacheKey.sql("reports");

  // ----------------------------------------

  static final CacheKey _card = turboKey.join("card");

  /// sql:turbo:card:${cardId}
  /// Caches a single client card
  static CacheKey card(String cardId) => _card.join(cardId);

  /// sql:turbo:card:${cardId}:users
  /// Caches the users of a client card
  static CacheKey cardUsers(String cardId) => card(cardId).join("users");

  /// sql:turbo:cards
  static final CacheKey cards = turboKey.join("cards");

  // ----------------------------------------

  static final CacheKey _coupon = turboKey.join("coupon");

  /// sql:turbo:coupon:${couponId}
  /// Caches a single coupon
  static CacheKey coupon(String couponId) => _coupon.join("coupon").join(couponId);

  /// sql:turbo:coupons
  static final CacheKey coupons = turboKey.join("coupons");

  /// sql:turbo:coupons:category:${categoryName}:${countryCode}
  /// Caches the coupons in a category for a country
  static CacheKey couponsInCategory(Country country, ClientCategory category) =>
      coupons.join("category").join(category.name).join(country.code);

  /// sql:turbo:coupons:newest:${countryCode}
  /// Caches the newest coupons for a country
  static CacheKey newestCoupons(Country country) => coupons.join("newest").join(country.code);

  /// sql:turbo:coupons:nearest:${lon}:${lat}
  /// Caches the nearest coupons to a location (lon, lat)
  static CacheKey nearestCoupons(double lon, double lat) {
    /*
      Dec. places   Dec. degrees  Distance (meters)
      0   1.0       110,574.3     111 km
      1   0.1       11,057.43     11 km
      2   0.01       1,105.74     1 km
      3   0.001        110.57    
      4   0.0001        11.06   
      5   0.00001        1.11    
      6   0.000001       0.11     11 cm
      7   0.0000001      0.01     1 cm
      8   0.00000001    0.001     1 mm
    */
    double round(double val, {int places = 2}) {
      num mod = pow(10.0, places);
      return ((val * mod).round().toDouble() / mod);
    }

    return coupons.join("nearest").join("${round(lon)}:${round(lat)}");
  }

  // ----------------------------------------

  static final CacheKey _user = turboKey.join("user");

  /// sql:turbo:user:${userId}
  /// Caches a single user
  static CacheKey user(String userId) => _user.join(userId);

  /// sql:turbo:user:${userId}:userCards
  /// Caches the user cards of a user, JSON of all user cards
  static CacheKey userUserCards(String userId) => user(userId).join("userCards");

  /// sql:turbo:user:${userId}:userCard:${cardId}
  /// Caches a single user card, JSON of a single user card. Use "*" as userCardId get all user cards for a user.
  static CacheKey userUserCard(String userId, String userCardId) {
    if (userCardId == "*") return user(userId).join("userCard");
    return user(userId).join("userCard").join(userCardId);
  }

  /// sql:turbo:user:${userId}:userAddress
  /// Caches the user address (of a user), JSON of single user address
  static CacheKey userUserAddress(String userId) => user(userId).join("userAddress");

  /// sql:turbo:user:${userId}:userAddresses
  /// Caches multiple user addresses (of a user), JSON of multiple user address
  static CacheKey userUserAddresses(String userId) => user(userId).join("userAddresses");

  // ----------------------------------------

  static final CacheKey _client = turboKey.join("client");

  /// sql:turbo:client:${clientId}
  /// Caches a single client
  static CacheKey client(String clientId) => _client.join(clientId);

  /// sql:turbo:client:${clientId}:${userType}
  /// Caches a single client for a user type
  static CacheKey clientForUserType(String clientId, UserType userType) => client(clientId).join(userType.name);

  // ----------------------------------------

  static final CacheKey _location = turboKey.join("location");

  /// sql:turbo:location:${locationId}
  /// Caches a single location
  static CacheKey location(String locationId) => _location.join("location").join(locationId);

  static final CacheKey _locations = turboKey.join("locations");

  /// sql:turbo:locations:${clientId}
  /// Caches the locations of a client
  static CacheKey locations(String clientId) => _locations.join(clientId);

  // ----------------------------------------

  static CacheKey clientReports(String clientId) => reportsKey.join("clients").join(clientId);

  static CacheKey clientReportType(String clientId, ClientReportType reportType,
          {JsonObject reportParams = const {}}) =>
      clientReports(clientId).join(reportType.redisKey(params: reportParams));

  // ----------------------------------------

  static final CacheKey _program = turboKey.join("program");

  /// sql:turbo:program:${programId}
  /// Caches a single program
  static CacheKey program(String programId) => _program.join(programId);

  // ----------------------------------------

  static final CacheKey _leaflets = turboKey.join("leaflets");

  /// sql:turbo:leaflets:${clientId}
  /// Caches the leaflets of a client
  static CacheKey leaflets(String clientId) => _leaflets.join(clientId);

  /// sql:turbo:leaflets:overview:${countryCode}:${limit}
  /// Caches the leaflets overview of clients for a country with limit
  static CacheKey leafletsOverviewForCountry(Country country, int limit) =>
      _leaflets.join("overview").join(country.code).join(limit.toString());
}

// eof

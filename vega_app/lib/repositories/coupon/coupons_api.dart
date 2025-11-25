import "dart:io";

import "package:core_flutter/core_dart.dart";

import "coupons.dart";

class ApiCouponsRepository extends CouponsRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiCouponsRepository({required this.deviceRepository});

  @override
  Future<Coupon?> read(String couponId, {bool ignoreCache = false}) async {
    final cached = deviceRepository.getCacheKey(couponId);

    final res = await ApiClient().get("/v1/coupon/$couponId", params: {
      if (cached != null && !ignoreCache) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    // cached
    if (json == null) return null;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(couponId, timestamp);

    return Coupon.fromMap(json["coupon"], Convention.camel);
  }

  @override
  Future<List<Coupon>?> newest({bool ignoreCache = false}) async {
    final user = deviceRepository.get(DeviceKey.user) as User;

    final cacheKey = "ee6c0f00-af08-4c05-99c1-25891c93d702-${user.country}";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/coupon/newest", params: {
      "country": user.country,
      if (cached != null && !ignoreCache) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;
    if (json.isEmpty) return [];

    final coupons = json["coupons"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return coupons.map((e) => Coupon.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<List<Coupon>?> nearest({bool ignoreCache = false}) async {
    const cacheKey = "ee6c0f00-af08-4c05-99c1-25891c93d702";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final user = deviceRepository.get(DeviceKey.user) as User;
    final lat = user.metaLocationLatitude;
    final lon = user.metaLocationLongitude;

    if (lat == null || lon == null) return null;

    final res = await ApiClient().get("/v1/coupon/nearest", params: {
      "lat": lat,
      "lon": lon,
      if (cached != null && !ignoreCache) "cache": cached,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;
    if (json.isEmpty) return [];

    final coupons = json["coupons"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) {
      debug(() => "Hive: put new cache cache=$timestamp for $cacheKey");
      deviceRepository.putCacheKey(cacheKey, timestamp);
    }

    return coupons.map((e) => Coupon.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<List<Coupon>?> readByCategory(ClientCategory category, {bool ignoreCache = false}) async {
    final cacheKey = "bca1ac49-011c-4978-9054-147913090488-${category.code}";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/coupon/category", params: {
      if (cached != null && !ignoreCache) "cache": cached,
      "category": category.code,
    });

    final json = (await res.handleStatusCodeWithJson());
    if (json == null) return null;
    if (json.isEmpty) return [];

    final coupons = json["coupons"] as JsonArray;

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) {
      debug(() => "Hive: put new cache cache=$timestamp for $cacheKey");
      deviceRepository.putCacheKey(cacheKey, timestamp);
    }

    return coupons.map((e) => Coupon.fromMap(e, Convention.camel)).toList();
  }

  @override
  Future<void> create(Coupon coupon) => throw UnimplementedError();

  @override
  Future<void> createNewest(List<Coupon> coupons) => throw UnimplementedError();

  @override
  Future<void> createNearest(List<Coupon> coupons) => throw UnimplementedError();

  // Returns (user card id, coupon id)
  @override
  Future<(String?, String?)> take(Coupon coupon) async {
    final res = await ApiClient().post("/v1/coupon/take/${coupon.couponId}");

    final json = (await res.handleStatusCodeWithJson(HttpStatus.accepted));

    final userCardId = cast<String>(json?["userCardId"]);
    final userCouponId = cast<String>(json?["userCouponId"]);

    return (userCardId, userCouponId);
  }
}

// eof

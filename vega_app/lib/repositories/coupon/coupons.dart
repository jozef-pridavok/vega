import "package:core_flutter/core_dart.dart";

abstract class CouponsRepository {
  Future<void> createNewest(List<Coupon> coupons);
  Future<void> createNearest(List<Coupon> coupons);
  Future<void> create(Coupon coupon);

  Future<Coupon?> read(String couponId, {bool ignoreCache = false});

  Future<List<Coupon>?> newest({bool ignoreCache = false});
  Future<List<Coupon>?> nearest({bool ignoreCache = false});
  Future<List<Coupon>?> readByCategory(ClientCategory category, {bool ignoreCache = false});

  // Returns (user card id, coupon id)
  Future<(String?, String?)> take(Coupon coupon);
}

// eof

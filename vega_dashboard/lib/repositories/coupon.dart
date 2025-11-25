import "package:core_flutter/core_dart.dart";

enum CouponRepositoryFilter {
  active,
  prepared,
  finished,
  archived,
}

abstract class CouponRepository {
  Future<bool> create(Coupon coupon, {List<int>? image});
  Future<List<Coupon>> readAll({CouponRepositoryFilter filter});
  Future<bool> update(Coupon coupon, {List<int>? image});

  Future<UserCoupon> issue(String couponId, CodeType type, String value);
  Future<bool> redeem(CodeType type, String value);

  Future<bool> start(Coupon coupon);
  Future<bool> finish(Coupon coupon);
  Future<bool> block(Coupon coupon);
  Future<bool> unblock(Coupon coupon);
  Future<bool> archive(Coupon coupon);

  Future<bool> reorder(List<Coupon> coupons);
}

// eof

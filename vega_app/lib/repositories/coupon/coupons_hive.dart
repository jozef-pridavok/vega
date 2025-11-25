import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "coupons.dart";

class HiveCouponsRepository extends CouponsRepository {
  static const String _boxKey = "59149a7d-7807-458d-a977-eb34befa0945";
  static const String _boxNewestKey = "7a63c3cb-8383-4287-bff1-bfd3290cfe40";
  static const String _boxNearestKey = "64531466-96e7-4c72-940e-fa1ea9e0cb38";

  static late Box<Coupon> _box;
  static late Box<Coupon> _boxNewest;
  static late Box<Coupon> _boxNearest;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxKey);
    _boxNewest = await Hive.openBox(_boxNewestKey);
    _boxNearest = await Hive.openBox(_boxNearestKey);
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk(_boxKey);
    await Hive.deleteBoxFromDisk(_boxNewestKey);
    await Hive.deleteBoxFromDisk(_boxNearestKey);
  }

  static void clear() {
    _box.clear();
    _boxNewest.clear();
    _boxNearest.clear();
  }

  @override
  Future<void> createNewest(List<Coupon> coupons) async {
    await _boxNearest.clear();
    await Future.wait(coupons.map((coupon) => _boxNewest.put(coupon.couponId, coupon)));
  }

  @override
  Future<void> createNearest(List<Coupon> coupons) async {
    await _boxNewest.clear();
    await Future.wait(coupons.map((coupon) => _boxNearest.put(coupon.couponId, coupon)));
  }

  @override
  Future<void> create(Coupon coupon) async => await _box.put(coupon.couponId, coupon);

  @override
  Future<Coupon?> read(String couponId, {bool ignoreCache = false}) async => _box.get(couponId);

  @override
  Future<List<Coupon>?> newest({bool ignoreCache = false}) async => _boxNewest.values.toList();

  @override
  Future<List<Coupon>?> nearest({bool ignoreCache = false}) async => _boxNearest.values.toList();

  @override
  Future<List<Coupon>?> readByCategory(ClientCategory category, {bool ignoreCache = false}) =>
      throw UnimplementedError();

  @override
  Future<(String?, String?)> take(Coupon coupon) => throw UnimplementedError();
}

// eof

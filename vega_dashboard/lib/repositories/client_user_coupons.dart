import "package:core_flutter/core_dart.dart";

abstract class ClientUserCouponsRepository {
  Future<List<UserCoupon>> readAll({int? period, String? filter, int? type, String? couponId});
}

// eof

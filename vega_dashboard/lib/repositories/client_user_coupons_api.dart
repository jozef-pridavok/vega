import "package:core_flutter/core_dart.dart";

import "client_user_coupons.dart";

class ApiClientUserCouponsRepository with LoggerMixin implements ClientUserCouponsRepository {
  @override
  Future<List<UserCoupon>> readAll({int? period, String? filter, int? type, String? couponId}) async {
    final path = "/v1/dashboard/client_user_coupon/";
    final params = <String, dynamic>{
      if (period != null) "period": period,
      if (filter != null && filter.isNotEmpty) "filter": filter,
      if (type != null) "type": type,
      if (couponId != null) "couponId": couponId,
    };
    final res = await ApiClient().get(path, params: params);
    final json = await res.handleStatusCodeWithJson();

    return (json?["userCoupons"] as JsonArray?)?.map((e) => UserCoupon.fromMap(e, Convention.camel)).toList() ?? [];
  }
}

// eof

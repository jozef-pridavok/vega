import "dart:io";

import "package:core_flutter/core_dart.dart";

import "coupon.dart";

extension _CouponRepositoryFilterCode on CouponRepositoryFilter {
  static final _codeMap = {
    CouponRepositoryFilter.active: 1,
    CouponRepositoryFilter.prepared: 2,
    CouponRepositoryFilter.finished: 3,
    CouponRepositoryFilter.archived: 4,
  };
  int get code => _codeMap[this]!;
}

class ApiCouponRepository with LoggerMixin implements CouponRepository {
  @override
  Future<List<Coupon>> readAll({CouponRepositoryFilter filter = CouponRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/coupon/", params: {"filter": filter.code});
    final json = await res.handleStatusCodeWithJson();
    return (json?["coupons"] as JsonArray?)?.map((e) => Coupon.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Coupon coupon, {List<int>? image}) async {
    final path = "/v1/dashboard/coupon/${coupon.couponId}";
    final api = ApiClient();

    final res = image != null
        ? await api.postMultipart(path, [image, coupon.toMap(Convention.camel)])
        : await api.post(path, data: coupon.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Coupon coupon, {List<int>? image}) async {
    final path = "/v1/dashboard/coupon/${coupon.couponId}";
    final api = ApiClient();

    final res = image != null
        ? await api.putMultipart(path, [image, coupon.toMap(Convention.camel)])
        : await api.put(path, data: coupon.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> reorder(List<Coupon> coupons) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/coupon/reorder",
      data: {"reorder": coupons.map((e) => e.couponId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == coupons.length;
  }

  @override
  Future<UserCoupon> issue(String couponId, CodeType type, String value) async {
    final res = await ApiClient().post("/v1/dashboard/coupon/issue/$couponId/${type.code}/$value");
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return UserCoupon.fromMap(json["userCoupon"], Convention.camel);
  }

  @override
  Future<bool> redeem(CodeType type, String value) async {
    final res = await ApiClient().put("/v1/dashboard/coupon/redeem/${type.code}/$value");
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(Coupon coupon, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/coupon/${coupon.couponId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> start(Coupon coupon) => _patch(coupon, {"start": true});

  @override
  Future<bool> finish(Coupon coupon) => _patch(coupon, {"finish": true});

  @override
  Future<bool> block(Coupon coupon) => _patch(coupon, {"blocked": true});

  @override
  Future<bool> unblock(Coupon coupon) => _patch(coupon, {"blocked": false});

  @override
  Future<bool> archive(Coupon coupon) => _patch(coupon, {"archived": true});
}

// eof

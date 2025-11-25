import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/repositories/coupon.dart";

@immutable
abstract class IssueCouponState {}

class IssueCouponInitial extends IssueCouponState {}

class IssueCouponInProcess extends IssueCouponState {}

class IssueCouponSucceed extends IssueCouponState {
  final UserCoupon coupon;
  IssueCouponSucceed(this.coupon);
}

class IssueCouponFailed extends IssueCouponState {
  final CoreError? error;
  final String message;
  IssueCouponFailed(this.message, {this.error});
}

class IssueCouponNotifier extends StateNotifier<IssueCouponState> with LoggerMixin {
  final CouponRepository couponRepository;

  IssueCouponNotifier({required this.couponRepository}) : super(IssueCouponInitial());

  void reset() => state = IssueCouponInitial();

  Future<void> issue(Coupon coupon, CodeType type, String value) async {
    try {
      state = IssueCouponInProcess();
      final userCoupon = await couponRepository.issue(coupon.couponId, type, value);
      state = IssueCouponSucceed(userCoupon);
    } on CoreError catch (err) {
      error("Unexpected error: $err");
      state = IssueCouponFailed(err.toString(), error: err);
    } catch (ex) {
      error("Unexpected exception: $ex");
      state = IssueCouponFailed(ex.toString());
    }
  }
}

// eof

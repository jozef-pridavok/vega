import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/repositories/coupon.dart";

@immutable
abstract class RedeemCouponState {}

class RedeemCouponInitial extends RedeemCouponState {}

class RedeemCouponInProcess extends RedeemCouponState {}

class RedeemCouponSucceed extends RedeemCouponState {
  RedeemCouponSucceed();
}

class RedeemCouponFailed extends RedeemCouponState {
  final CoreError? error;
  final String message;
  RedeemCouponFailed(this.message, {this.error});
}

class RedeemCouponNotifier extends StateNotifier<RedeemCouponState> with LoggerMixin {
  final CouponRepository couponRepository;

  RedeemCouponNotifier({required this.couponRepository}) : super(RedeemCouponInitial());

  void reset() => state = RedeemCouponInitial();

  Future<void> redeem(CodeType type, String value) async {
    if (state is RedeemCouponInProcess) return;
    try {
      state = RedeemCouponInProcess();
      final redeemed = await couponRepository.redeem(type, value);
      state = redeemed ? RedeemCouponSucceed() : RedeemCouponFailed("");
    } on CoreError catch (err) {
      error("Unexpected error: $err");
      state = RedeemCouponFailed(err.toString(), error: err);
    } catch (ex) {
      error("Unexpected exception: $ex");
      state = RedeemCouponFailed(ex.toString());
    }
  }
}

// eof

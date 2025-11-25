import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/coupon/coupons.dart";

@immutable
abstract class TakeCouponState {}

extension TakeCouponStateToActionButtonState on TakeCouponState {
  static const stateMap = {
    TakeCouponInitial: MoleculeActionButtonState.idle,
    TakeCouponInProcess: MoleculeActionButtonState.loading,
    TakeCouponFailed: MoleculeActionButtonState.fail,
    TakeCouponSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class TakeCouponInitial extends TakeCouponState {}

class TakeCouponInProcess extends TakeCouponState {}

class TakeCouponSucceed extends TakeCouponState {
  final String userCardId;
  final String userCouponId;
  TakeCouponSucceed(this.userCardId, this.userCouponId);
}

class TakeCouponFailed extends TakeCouponState implements FailedState {
  @override
  final CoreError error;
  TakeCouponFailed(this.error);
}

class TakeCouponNotifier extends StateNotifier<TakeCouponState> {
  final CouponsRepository repository;
  TakeCouponNotifier({required this.repository}) : super(TakeCouponInitial());

  void reset() => state = TakeCouponInitial();

  Future<void> take(Coupon coupon) async {
    try {
      state = TakeCouponInProcess();
      final (userCardId, userCouponId) = await repository.take(coupon);
      if (userCouponId != null)
        state = TakeCouponSucceed(userCardId!, userCouponId);
      else
        state = TakeCouponFailed(errorUnexpectedException("User coupon has not been created"));
    } on CoreError catch (ex) {
      state = TakeCouponFailed(ex);
    } catch (ex) {
      state = TakeCouponFailed(errorUnexpectedException(ex));
    }
  }
}

// eof

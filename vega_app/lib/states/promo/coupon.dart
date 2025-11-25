import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/coupon/coupons.dart";

@immutable
abstract class CouponState {}

extension CouponStateToActionButtonState on CouponState {
  static const stateMap = {
    CouponInitial: MoleculeActionButtonState.idle,
    CouponLoading: MoleculeActionButtonState.loading,
    CouponFailed: MoleculeActionButtonState.fail,
    //CouponLoaded: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponLoaded extends CouponState {
  final Coupon coupon;
  CouponLoaded(this.coupon);
}

class CouponFailed extends CouponState implements FailedState {
  @override
  final CoreError error;
  CouponFailed(this.error);
}

class CouponNotifier extends StateNotifier<CouponState> with StateMixin {
  final String couponId;
  final CouponsRepository localCoupons;
  final CouponsRepository remoteCoupons;
  CouponNotifier(this.couponId, {required this.localCoupons, required this.remoteCoupons}) : super(CouponInitial());

  void reset() => state = CouponInitial();

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<CouponLoaded>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    state = CouponLoading();

    try {
      Coupon? coupon = reload ? null : await localCoupons.read(couponId);

      if (coupon == null) {
        coupon = await remoteCoupons.read(couponId, ignoreCache: reload);
        if (coupon != null) await localCoupons.create(coupon);
      }

      state = (coupon != null) ? CouponLoaded(coupon) : CouponFailed(errorFailedToLoadData);
    } on CoreError catch (ex) {
      debug(() => ex.toString());
      state = CouponFailed(ex);
    } catch (ex) {
      debug(() => ex.toString());
      state = CouponFailed(errorUnexpectedException(ex));
    }
  }

  Future<void> load() => _load();

  Future<void> refresh() => _load(reload: true);

  Future<void> refreshOnBackground() async {
    final loaded = expect<CouponLoaded>(state);
    if (loaded == null) return;
    try {
      final coupon = await remoteCoupons.read(couponId);
      if (coupon != null) {
        await localCoupons.create(coupon);
        state = CouponLoaded(coupon);
      }
    } on Exception catch (ex) {
      debug(() => errorFailedToLoadDataEx(ex: ex).toString());
    } catch (ex) {
      debug(() => errorUnexpectedException(ex).toString());
    }
  }
}

// eof

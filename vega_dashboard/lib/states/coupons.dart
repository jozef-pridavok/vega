import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/coupon.dart";

@immutable
abstract class CouponsState {}

class CouponsInitial extends CouponsState {}

class CouponsLoading extends CouponsState {}

class CouponsSucceed extends CouponsState {
  final List<Coupon> coupons;
  final Coupon? removedCoupon;
  CouponsSucceed({required this.coupons, this.removedCoupon});
}

class CouponsRefreshing extends CouponsSucceed {
  CouponsRefreshing({required super.coupons});
}

class CouponsFailed extends CouponsState implements FailedState {
  @override
  final CoreError error;
  @override
  CouponsFailed(this.error);
}

class CouponsNotifier extends StateNotifier<CouponsState> with StateMixin {
  final CouponRepositoryFilter filter;
  final CouponRepository couponRepository;

  CouponsNotifier(
    this.filter, {
    required this.couponRepository,
  }) : super(CouponsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = CouponsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<CouponsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! CouponsRefreshing) state = CouponsLoading();
      final coupons = await couponRepository.readAll(filter: filter);
      state = CouponsSucceed(coupons: coupons);
    } on CoreError catch (err) {
      warning(err.toString());
      state = CouponsFailed(err);
    } on Exception catch (ex) {
      state = CouponsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = CouponsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<CouponsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = CouponsRefreshing(coupons: succeed.coupons);
    await load(reload: true);
  }

  bool added(Coupon coupon) {
    return next(state, [CouponsSucceed], () {
      final coupons = cast<CouponsSucceed>(state)!.coupons;
      final index = coupons.indexWhere((e) => e.couponId == coupon.couponId);
      if (index != -1) return false;
      coupons.insert(0, coupon);
      state = CouponsSucceed(coupons: coupons);
      return true;
    });
  }

  bool updated(Coupon coupon) {
    return next(state, [CouponsSucceed], () {
      final coupons = cast<CouponsSucceed>(state)!.coupons;
      final index = coupons.indexWhere((e) => e.couponId == coupon.couponId);
      if (index == -1) return false;
      coupons.replaceRange(index, index + 1, [coupon]);
      state = CouponsSucceed(coupons: coupons);
      return true;
    });
  }

  bool removed(Coupon coupon) {
    return next(state, [CouponsSucceed], () {
      final coupons = cast<CouponsSucceed>(state)!.coupons;
      final index = coupons.indexWhere((r) => r.couponId == coupon.couponId);
      if (index == -1) return false;
      coupons.removeAt(index);
      state = CouponsSucceed(coupons: coupons);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<CouponsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentCoupons = succeed.coupons;
      final removedCoupon = currentCoupons.removeAt(oldIndex);
      currentCoupons.insert(newIndex, removedCoupon);
      final newCoupons = currentCoupons.map((coupon) => coupon.copyWith(rank: currentCoupons.indexOf(coupon))).toList();
      final reordered = await couponRepository.reorder(newCoupons);
      state = reordered ? CouponsSucceed(coupons: newCoupons) : CouponsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = CouponsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = CouponsFailed(errorFailedToSaveData);
    }
  }
}

// eof

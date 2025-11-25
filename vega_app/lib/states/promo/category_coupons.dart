import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/coupon/coupons.dart";

@immutable
abstract class CategoryCouponsState {}

class CategoryCouponsInitial extends CategoryCouponsState {}

class CategoryCouponsLoading extends CategoryCouponsState {}

class CategoryCouponsSucceed extends CategoryCouponsState {
  final List<Coupon> coupons;
  CategoryCouponsSucceed({required this.coupons});
}

class CategoryCouponsRefreshing extends CategoryCouponsSucceed {
  CategoryCouponsRefreshing({required super.coupons});
}

class CategoryCouponsFailed extends CategoryCouponsState implements FailedState {
  @override
  final CoreError error;
  @override
  CategoryCouponsFailed(this.error);
}

class CategoryCouponsNotifier extends StateNotifier<CategoryCouponsState> with LoggerMixin {
  final ClientCategory category;
  final CouponsRepository remoteRepository;

  CategoryCouponsNotifier(
    this.category, {
    required this.remoteRepository,
  }) : super(CategoryCouponsInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<CategoryCouponsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      final previousSucceed = cast<CategoryCouponsSucceed>(state);
      if (state is! CategoryCouponsRefreshing) state = CategoryCouponsLoading();
      final coupons = await remoteRepository.readByCategory(category, ignoreCache: reload);
      state = CategoryCouponsSucceed(coupons: coupons ?? previousSucceed?.coupons ?? []);
    } on CoreError catch (e) {
      error(e.toString());
      state = CategoryCouponsFailed(e);
    } catch (e) {
      error(e.toString());
      state = CategoryCouponsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! CategoryCouponsSucceed) return;
    final coupons = cast<CategoryCouponsSucceed>(state)!.coupons;
    state = CategoryCouponsRefreshing(coupons: coupons);
    await _load(reload: true);
  }
}

// eof

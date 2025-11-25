import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_user_coupons.dart";

@immutable
abstract class ClientUserCouponsState {
  final int? period;
  final String? filter;
  final int? type;
  final String? couponId;

  ClientUserCouponsState({this.period, this.filter, this.type, this.couponId});
}

class ClientUserCouponsInitial extends ClientUserCouponsState {
  ClientUserCouponsInitial() : super();
}

class ClientUserCouponsLoading extends ClientUserCouponsState {
  ClientUserCouponsLoading({super.period, super.filter, super.type, super.couponId});
}

class ClientUserCouponsSucceed extends ClientUserCouponsState {
  final List<UserCoupon> userCoupons;
  ClientUserCouponsSucceed(this.userCoupons, {super.period, super.filter, super.type, super.couponId});
}

class ClientUserCouponsRefreshing extends ClientUserCouponsSucceed {
  ClientUserCouponsRefreshing(super.userCoupons, {super.period, super.filter, super.type, super.couponId});
}

class ClientUserCouponsFailed extends ClientUserCouponsState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserCouponsFailed(this.error, {super.period, super.filter, super.type, super.couponId});
}

class ClientUserCouponsNotifier extends StateNotifier<ClientUserCouponsState> with LoggerMixin {
  final ClientUserCouponsRepository userCouponsRepository;

  ClientUserCouponsNotifier({required this.userCouponsRepository}) : super(ClientUserCouponsInitial());

  Future<void> _load({
    int? period,
    bool clearPeriod = false,
    String? filter,
    int? type,
    bool clearType = false,
    String? couponId,
    bool clearCouponId = false,
    bool reload = false,
  }) async {
    if (state is ClientUserCouponsLoading) return debug(() => errorAlreadyInProgress.toString());
    period = (clearPeriod && period == null) ? null : (period ?? state.period);
    filter ??= state.filter;
    type = (clearType && type == null) ? null : (type ?? state.type);
    couponId = (clearCouponId && couponId == null) ? null : (couponId ?? state.couponId);
    if (period != state.period) reload = true;
    if (filter != state.filter) reload = true;
    if (type != state.type) reload = true;
    if (couponId != state.couponId) reload = true;
    if (!reload && cast<ClientUserCouponsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ClientUserCouponsRefreshing)
        state = ClientUserCouponsLoading(period: period, filter: filter, type: type, couponId: couponId);
      final userCoupons =
          await userCouponsRepository.readAll(period: period, filter: filter, type: type, couponId: couponId);
      state = ClientUserCouponsSucceed(userCoupons, period: period, filter: filter, type: type, couponId: couponId);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserCouponsFailed(err, period: period, filter: filter, type: type, couponId: couponId);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = ClientUserCouponsFailed(errorFailedToLoadDataEx(ex: ex),
          period: period, filter: filter, type: type, couponId: couponId);
    } catch (e) {
      warning(e.toString());
      state = ClientUserCouponsFailed(errorFailedToLoadData,
          period: period, filter: filter, type: type, couponId: couponId);
    }
  }

  Future<void> load({int? period, String? filter, int? type, String? couponId, bool reload = false}) =>
      _load(period: period, filter: filter, type: type, couponId: couponId);

  Future<void> loadPeriod(int? period) => _load(period: period, clearPeriod: true);

  Future<void> loadType(int? type) => _load(type: type, clearType: true);

  Future<void> loadCoupon(String? couponId) => _load(couponId: couponId, clearCouponId: true);

  Future<void> refresh() async {
    final succeed = cast<ClientUserCouponsSucceed>(state);
    if (succeed == null)
      return await _load(period: state.period, filter: state.filter, type: state.type, couponId: state.couponId);
    state = ClientUserCouponsRefreshing(succeed.userCoupons,
        period: succeed.period, filter: succeed.filter, type: succeed.type, couponId: succeed.couponId);
    await _load(reload: true);
  }
}

// eof

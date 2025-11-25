import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/coupon/coupons.dart";
import "../../repositories/leaflet/leaflet_overview.dart";

@immutable
abstract class PromoState {}

class PromoInitial extends PromoState {}

class PromoLoading extends PromoState {}

class PromoSucceed extends PromoState {
  final List<Coupon> newestCoupons;
  final List<Coupon> nearestCoupons;
  final List<LeafletOverview> leaflets;
  PromoSucceed({required this.newestCoupons, required this.nearestCoupons, required this.leaflets});
}

class PromoRefreshing extends PromoSucceed {
  PromoRefreshing({required super.newestCoupons, required super.nearestCoupons, required super.leaflets});
}

class PromoFailed extends PromoState implements FailedState {
  @override
  final CoreError error;
  @override
  PromoFailed(this.error);
}

class PromoNotifier extends StateNotifier<PromoState> with LoggerMixin {
  final DeviceRepository deviceRepository;

  final CouponsRepository remoteCoupons;
  final CouponsRepository localCoupons;
  final LeafletOverviewRepository remoteLeaflets;
  final LeafletOverviewRepository localLeaflets;

  PromoNotifier({
    required this.deviceRepository,
    required this.localCoupons,
    required this.remoteCoupons,
    required this.localLeaflets,
    required this.remoteLeaflets,
  }) : super(PromoInitial());

  Future<void> reset() async => state = PromoInitial();

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<PromoSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    if (state is PromoLoading) return debug(() => errorAlreadyInProgress.toString());

    try {
      if (state is! PromoRefreshing) state = PromoLoading();

      final user = deviceRepository.get(DeviceKey.user) as User;
      final country = CountryCode.fromCode(user.country);

      var newestCoupons = await localCoupons.newest();
      if ((newestCoupons?.isEmpty ?? true) || reload) {
        newestCoupons = await remoteCoupons.newest(ignoreCache: reload);
        if (newestCoupons != null) await localCoupons.createNewest(newestCoupons);
      }

      var nearestCoupons = await localCoupons.nearest();
      if ((nearestCoupons?.isEmpty ?? true) || reload) {
        nearestCoupons = await remoteCoupons.nearest(ignoreCache: reload);
        if (nearestCoupons != null) await localCoupons.createNearest(nearestCoupons);
      }

      var leaflets = await localLeaflets.newest(country);
      if ((leaflets?.isEmpty ?? true) || reload) {
        leaflets = await remoteLeaflets.newest(country, noCache: reload);
        if (leaflets != null) await localLeaflets.createAll(leaflets);
      }

      newestCoupons = newestCoupons?.take(5).toList();
      // substract nearestCoupons from newestCoupons
      //nearestCoupons = nearestCoupons?.where((e) => !newestCoupons!.contains(e)).take(5).toList();
      nearestCoupons = nearestCoupons?.take(5).toList();

      state = PromoSucceed(
        newestCoupons: newestCoupons ?? [],
        nearestCoupons: nearestCoupons ?? [],
        leaflets: leaflets ?? [],
      );
    } on CoreError catch (e) {
      error(e.toString());
      state = PromoFailed(e);
    } catch (e) {
      error(e.toString());
      state = PromoFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! PromoSucceed) return await _load(reload: true);
    final newestCoupons = cast<PromoSucceed>(state)!.newestCoupons;
    final nearestCoupons = cast<PromoSucceed>(state)!.nearestCoupons;
    final leaflets = cast<PromoSucceed>(state)!.leaflets;
    state = PromoRefreshing(newestCoupons: newestCoupons, nearestCoupons: nearestCoupons, leaflets: leaflets);
    await _load(reload: true);
  }
}

// eof

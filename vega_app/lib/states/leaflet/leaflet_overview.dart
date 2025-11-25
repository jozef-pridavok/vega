/*
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/leaflet/leaflet_overview.dart";

@immutable
abstract class LeafletOverviewState {}

class LeafletOverviewInitial extends LeafletOverviewState {}

class LeafletOverviewLoading extends LeafletOverviewState {}

class LeafletOverviewSucceed extends LeafletOverviewState {
  final List<LeafletOverview> leaflets;
  LeafletOverviewSucceed({required this.leaflets});
}

class LeafletOverviewRefreshing extends LeafletOverviewSucceed {
  LeafletOverviewRefreshing({required super.leaflets});
}

class LeafletOverviewFailed extends LeafletOverviewState implements FailedState {
  @override
  final CoreError? error;
  @override
  LeafletOverviewFailed(this.error);
}

class LeafletOverviewNotifier extends StateNotifier<LeafletOverviewState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final LeafletOverviewRepository remoteLeaflets;
  final LeafletOverviewRepository localLeaflets;

  LeafletOverviewNotifier({
    required this.deviceRepository,
    required this.localLeaflets,
    required this.remoteLeaflets,
  }) : super(LeafletOverviewInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<LeafletOverviewSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! LeafletOverviewRefreshing) state = LeafletOverviewLoading();

      final country = CountryCode.fromCode((deviceRepository.get(DeviceKey.user) as User).country);

      var leaflets = await localLeaflets.readAll(country);
      if ((leaflets?.isEmpty ?? true) || reload) {
        leaflets = await remoteLeaflets.readAll(country, noCache: reload);
        if (leaflets != null) localLeaflets.createAll(leaflets);
      }
      state = LeafletOverviewSucceed(leaflets: leaflets ?? []);
    } on CoreError catch (e) {
      error(e.toString());
      state = LeafletOverviewFailed(e);
    } catch (e) {
      error(e.toString());
      state = LeafletOverviewFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! LeafletOverviewSucceed) return;
    final leaflets = cast<LeafletOverviewSucceed>(state)!.leaflets;
    state = LeafletOverviewRefreshing(leaflets: leaflets);
    await _load(reload: true);
  }
}
*/
// eof

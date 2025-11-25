import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/dashboard.dart";
import "../repositories/dashboard.dart";

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSucceed extends DashboardState {
  final String language;
  final Dashboard dashboard;
  DashboardSucceed({
    required this.language,
    required this.dashboard,
  });
}

class DashboardRefreshing extends DashboardSucceed {
  DashboardRefreshing({
    required super.language,
    required super.dashboard,
  });
}

class DashboardFailed extends DashboardState implements FailedState {
  @override
  final CoreError error;
  DashboardFailed(this.error);
}

class DashboardNotifier extends StateNotifier<DashboardState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final DashboardRepository dashboardRepository;

  DashboardNotifier({
    required this.deviceRepository,
    required this.dashboardRepository,
  }) : super(DashboardInitial());

  void reset() => state = DashboardInitial();

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<DashboardSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! DashboardRefreshing) state = DashboardLoading();
      final language = (deviceRepository.get(DeviceKey.user) as User).language ?? "en";
      final dashboard = await dashboardRepository.read();
      state = DashboardSucceed(language: language, dashboard: dashboard);
    } on CoreError catch (err) {
      error(err.toString());
      state = DashboardFailed(err);
    } on Exception catch (ex) {
      error(ex.toString());
      state = DashboardFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      error(e.toString());
      state = DashboardFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<DashboardSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = DashboardRefreshing(language: succeed.language, dashboard: succeed.dashboard);
    await load(reload: true);
  }
}

// eof

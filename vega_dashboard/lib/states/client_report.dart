import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/dashboard.dart";

@immutable
abstract class ClientReportState {}

class ClientReportInitial extends ClientReportState {}

abstract class ClientReportStateWithSet {
  final ClientReportSet set;

  ClientReportStateWithSet({required this.set});
}

abstract class ClientReportStateWithData {
  final ClientReportSetData data;

  ClientReportStateWithData({required this.data});
}

class ClientReportLoading extends ClientReportState implements ClientReportStateWithSet {
  @override
  final ClientReportSet set;
  ClientReportLoading({required this.set});
}

class ClientReportSucceed extends ClientReportState implements ClientReportStateWithSet, ClientReportStateWithData {
  @override
  final ClientReportSet set;
  @override
  final ClientReportSetData data;
  ClientReportSucceed({required this.set, required this.data});
}

class ClientReportRefreshing extends ClientReportState implements ClientReportStateWithSet, ClientReportStateWithData {
  @override
  final ClientReportSet set;
  @override
  final ClientReportSetData data;
  ClientReportRefreshing({required this.set, required this.data});
}

class ClientReportFailed extends ClientReportState implements FailedState, ClientReportStateWithSet {
  @override
  final CoreError error;
  @override
  final ClientReportSet set;
  ClientReportFailed({required this.error, required this.set});
}

class ClientReportNotifier extends StateNotifier<ClientReportState> with LoggerMixin {
  final String setId;
  final DeviceRepository deviceRepository;
  final DashboardRepository dashboardRepository;

  ClientReportNotifier(
    this.setId, {
    required this.deviceRepository,
    required this.dashboardRepository,
  }) : super(ClientReportInitial());

  void reset() => state = ClientReportInitial();

  Future<void> load(ClientReportSet set, {bool reload = false}) async {
    if (!reload && cast<ClientReportSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ClientReportRefreshing) state = ClientReportLoading(set: set);
      final data = await dashboardRepository.clientReport(set);
      state = ClientReportSucceed(set: set, data: data);
    } on CoreError catch (err) {
      error(err.toString());
      state = ClientReportFailed(set: set, error: err);
    } on Exception catch (ex) {
      error(ex.toString());
      state = ClientReportFailed(set: set, error: errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      error(e.toString());
      state = ClientReportFailed(set: set, error: errorFailedToLoadData);
    }
  }

  Future<void> refresh({ClientReportSet? set}) async {
    final succeed = cast<ClientReportSucceed>(state);
    if (succeed == null) {
      if (set != null) return load(set, reload: true);
      return;
    }
    state = ClientReportRefreshing(set: set ?? succeed.set, data: succeed.data);
    await load(set ?? succeed.set, reload: true);
  }
}

// eof

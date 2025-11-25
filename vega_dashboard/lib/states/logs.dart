import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/logs.dart";

@immutable
abstract class LogsState {}

class LogsInitial extends LogsState {}

class LogsLoading extends LogsState {}

class LogsSucceed extends LogsState {
  final List<Log> logs;
  LogsSucceed(this.logs);
}

class LogsRefreshing extends LogsSucceed {
  LogsRefreshing(super.logs);
}

class LogsFailed extends LogsState implements FailedState {
  @override
  final CoreError error;
  LogsFailed(this.error);
}

class LogsNotifier extends StateNotifier<LogsState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final LogsRepository logsRepository;

  LogsNotifier({
    required this.deviceRepository,
    required this.logsRepository,
  }) : super(LogsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<LogsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! LogsRefreshing) state = LogsLoading();
      //final language = (deviceRepository.get(DeviceKey.user) as User).language ?? "en";
      final logs = await logsRepository.readAll(null);
      state = LogsSucceed(logs);
    } on CoreError catch (err) {
      error(err.toString());
      state = LogsFailed(err);
    } on Exception catch (ex) {
      error(ex.toString());
      state = LogsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      error(e.toString());
      state = LogsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<LogsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = LogsRefreshing(succeed.logs);
    await load(reload: true);
  }
}

// eof

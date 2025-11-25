import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/program/programs.dart";

@immutable
abstract class ProgramState {}

class ProgramInitial extends ProgramState {}

class ProgramLoading extends ProgramState {}

class ProgramSucceed extends ProgramState {
  final Program program;
  final int totalPoints;
  final List<int> stamps;

  ProgramSucceed({required this.program})
      : totalPoints = (program.rewards?.isNotEmpty ?? false) ? program.rewards!.map((e) => e.points).max : 0,
        stamps = (program.rewards?.isNotEmpty ?? false)
            ? List<int>.generate(program.rewards!.map((e) => e.points).max, (i) => i + 1)
            : [];
}

class ProgramRefreshing extends ProgramSucceed {
  ProgramRefreshing({required super.program});
}

class ProgramFailed extends ProgramState implements FailedState {
  @override
  final CoreError error;
  ProgramFailed(this.error);
}

class ProgramNotifier extends StateNotifier<ProgramState> with LoggerMixin {
  final String programId;
  final ProgramsRepository remoteRepository;
  final ProgramsRepository localRepository;

  ProgramNotifier(
    this.programId, {
    required this.remoteRepository,
    required this.localRepository,
  }) : super(ProgramInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<ProgramSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ProgramRefreshing) state = ProgramLoading();

      var program = await localRepository.read(programId);
      if (program == null || reload) {
        program = await remoteRepository.read(programId, ignoreCache: reload);
        if (program != null) await localRepository.create(program);
      }
      state = program != null ? ProgramSucceed(program: program) : ProgramFailed(errorFailedToLoadData);
    } on CoreError catch (e) {
      error(e.toString());
      state = ProgramFailed(e);
    } catch (e) {
      error(e.toString());
      state = ProgramFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! ProgramSucceed) return;
    final program = cast<ProgramSucceed>(state)!.program;
    state = ProgramRefreshing(program: program);
    await _load(reload: true);
  }

  Future<void> refreshBackground() async {
    if (!await isApiAvailable()) return;
    final program = await remoteRepository.read(programId, ignoreCache: true);
    if (program != null) {
      await localRepository.create(program);
      state = ProgramSucceed(program: program);
    }
  }
}

// eof

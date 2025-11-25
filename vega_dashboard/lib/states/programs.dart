import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/program.dart";

@immutable
abstract class ProgramsState {}

class ProgramsInitial extends ProgramsState {}

class ProgramsLoading extends ProgramsState {}

class ProgramsSucceed extends ProgramsState {
  final List<Program> programs;
  ProgramsSucceed({required this.programs});
}

class ProgramsRefreshing extends ProgramsSucceed {
  ProgramsRefreshing({required super.programs});
}

class ProgramsFailed extends ProgramsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProgramsFailed(this.error);
}

class ProgramsNotifier extends StateNotifier<ProgramsState> with StateMixin {
  final ProgramRepositoryFilter filter;
  final ProgramRepository programRepository;

  ProgramsNotifier(
    this.filter, {
    required this.programRepository,
  }) : super(ProgramsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ProgramsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProgramsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProgramsRefreshing) state = ProgramsLoading();
      final programs = await programRepository.readAll(filter: filter);
      state = ProgramsSucceed(programs: programs);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProgramsFailed(err);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = ProgramsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProgramsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<ProgramsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProgramsRefreshing(programs: succeed.programs);
    await load(reload: true);
  }

  bool added(Program program) {
    return next(state, [ProgramsSucceed], () {
      final programs = cast<ProgramsSucceed>(state)!.programs;
      final index = programs.indexWhere((e) => e.programId == program.programId);
      if (index != -1) return false;
      programs.insert(0, program);
      state = ProgramsSucceed(programs: programs);
      return true;
    });
  }

  bool updated(Program program) {
    return next(state, [ProgramsSucceed], () {
      final programs = cast<ProgramsSucceed>(state)!.programs;
      final index = programs.indexWhere((e) => e.programId == program.programId);
      if (index == -1) return false;
      programs.replaceRange(index, index + 1, [program]);
      state = ProgramsSucceed(programs: programs);
      return true;
    });
  }

  bool removed(Program program) {
    return next(state, [ProgramsSucceed], () {
      final programs = cast<ProgramsSucceed>(state)!.programs;
      final index = programs.indexWhere((r) => r.programId == program.programId);
      if (index == -1) return false;
      programs.removeAt(index);
      state = ProgramsSucceed(programs: programs);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<ProgramsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentPrograms = succeed.programs;
      final removedProgram = currentPrograms.removeAt(oldIndex);
      currentPrograms.insert(newIndex, removedProgram);
      final newPrograms = currentPrograms.map((card) => card.copyWith(rank: currentPrograms.indexOf(card))).toList();
      final reordered = await programRepository.reorder(newPrograms);
      state = reordered ? ProgramsSucceed(programs: newPrograms) : ProgramsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProgramsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ProgramsFailed(errorFailedToSaveData);
    }
  }
}

// eof

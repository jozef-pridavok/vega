import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../repositories/program.dart";

enum ProgramPatchPhase {
  initial,
  starting,
  started,
  finishing,
  finished,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  reordering,
  reordered,
  failed,
}

extension ProgramPatchPhaseBool on ProgramPatchPhase {
  bool get isInProgress =>
      this == ProgramPatchPhase.starting ||
      this == ProgramPatchPhase.finishing ||
      this == ProgramPatchPhase.blocking ||
      this == ProgramPatchPhase.unblocking ||
      this == ProgramPatchPhase.archiving ||
      this == ProgramPatchPhase.reordering;

  bool get isSuccessful =>
      this == ProgramPatchPhase.started ||
      this == ProgramPatchPhase.finished ||
      this == ProgramPatchPhase.blocked ||
      this == ProgramPatchPhase.unblocked ||
      this == ProgramPatchPhase.archived ||
      this == ProgramPatchPhase.reordered;
}

class ProgramPatchState {
  final ProgramPatchPhase phase;
  final Program program;
  ProgramPatchState(this.phase, this.program);

  factory ProgramPatchState.initial() => ProgramPatchState(ProgramPatchPhase.initial, DataModel.emptyProgram());

  factory ProgramPatchState.starting(Program program) => ProgramPatchState(ProgramPatchPhase.starting, program);
  factory ProgramPatchState.started(Program program) => ProgramPatchState(ProgramPatchPhase.started, program);

  factory ProgramPatchState.finishing(Program program) => ProgramPatchState(ProgramPatchPhase.finishing, program);
  factory ProgramPatchState.finished(Program program) => ProgramPatchState(ProgramPatchPhase.finished, program);

  factory ProgramPatchState.blocking(Program program) => ProgramPatchState(ProgramPatchPhase.blocking, program);
  factory ProgramPatchState.blocked(Program program) => ProgramPatchState(ProgramPatchPhase.blocked, program);

  factory ProgramPatchState.unblocking(Program program) => ProgramPatchState(ProgramPatchPhase.unblocking, program);
  factory ProgramPatchState.unblocked(Program program) => ProgramPatchState(ProgramPatchPhase.unblocked, program);

  factory ProgramPatchState.archiving(Program program) => ProgramPatchState(ProgramPatchPhase.archiving, program);
  factory ProgramPatchState.archived(Program program) => ProgramPatchState(ProgramPatchPhase.archived, program);

  factory ProgramPatchState.reordering(Program program) => ProgramPatchState(ProgramPatchPhase.reordering, program);
  factory ProgramPatchState.reordered(Program program) => ProgramPatchState(ProgramPatchPhase.reordered, program);
}

extension ProgramPatchStateToActionButtonState on ProgramPatchState {
  static const stateMap = {
    ProgramPatchPhase.starting: MoleculeActionButtonState.loading,
    ProgramPatchPhase.started: MoleculeActionButtonState.success,
    ProgramPatchPhase.finishing: MoleculeActionButtonState.loading,
    ProgramPatchPhase.finished: MoleculeActionButtonState.success,
    ProgramPatchPhase.blocking: MoleculeActionButtonState.loading,
    ProgramPatchPhase.blocked: MoleculeActionButtonState.success,
    ProgramPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ProgramPatchPhase.unblocked: MoleculeActionButtonState.success,
    ProgramPatchPhase.archiving: MoleculeActionButtonState.loading,
    ProgramPatchPhase.archived: MoleculeActionButtonState.success,
    ProgramPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProgramPatchFailed extends ProgramPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProgramPatchFailed(this.error, Program program) : super(ProgramPatchPhase.failed, program);

  factory ProgramPatchFailed.from(CoreError error, ProgramPatchState state) => ProgramPatchFailed(error, state.program);
}

class ProgramPatchNotifier extends StateNotifier<ProgramPatchState> with LoggerMixin {
  final ProgramRepository programRepository;

  ProgramPatchNotifier({
    required this.programRepository,
  }) : super(ProgramPatchState.initial());

  Future<void> reset() async => state = ProgramPatchState.initial();

  Future<void> start(Program program) async {
    try {
      state = ProgramPatchState.starting(program);
      bool started = await programRepository.start(program);
      state = started ? ProgramPatchState.started(program) : ProgramPatchFailed(errorFailedToSaveData, program);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramPatchFailed(errorFailedToSaveData, program);
    }
  }

  Future<void> finish(Program program) async {
    try {
      state = ProgramPatchState.finishing(program);
      bool stopped = await programRepository.finish(program);
      state = stopped ? ProgramPatchState.finished(program) : ProgramPatchFailed(errorFailedToSaveData, program);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramPatchFailed(errorFailedToSaveData, program);
    }
  }

  Future<void> block(Program program) async {
    try {
      state = ProgramPatchState.blocking(program);
      bool stopped = await programRepository.block(program);
      state = stopped
          ? ProgramPatchState.blocked(program.copyWith(blocked: true))
          : ProgramPatchFailed(errorFailedToSaveData, program);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramPatchFailed(errorFailedToSaveData, program);
    }
  }

  Future<void> unblock(Program program) async {
    try {
      state = ProgramPatchState.unblocking(program);
      bool stopped = await programRepository.unblock(program);
      state = stopped
          ? ProgramPatchState.unblocked(program.copyWith(blocked: false))
          : ProgramPatchFailed(errorFailedToSaveData, program);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramPatchFailed(errorFailedToSaveData, program);
    }
  }

  Future<void> archive(Program program) async {
    try {
      state = ProgramPatchState.archiving(program);
      bool archived = await programRepository.archive(program);
      state = archived ? ProgramPatchState.archived(program) : ProgramPatchFailed(errorFailedToSaveData, program);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramPatchFailed(errorFailedToSaveData, program);
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/program_actions.dart";

@immutable
abstract class ProgramActionState {}

class ProgramActionInitial extends ProgramActionState {}

class ProgramActionInProgress extends ProgramActionState {}

class ProgramActionSucceed extends ProgramActionState {}

class ProgramActionFailed extends ProgramActionState implements FailedState {
  @override
  final CoreError error;
  ProgramActionFailed(this.error);
}

class ProgramActionNotifier extends StateNotifier<ProgramActionState> with LoggerMixin {
  final ProgramActionRepository programAction;

  ProgramActionNotifier({required this.programAction}) : super(ProgramActionInitial());

  Future<void> reset() async {
    state = ProgramActionInitial();
  }

  Future<void> add(Program program, int points, {String? userCardId, String? number}) async {
    state = ProgramActionInProgress();
    try {
      await programAction.add(program.programId, points, userCardId: userCardId, number: number);
      state = ProgramActionSucceed();
    } on CoreError catch (ex) {
      warning(ex.toString());
      state = ProgramActionFailed(ex);
    } catch (e) {
      warning(e.toString());
      state = ProgramActionFailed(errorUnexpectedException(e));
    }
  }

  Future<void> subtract(Program program, int points, {String? userCardId, String? number}) async {
    state = ProgramActionInProgress();
    try {
      await programAction.subtract(program.programId, points, userCardId: userCardId, number: number);
      state = ProgramActionSucceed();
    } on CoreError catch (ex) {
      warning(ex.toString());
      state = ProgramActionFailed(ex);
    } catch (e) {
      warning(e.toString());
      state = ProgramActionFailed(errorUnexpectedException(e));
    }
  }
}

// eof

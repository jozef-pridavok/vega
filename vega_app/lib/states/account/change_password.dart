import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@immutable
abstract class ChangePasswordState {}

extension ChangePasswordStateToActionButtonState on ChangePasswordState {
  static const stateMap = {
    ChangePasswordInitial: MoleculeActionButtonState.idle,
    ChangePasswordInProgress: MoleculeActionButtonState.loading,
    ChangePasswordFailed: MoleculeActionButtonState.fail,
    ChangePasswordRequested: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordInProgress extends ChangePasswordState {}

class ChangePasswordRequested extends ChangePasswordState {
  ChangePasswordRequested();
}

class ChangePasswordFailed extends ChangePasswordState {
  final CoreError error;
  ChangePasswordFailed(this.error);
}

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> with LoggerMixin {
  final UserRepository remoteUser;

  ChangePasswordNotifier({required this.remoteUser}) : super(ChangePasswordInitial());

  void reset() => state = ChangePasswordInitial();

  Future<void> changePassword(String email, String password) async {
    if (state is! ChangePasswordInitial) return debug(() => errorUnexpectedState.toString());

    try {
      state = ChangePasswordInProgress();
      final requested = await remoteUser.changePassword(email, password);
      state = requested ? ChangePasswordRequested() : ChangePasswordFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      state = ChangePasswordFailed(err);
    } catch (ex) {
      state = ChangePasswordFailed(errorUnexpectedException(ex));
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@immutable
abstract class DeleteAccountState {}

extension DeleteAccountStateToActionButtonState on DeleteAccountState {
  static const stateMap = {
    DeleteAccountInProgress: MoleculeActionButtonState.loading,
    DeleteAccountFailed: MoleculeActionButtonState.fail,
    DeleteAccountSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends DeleteAccountState {}

class DeleteAccountSucceed extends DeleteAccountState {}

class DeleteAccountFailed extends DeleteAccountState implements FailedState {
  @override
  final CoreError error;
  DeleteAccountFailed(this.error);
}

class DeleteAccountNotifier extends StateNotifier<DeleteAccountState> with StateMixin {
  final DeviceRepository deviceRepository;
  final UserRepository remoteUser;

  DeleteAccountNotifier({required this.deviceRepository, required this.remoteUser}) : super(DeleteAccountInitial());

  void reset() => state = DeleteAccountInitial();

  Future<void> delete() async {
    if (state is! DeleteAccountInitial) return debug(() => errorUnexpectedState.toString());

    try {
      state = DeleteAccountInProgress();
      final deleted = await remoteUser.delete();
      if (deleted) deviceRepository.clearAll();
      state = deleted ? DeleteAccountSucceed() : DeleteAccountFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      state = DeleteAccountFailed(err);
    } catch (ex) {
      state = DeleteAccountFailed(errorUnexpectedException(ex));
    }
  }
}

// eof

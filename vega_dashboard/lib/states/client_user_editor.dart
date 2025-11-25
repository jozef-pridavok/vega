import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_users.dart";

@immutable
abstract class ClientUserEditorState {}

extension ClientUserEditorStateToActionButtonState on ClientUserEditorState {
  static const stateMap = {
    ClientUserSaving: MoleculeActionButtonState.loading,
    ClientUserSaved: MoleculeActionButtonState.success,
    ClientUserEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientUserEditorInitial extends ClientUserEditorState {}

class ClientUserSaving extends ClientUserEditorState {
  final User user;
  final bool isNew;
  ClientUserSaving(this.user, {this.isNew = false});
}

class ClientUserSaved extends ClientUserSaving {
  ClientUserSaved(super.user, {super.isNew = false});
}

class ClientUserEditorFailed extends ClientUserSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserEditorFailed(this.error, super.user);
}

class ClientUserEditorNotifier extends StateNotifier<ClientUserEditorState> with StateMixin {
  final ClientUserRepository clientUserRepository;

  ClientUserEditorNotifier({
    required this.clientUserRepository,
  }) : super(ClientUserEditorInitial());

  void reset() => state = ClientUserEditorInitial();

  Future<void> create(User user, String password) async {
    try {
      state = ClientUserSaving(user);
      user.userId = uuid();
      final saved = await clientUserRepository.create(user, password);
      state = saved ? ClientUserSaved(user) : ClientUserEditorFailed(errorFailedToSaveData, user);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserEditorFailed(err, user);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientUserEditorFailed(errorFailedToSaveData, user);
    }
  }

  Future<void> save(User user, String password) async {
    try {
      state = ClientUserSaving(user);
      final saved = await clientUserRepository.update(user, password);
      state = saved ? ClientUserSaved(user) : ClientUserEditorFailed(errorFailedToSaveData, user);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserEditorFailed(err, user);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientUserEditorFailed(errorFailedToSaveData, user);
    }
  }
}

// eof

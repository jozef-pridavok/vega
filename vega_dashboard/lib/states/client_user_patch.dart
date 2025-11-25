import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_users.dart";

@immutable
abstract class ClientUserPatchState {}

extension ClientUserPatchStateToActionButtonState on ClientUserPatchState {
  static const stateMap = {
    ClientUserPatching: MoleculeActionButtonState.loading,
    ClientUserPatched: MoleculeActionButtonState.success,
    ClientUserPatchFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientUserPatchInitial extends ClientUserPatchState {}

enum ClientUserPatchType { block, unblock, archive }

class ClientUserPatching extends ClientUserPatchState {
  final ClientUserPatchType type;
  final User user;
  ClientUserPatching(this.type, this.user);
}

class ClientUserPatched extends ClientUserPatching {
  ClientUserPatched._(super.type, super.user);

  factory ClientUserPatched.from(ClientUserPatching state) => ClientUserPatched._(state.type, state.user);
}

class ClientUserPatchFailed extends ClientUserPatching implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserPatchFailed._(this.error, super.type, super.user);

  factory ClientUserPatchFailed.from(CoreError error, ClientUserPatching state) =>
      ClientUserPatchFailed._(error, state.type, state.user);
}

class ClientUserPatchNotifier extends StateNotifier<ClientUserPatchState> with StateMixin {
  final ClientUserRepository clientUserRepository;

  ClientUserPatchNotifier({
    required this.clientUserRepository,
  }) : super(ClientUserPatchInitial());

  void reset() => state = ClientUserPatchInitial();

  Future<void> _patch(User user, ClientUserPatchType type) async {
    if (expect<ClientUserPatchInitial>(state) == null) return;
    final patching = ClientUserPatching(type, user);
    try {
      state = patching;
      bool patched = false;
      switch (type) {
        case ClientUserPatchType.block:
          patched = await clientUserRepository.block(user);
          break;
        case ClientUserPatchType.unblock:
          patched = await clientUserRepository.unblock(user);
          break;
        case ClientUserPatchType.archive:
          patched = await clientUserRepository.archive(user);
          break;
      }
      state = patched ? ClientUserPatched.from(patching) : ClientUserPatchFailed.from(errorFailedToSaveData, patching);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientUserPatchFailed.from(errorFailedToSaveData, patching);
    }
  }

  Future<void> block(User user) => _patch(user, ClientUserPatchType.block);

  Future<void> unblock(User user) => _patch(user, ClientUserPatchType.unblock);

  Future<void> archive(User user) => _patch(user, ClientUserPatchType.archive);
}

// eof

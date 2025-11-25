import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/client_card.dart";

enum ClientCardPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
}

class ClientCardPatchState {
  final ClientCardPatchPhase phase;
  final Card card;
  ClientCardPatchState(this.phase, this.card);

  factory ClientCardPatchState.initial() => ClientCardPatchState(ClientCardPatchPhase.initial, DataModel.emptyCard());

  factory ClientCardPatchState.blocking(Card card) => ClientCardPatchState(ClientCardPatchPhase.blocking, card);
  factory ClientCardPatchState.blocked(Card card) => ClientCardPatchState(ClientCardPatchPhase.blocked, card);

  factory ClientCardPatchState.unblocking(Card card) => ClientCardPatchState(ClientCardPatchPhase.unblocking, card);
  factory ClientCardPatchState.unblocked(Card card) => ClientCardPatchState(ClientCardPatchPhase.unblocked, card);

  factory ClientCardPatchState.archiving(Card card) => ClientCardPatchState(ClientCardPatchPhase.archiving, card);
  factory ClientCardPatchState.archived(Card card) => ClientCardPatchState(ClientCardPatchPhase.archived, card);
}

extension ClientCardPatchStateToActionButtonState on ClientCardPatchState {
  static const stateMap = {
    ClientCardPatchPhase.blocking: MoleculeActionButtonState.loading,
    ClientCardPatchPhase.blocked: MoleculeActionButtonState.success,
    ClientCardPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ClientCardPatchPhase.unblocked: MoleculeActionButtonState.success,
    ClientCardPatchPhase.archiving: MoleculeActionButtonState.loading,
    ClientCardPatchPhase.archived: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ClientCardPatchFailed extends ClientCardPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientCardPatchFailed(this.error, ClientCardPatchPhase phase, Card card) : super(phase, card);
}

class ClientCardPatchNotifier extends StateNotifier<ClientCardPatchState> with LoggerMixin {
  final ClientCardRepository repository;

  ClientCardPatchNotifier({required this.repository}) : super(ClientCardPatchState.initial());

  reset() => state = ClientCardPatchState.initial();

  Future<void> block(Card card) async {
    final op = ClientCardPatchPhase.blocking;
    try {
      state = ClientCardPatchState.blocking(card);
      bool blocked = await repository.block(card);
      state = blocked
          ? ClientCardPatchState.blocked(card.copyWith(blocked: true))
          : ClientCardPatchFailed(errorFailedToSaveData, op, card);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientCardPatchFailed(errorFailedToSaveData, op, card);
    }
  }

  Future<void> unblock(Card card) async {
    final op = ClientCardPatchPhase.unblocking;
    try {
      state = ClientCardPatchState.unblocking(card);
      bool unblocked = await repository.unblock(card);
      state = unblocked
          ? ClientCardPatchState.unblocked(card.copyWith(blocked: false))
          : ClientCardPatchFailed(errorFailedToSaveData, op, card);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientCardPatchFailed(errorFailedToSaveData, op, card);
    }
  }

  Future<void> archive(Card card) async {
    final op = ClientCardPatchPhase.archiving;
    try {
      state = ClientCardPatchState.archiving(card);
      bool archived = await repository.archive(card);
      state = archived ? ClientCardPatchState.archived(card) : ClientCardPatchFailed(errorFailedToSaveData, op, card);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientCardPatchFailed(errorFailedToSaveData, op, card);
    }
  }
}

// eof

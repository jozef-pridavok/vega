import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/seller_client.dart";

@immutable
abstract class SellerClientPatchState {
  bool get isSucceed =>
      this is SellerClientBlocked ||
      this is SellerClientUnblocked ||
      this is SellerClientArchived ||
      this is SellerClientDemoCreditSet;
}

extension SellerClientPatchStateToActionButtonState on SellerClientPatchState {
  static const stateMap = {
    SellerClientPatchInProgress: MoleculeActionButtonState.loading,
    SellerClientBlocked: MoleculeActionButtonState.success,
    SellerClientUnblocked: MoleculeActionButtonState.success,
    SellerClientArchived: MoleculeActionButtonState.success,
    SellerClientPatchFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class SellerClientPatchInitial extends SellerClientPatchState {}

class SellerClientPatchInProgress extends SellerClientPatchState {
  final Client client;

  SellerClientPatchInProgress(this.client);
}

class SellerClientBlocked extends SellerClientPatchInProgress {
  SellerClientBlocked(super.client);
}

class SellerClientUnblocked extends SellerClientPatchInProgress {
  SellerClientUnblocked(super.client);
}

class SellerClientArchived extends SellerClientPatchInProgress {
  SellerClientArchived(super.client);
}

class SellerClientDemoCreditSet extends SellerClientPatchInProgress {
  SellerClientDemoCreditSet(super.client);
}

class SellerClientPatchFailed extends SellerClientPatchInProgress implements FailedState {
  @override
  final CoreError error;
  @override
  SellerClientPatchFailed(super.client, this.error);
}

class SellerClientPatchNotifier extends StateNotifier<SellerClientPatchState> with LoggerMixin {
  final SellerClientRepository sellerClientRepository;

  SellerClientPatchNotifier({
    required this.sellerClientRepository,
  }) : super(SellerClientPatchInitial());

  Future<void> reset() async => state = SellerClientPatchInitial();

  Future<void> block(Client client) async {
    try {
      state = SellerClientPatchInProgress(client);
      bool blocked = await sellerClientRepository.block(client);
      state = blocked ? SellerClientBlocked(client) : SellerClientPatchFailed(client, errorFailedToSaveData);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientPatchFailed(client, errorFailedToSaveData);
    }
  }

  Future<void> unblock(Client client) async {
    try {
      state = SellerClientPatchInProgress(client);
      bool unblocked = await sellerClientRepository.unblock(client);
      state = unblocked ? SellerClientUnblocked(client) : SellerClientPatchFailed(client, errorFailedToSaveData);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientPatchFailed(client, errorFailedToSaveData);
    }
  }

  Future<void> archive(Client client) async {
    try {
      state = SellerClientPatchInProgress(client);
      final archived = await sellerClientRepository.archive(client);
      state = archived ? SellerClientArchived(client) : SellerClientPatchFailed(client, errorFailedToSaveData);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientPatchFailed(client, errorFailedToSaveData);
    }
  }

  Future<void> setDemoCredit(Client client, int fraction) async {
    try {
      state = SellerClientPatchInProgress(client);
      final updated = await sellerClientRepository.setDemoCredit(client, fraction);
      state = updated ? SellerClientDemoCreditSet(client) : SellerClientPatchFailed(client, errorFailedToSaveData);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientPatchFailed(client, errorFailedToSaveData);
    }
  }
}

// eof

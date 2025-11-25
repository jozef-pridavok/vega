import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/user/user_cards.dart";

@immutable
abstract class EditUserCardState {
  final UserCard userCard;
  const EditUserCardState(this.userCard);
}

extension UpdateUserCardStateToActionButtonState on EditUserCardState {
  static const stateMap = {
    EditUserCardInitial: MoleculeActionButtonState.idle,
    EditUserCardSaving: MoleculeActionButtonState.loading,
    EditUserCardFailed: MoleculeActionButtonState.fail,
    EditUserCardSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class EditUserCardInitial extends EditUserCardState {
  const EditUserCardInitial(super.userCard);
}

class EditUserCardSaving extends EditUserCardState {
  const EditUserCardSaving(super.userCard);
}

class EditUserCardSucceed extends EditUserCardState {
  const EditUserCardSucceed(super.userCard);
}

class EditUserCardFailed extends EditUserCardState implements FailedState {
  @override
  final CoreError error;
  const EditUserCardFailed(this.error, super.userCard);
}

class EditUserCardNotifier extends StateNotifier<EditUserCardState> with StateMixin {
  final UserCard userCard;
  final UserCardsRepository remote;
  final UserCardsRepository local;

  EditUserCardNotifier(
    this.userCard, {
    required this.remote,
    required this.local,
  }) : super(EditUserCardInitial(userCard));

  void reset() => state = EditUserCardInitial(state.userCard);

  Future<void> save(bool isNew, {String? name, String? number, String? notes}) async {
    final currentState = expect<EditUserCardInitial>(state);
    if (currentState == null) return;

    final userCard = currentState.userCard.copyWith(name: name, number: number, notes: notes);
    state = EditUserCardSaving(userCard);
    try {
      bool localAffected = isNew ? await local.create(userCard) : await local.update(userCard);
      if (localAffected && await isApiAvailable()) {
        final remoteAffected = isNew ? await remote.create(userCard) : await remote.update(userCard);
        if (remoteAffected) await (local as SyncedLocalRepository).synced(userCard);
        //await sync(
        //  localRepository as SyncedLocalRepository<UserCard>,
        //  remoteRepository as SyncedRemoteRepository<UserCard>,
        //);
      }

      if (!localAffected) {
        state = EditUserCardFailed(errorFailedToSaveData, userCard);
        return;
      }

      state = EditUserCardSucceed(
        userCard.copyWith(name: name, number: number, notes: notes),
      );
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = EditUserCardFailed(err, userCard);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = EditUserCardFailed(errorFailedToSaveDataEx(ex: ex), userCard);
    } catch (e) {
      verbose(() => e.toString());
      state = EditUserCardFailed(errorFailedToSaveData, userCard);
    }
  }
}

// eof

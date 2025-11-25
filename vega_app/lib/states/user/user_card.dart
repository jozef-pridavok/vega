import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/user/user_cards.dart";

@immutable
abstract class UserCardState {}

extension UserCardStateToActionButtonState on UserCardState {
  static const stateMap = {
    UserCardLoading: MoleculeActionButtonState.loading,
    UserCardRefreshing: MoleculeActionButtonState.loading,
    UserCardFailed: MoleculeActionButtonState.fail,
    UserCardLoaded: MoleculeActionButtonState.idle,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class UserCardInitial extends UserCardState {}

class UserCardLoading extends UserCardState {}

class UserCardLoaded extends UserCardState {
  final UserCard userCard;
  UserCardLoaded({required this.userCard});
}

class UserCardRefreshing extends UserCardLoaded {
  UserCardRefreshing({required super.userCard});
}

class UserCardFailed extends UserCardState implements FailedState {
  @override
  final CoreError error;
  @override
  UserCardFailed(this.error);
}

class UserCardNotifier extends StateNotifier<UserCardState> with StateMixin {
  final String userCardId;
  final UserCardsRepository remoteRepository;
  final UserCardsRepository localRepository;

  UserCardNotifier(
    this.userCardId, {
    required this.remoteRepository,
    required this.localRepository,
  }) : super(UserCardInitial());

  void reset() => state = UserCardInitial();

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<UserCardLoaded>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! UserCardRefreshing) state = UserCardLoading();

      //await Future.delayed(const Duration(seconds: 5));

      var userCard = await localRepository.read(userCardId);
      if (userCard == null || reload) {
        userCard = await remoteRepository.read(userCardId, ignoreCache: reload);
        if (userCard != null) await localRepository.create(userCard);
      }
      if (userCard != null) state = UserCardLoaded(userCard: userCard..synced());
    } on CoreError catch (e) {
      error(e.toString());
      state = UserCardFailed(e);
    } catch (e) {
      error(e.toString());
      state = UserCardFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() async => _load();

  Future<void> refresh() async {
    final succeed = cast<UserCardLoaded>(state);
    if (succeed != null) state = UserCardRefreshing(userCard: succeed.userCard);
    await _load(reload: true);
  }

  Future<void> refreshOnBackground() async {
    if (state is UserCardInitial) return _load(reload: true);
    final succeed = expect<UserCardLoaded>(state);
    if (succeed == null) return;
    if (!await isApiAvailable()) return;
    final userCard = await remoteRepository.read(userCardId, ignoreCache: true);
    if (userCard != null) {
      await localRepository.create(userCard);
      state = UserCardLoaded(userCard: userCard..synced());
    }
  }

  void updateCard(UserCard userCard) {
    if (state is UserCardInitial) {
      state = UserCardLoaded(userCard: userCard);
      return;
    }

    final loaded = expect<UserCardLoaded>(state);
    if (loaded == null) return;

    final src = loaded.userCard;
    if (src.userCardId != userCard.userCardId) return debug(() => "userCardId mismatch");

    state = UserCardLoaded(userCard: src.copyWith(name: userCard.name, number: userCard.number, notes: userCard.notes));
  }
}

// eof

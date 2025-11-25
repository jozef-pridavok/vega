import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/card/cards.dart";

@immutable
abstract class CardsState {}

class CardsInitial extends CardsState {}

class CardsLoading extends CardsState {}

class CardsSucceed extends CardsState {
  final User user;

  final List<Card> cards;

  CardsSucceed({required this.user, required this.cards});
}

class CardsRefreshing extends CardsSucceed {
  CardsRefreshing({required super.user, required super.cards});
}

class CardsFailed extends CardsState {
  final CoreError error;
  CardsFailed(this.error);
}

class CardsNotifier extends StateNotifier<CardsState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final CardsRepository remoteCardsRepository;
  final CardsRepository localCardsRepository;

  CardsNotifier({
    required this.deviceRepository,
    required this.remoteCardsRepository,
    required this.localCardsRepository,
  }) : super(CardsInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<CardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! CardsRefreshing) state = CardsLoading();

      // Hive does not return null
      List<Card>? cards = await localCardsRepository.readAll() ?? [];
      if (!reload) {
        // no local data but is online
        if (cards.isEmpty && await isApiAvailable()) {
          cards = await _sync();
        } else {
          // no local data and no internet connection
          if (cards.isEmpty) {
            debug(() => errorCannotLoadInOfflineMode.toString());
            state = CardsFailed(errorCannotLoadInOfflineMode);
            return;
          }
        }
      } else {
        // forced reload and is online
        if (await isApiAvailable()) {
          cards = await _sync();
        } else {
          // forced reload but no internet connection
          // TODO: notify that he is in offline mode
          debug(() => errorCannotLoadInOfflineMode.toString());
          state = CardsFailed(errorCannotLoadInOfflineMode);
          return;
        }
      }
      final user = deviceRepository.get(DeviceKey.user) as User;
      state = CardsSucceed(user: user, cards: cards);
    } on CoreError catch (e) {
      error(e.toString());
      state = CardsFailed(e);
    } catch (e) {
      error(e.toString());
      state = CardsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() async {
    final succeed = cast<CardsSucceed>(state);
    if (succeed == null) return;
    state = CardsRefreshing(user: succeed.user, cards: succeed.cards);
    await _load(reload: true);
  }

  Future<List<Card>> _sync() async {
    return await remoteCardsRepository.readAll() ?? [];
  }
}

// eof

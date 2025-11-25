import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_card.dart";

@immutable
abstract class ClientCardsState {}

class ClientCardsInitial extends ClientCardsState {}

class ClientCardsLoading extends ClientCardsState {}

class ClientCardsSucceed extends ClientCardsState {
  final List<Card> cards;
  ClientCardsSucceed({required this.cards});
}

class ClientCardsRefreshing extends ClientCardsSucceed {
  ClientCardsRefreshing({required super.cards});
}

class ClientCardsFailed extends ClientCardsState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientCardsFailed(this.error);
}

class ClientCardsDeleteSucceed extends ClientCardsSucceed {
  ClientCardsDeleteSucceed({required super.cards});
}

class ClientCardsOperationFailed extends ClientCardsSucceed implements FailedState {
  @override
  final CoreError error;
  ClientCardsOperationFailed(this.error, {required super.cards});
}

class ClientCardsNotifier extends StateNotifier<ClientCardsState> with StateMixin {
  final ClientCardRepositoryFilter filter;
  final ClientCardRepository clientCardRepository;

  ClientCardsNotifier(this.filter, {required this.clientCardRepository}) : super(ClientCardsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ClientCardsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false, bool resetToSucceedState = false}) async {
    if (!reload && cast<ClientCardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    if (resetToSucceedState) {
      final currentState = cast<ClientCardsOperationFailed>(state)!;
      state = ClientCardsSucceed(cards: currentState.cards);
      return;
    }
    try {
      if (state is! ClientCardsRefreshing) state = ClientCardsLoading();
      final cards = await clientCardRepository.readAll(filter: filter);
      state = ClientCardsSucceed(cards: cards);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientCardsFailed(err);
    } on Exception catch (ex) {
      state = ClientCardsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientCardsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<ClientCardsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ClientCardsRefreshing(cards: succeed.cards);
    await load(reload: true);
  }

  bool added(Card card) {
    return next(state, [ClientCardsSucceed], () {
      final cards = cast<ClientCardsSucceed>(state)!.cards;
      final index = cards.indexWhere((e) => e.cardId == card.cardId);
      if (index != -1) return false;
      cards.insert(0, card);
      state = ClientCardsSucceed(cards: cards);
      return true;
    });
  }

  bool updated(Card card) {
    return next(state, [ClientCardsSucceed], () {
      final cards = cast<ClientCardsSucceed>(state)!.cards;
      final index = cards.indexWhere((e) => e.cardId == card.cardId);
      if (index == -1) return false;
      cards.replaceRange(index, index + 1, [card]);
      state = ClientCardsSucceed(cards: cards);
      return true;
    });
  }

  bool removed(Card card) {
    return next(state, [ClientCardsSucceed], () {
      final cards = cast<ClientCardsSucceed>(state)!.cards;
      final index = cards.indexWhere((r) => r.cardId == card.cardId);
      if (index == -1) return false;
      cards.removeAt(index);
      state = ClientCardsSucceed(cards: cards);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<ClientCardsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentCards = succeed.cards;
      final removedCard = currentCards.removeAt(oldIndex);
      currentCards.insert(newIndex, removedCard);
      final newCards = currentCards.map((card) => card.copyWith(rank: currentCards.indexOf(card))).toList();
      final reordered = await clientCardRepository.reorder(newCards);
      state = reordered ? ClientCardsSucceed(cards: newCards) : ClientCardsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientCardsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ClientCardsFailed(errorFailedToSaveData);
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/card/cards.dart";

@immutable
abstract class TopCardsState {}

class TopCardsInitial extends TopCardsState {}

class TopCardsLoading extends TopCardsState {}

class TopCardsSucceed extends TopCardsState {
  final List<Card> cards;
  TopCardsSucceed({required this.cards});
}

class TopCardsRefreshing extends TopCardsSucceed {
  TopCardsRefreshing({required super.cards});
}

class TopCardsFailed extends TopCardsState {
  final CoreError error;
  TopCardsFailed(this.error);
}

class TopCardsNotifier extends StateNotifier<TopCardsState> with LoggerMixin {
  final CardsRepository cardsRepository;

  TopCardsNotifier({
    required this.cardsRepository,
  }) : super(TopCardsInitial());

  Future<void> _load({String? term, bool reload = false}) async {
    if (!reload && cast<TopCardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! TopCardsRefreshing) state = TopCardsLoading();
      final cards = term == null ? await cardsRepository.readTop(limit: 10) : await cardsRepository.search(term);
      state = TopCardsSucceed(cards: cards ?? []);
    } on CoreError catch (e) {
      error(e.toString());
      state = TopCardsFailed(e);
    } catch (e) {
      error(e.toString());
      state = TopCardsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> search(String term) => _load(term: term, reload: true);

  Future<void> refresh() async {
    final succeed = cast<TopCardsSucceed>(state);
    if (succeed == null) return;
    state = TopCardsRefreshing(cards: succeed.cards);
    await _load(reload: true);
  }
}

// eof

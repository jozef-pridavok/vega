import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/card/cards.dart";

@immutable
abstract class SearchCardsState {}

class SearchCardsInitial extends SearchCardsState {}

class SearchCardsInProgress extends SearchCardsState {}

class SearchCardsSucceed extends SearchCardsState {
  final List<Card> cards;
  SearchCardsSucceed({required this.cards});
}

class SearchCardsFailed extends SearchCardsState {
  final CoreError error;
  SearchCardsFailed(this.error);
}

class SearchCardsNotifier extends StateNotifier<SearchCardsState> with LoggerMixin {
  final CardsRepository remoteCardsRepository;

  SearchCardsNotifier({
    required this.remoteCardsRepository,
  }) : super(SearchCardsInitial());

  Future<void> load(String term) async {
    if (cast<SearchCardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      state = SearchCardsInProgress();
      List<Card>? cards = await remoteCardsRepository.readTop(limit: 10) ?? [];
      state = SearchCardsSucceed(cards: cards);
    } on CoreError catch (e) {
      error(e.toString());
      state = SearchCardsFailed(e);
    } catch (e) {
      error(e.toString());
      state = SearchCardsFailed(errorUnexpectedException(e));
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_user_cards.dart";

@immutable
abstract class ClientUserCardsState {
  final int? period;
  final String? filter;
  final String? programId;
  final String? cardId;

  ClientUserCardsState({this.period, this.filter, this.programId, this.cardId});
}

class ClientUserCardsInitial extends ClientUserCardsState {
  ClientUserCardsInitial() : super();
}

class ClientUserCardsLoading extends ClientUserCardsState {
  ClientUserCardsLoading({super.period, super.filter, super.programId, super.cardId});
}

class ClientUserCardsSucceed extends ClientUserCardsState {
  final List<UserCard> userCards;
  ClientUserCardsSucceed(this.userCards, {super.period, super.filter, super.programId, super.cardId});
}

class ClientUserCardsRefreshing extends ClientUserCardsSucceed {
  ClientUserCardsRefreshing(super.userCards, {super.period, super.filter, super.programId, super.cardId});
}

class ClientUserCardsFailed extends ClientUserCardsState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserCardsFailed(this.error, {super.period, super.filter, super.programId, super.cardId});
}

class ClientUserCardsNotifier extends StateNotifier<ClientUserCardsState> with LoggerMixin {
  final ClientUserCardsRepository userCardsRepository;

  ClientUserCardsNotifier({required this.userCardsRepository}) : super(ClientUserCardsInitial());

  Future<void> _load({
    int? period,
    bool clearPeriod = false,
    String? filter,
    String? cardId,
    bool clearCardId = false,
    String? programId,
    bool clearProgramId = false,
    bool reload = false,
  }) async {
    if (state is ClientUserCardsLoading) return debug(() => errorAlreadyInProgress.toString());
    period = (clearPeriod && period == null) ? null : (period ?? state.period);
    filter ??= state.filter;
    cardId = (clearCardId && cardId == null) ? null : (cardId ?? state.cardId);
    programId = (clearProgramId && programId == null) ? null : (programId ?? state.programId);
    if (period != state.period) reload = true;
    if (filter != state.filter) reload = true;
    if (cardId != state.cardId) reload = true;
    if (programId != state.programId) reload = true;
    if (!reload && cast<ClientUserCardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ClientUserCardsRefreshing)
        state = ClientUserCardsLoading(period: period, filter: filter, programId: programId, cardId: cardId);
      final userCards =
          await userCardsRepository.readAll(period: period, filter: filter, programId: programId, cardId: cardId);
      state = ClientUserCardsSucceed(userCards, period: period, filter: filter, programId: programId, cardId: cardId);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserCardsFailed(err, period: period, filter: filter, programId: programId, cardId: cardId);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = ClientUserCardsFailed(errorFailedToLoadDataEx(ex: ex),
          period: period, filter: filter, programId: programId, cardId: cardId);
    } catch (e) {
      warning(e.toString());
      state = ClientUserCardsFailed(errorFailedToLoadData,
          period: period, filter: filter, programId: programId, cardId: cardId);
    }
  }

  Future<void> load({int? period, String? filter, bool reload = false}) => _load(period: period, filter: filter);

  Future<void> loadProgram(String? programId) => _load(programId: programId, clearProgramId: true);

  Future<void> loadCard(String? cardId) => _load(cardId: cardId, clearCardId: true);

  Future<void> loadPeriod(int? period) => _load(period: period, clearPeriod: true);

  Future<void> refresh() async {
    final succeed = cast<ClientUserCardsSucceed>(state);
    if (succeed == null)
      return await _load(period: state.period, filter: state.filter, cardId: state.cardId, programId: state.programId);
    state = ClientUserCardsRefreshing(succeed.userCards,
        period: succeed.period, filter: succeed.filter, programId: succeed.programId, cardId: succeed.cardId);
    await _load(reload: true);
  }
}

// eof

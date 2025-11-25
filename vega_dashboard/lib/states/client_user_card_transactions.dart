import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_user_cards.dart";

@immutable
abstract class ClientUserCardTransactionsState {
  final String userCardId;
  final List<LoyaltyTransaction> transactions;

  ClientUserCardTransactionsState({required this.userCardId, required this.transactions});
}

class ClientUserCardTransactionsInitial extends ClientUserCardTransactionsState {
  ClientUserCardTransactionsInitial({required super.userCardId, required super.transactions});
}

class ClientUserCardTransactionsLoading extends ClientUserCardTransactionsState {
  ClientUserCardTransactionsLoading({required super.userCardId, required super.transactions});

  factory ClientUserCardTransactionsLoading.from(ClientUserCardTransactionsState state) =>
      ClientUserCardTransactionsLoading(userCardId: state.userCardId, transactions: state.transactions);
}

class ClientUserCardTransactionsSucceed extends ClientUserCardTransactionsState {
  ClientUserCardTransactionsSucceed({required super.userCardId, required super.transactions});

  factory ClientUserCardTransactionsSucceed.from(ClientUserCardTransactionsState state) =>
      ClientUserCardTransactionsSucceed(userCardId: state.userCardId, transactions: state.transactions);
}

class ClientUserCardTransactionsRefreshing extends ClientUserCardTransactionsSucceed {
  ClientUserCardTransactionsRefreshing({required super.userCardId, required super.transactions});

  factory ClientUserCardTransactionsRefreshing.from(ClientUserCardTransactionsState state) =>
      ClientUserCardTransactionsRefreshing(userCardId: state.userCardId, transactions: state.transactions);
}

class ClientUserCardTransactionsFailed extends ClientUserCardTransactionsState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserCardTransactionsFailed(this.error, {required super.userCardId, required super.transactions});

  factory ClientUserCardTransactionsFailed.from(CoreError error, ClientUserCardTransactionsState state) =>
      ClientUserCardTransactionsFailed(error, userCardId: state.userCardId, transactions: state.transactions);
}

class ClientUserCardTransactionsNotifier extends StateNotifier<ClientUserCardTransactionsState> with LoggerMixin {
  final ClientUserCardsRepository userCardsRepository;

  ClientUserCardTransactionsNotifier({
    required this.userCardsRepository,
  }) : super(ClientUserCardTransactionsInitial(userCardId: "", transactions: []));

  Future<void> load({String? userCardId, bool reload = false}) async {
    if (!reload && cast<ClientUserCardTransactionsSucceed>(state)?.userCardId == userCardId)
      return debug(() => errorAlreadyLoaded.toString());

    userCardId ??= cast<ClientUserCardTransactionsSucceed>(state)?.userCardId;
    if (userCardId == null) return debug(() => errorNoData.toString());

    try {
      if (state is! ClientUserCardTransactionsRefreshing) state = ClientUserCardTransactionsLoading.from(state);
      final transactions = await userCardsRepository.transactions(userCardId);
      state = ClientUserCardTransactionsSucceed(userCardId: userCardId, transactions: transactions);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserCardTransactionsFailed.from(err, state);
    } on Exception catch (ex) {
      state = ClientUserCardTransactionsFailed.from(errorFailedToLoadDataEx(ex: ex), state);
    } catch (e) {
      warning(e.toString());
      state = ClientUserCardTransactionsFailed.from(errorFailedToLoadData, state);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<ClientUserCardTransactionsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ClientUserCardTransactionsRefreshing.from(state);
    await load(reload: true);
  }
}

// eof

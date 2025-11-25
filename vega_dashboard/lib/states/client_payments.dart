import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_payment.dart";

@immutable
abstract class ClientPaymentsState {}

class ClientPaymentsInitial extends ClientPaymentsState {}

class ClientPaymentsLoading extends ClientPaymentsState {}

class ClientPaymentsSucceed extends ClientPaymentsState {
  final List<ClientPaymentProvider> providers;
  final List<ClientPayment> payments;
  ClientPaymentsSucceed({required this.providers, required this.payments});
}

class ClientPaymentsRefreshing extends ClientPaymentsSucceed {
  ClientPaymentsRefreshing({required super.providers, required super.payments});
}

class ClientPaymentsFailed extends ClientPaymentsState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientPaymentsFailed(this.error);
}

class ClientPaymentsNotifier extends StateNotifier<ClientPaymentsState> with LoggerMixin {
  final ClientPaymentRepositoryFilter filter;
  final ClientPaymentRepository paymentRepository;

  ClientPaymentsNotifier(
    this.filter, {
    required this.paymentRepository,
  }) : super(ClientPaymentsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ClientPaymentsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ClientPaymentsRefreshing) state = ClientPaymentsLoading();
      final (providers, payments) = filter == ClientPaymentRepositoryFilter.unpaid
          ? await paymentRepository.read(onlyUnpaid: true)
          : await paymentRepository.read(dateFrom: filter.dateFrom, dateTo: filter.dateTo);
      state = ClientPaymentsSucceed(providers: providers, payments: payments);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientPaymentsFailed(err);
    } on Exception catch (ex) {
      state = ClientPaymentsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientPaymentsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ClientPaymentsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ClientPaymentsRefreshing(providers: succeed.providers, payments: succeed.payments);
    await load(reload: true);
  }
}

// eof

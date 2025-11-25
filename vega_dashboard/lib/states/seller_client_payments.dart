import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_payment.dart";

@immutable
abstract class SellerClientPaymentsState {}

class SellerClientPaymentsInitial extends SellerClientPaymentsState {}

class SellerClientPaymentsLoading extends SellerClientPaymentsState {}

class SellerClientPaymentsSucceed extends SellerClientPaymentsState {
  final List<ClientPayment> payments;
  final List<ClientPayment> selected;
  SellerClientPaymentsSucceed({required this.payments, this.selected = const []});

  bool get hasSelected => selected.isNotEmpty;

  bool isSelected(ClientPayment payment) =>
      selected.map((e) => e.clientPaymentId).toList().contains(payment.clientPaymentId);
}

class SellerClientPaymentsRefreshing extends SellerClientPaymentsSucceed {
  SellerClientPaymentsRefreshing({required super.payments});
}

class SellerClientPaymentsFailed extends SellerClientPaymentsState implements FailedState {
  @override
  final CoreError error;
  @override
  SellerClientPaymentsFailed(this.error);
}

class SellerClientPaymentsNotifier extends StateNotifier<SellerClientPaymentsState> with LoggerMixin {
  final SellerPaymentRepositoryClientFilter filter;
  final ClientPaymentRepository paymentRepository;

  SellerClientPaymentsNotifier(
    this.filter, {
    required this.paymentRepository,
  }) : super(SellerClientPaymentsInitial());

  void reset() => state = SellerClientPaymentsInitial();

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<SellerClientPaymentsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! SellerClientPaymentsRefreshing) state = SellerClientPaymentsLoading();
      final payments = await paymentRepository.forSeller(filter);
      state = SellerClientPaymentsSucceed(payments: payments);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerClientPaymentsFailed(err);
    } on Exception catch (ex) {
      state = SellerClientPaymentsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SellerClientPaymentsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<SellerClientPaymentsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = SellerClientPaymentsRefreshing(payments: succeed.payments);
    await load(reload: true);
  }

  Future<void> toggle(ClientPayment payment) async {
    final succeed = cast<SellerClientPaymentsSucceed>(state);
    if (succeed == null) return;
    var selected = succeed.selected.toList();
    var clientPaymentId = payment.clientPaymentId;
    if (selected.map((e) => e.clientPaymentId).toList().contains(clientPaymentId)) {
      selected.removeWhere((e) => e.clientPaymentId == clientPaymentId);
    } else {
      selected.add(payment);
    }
    state = SellerClientPaymentsSucceed(payments: succeed.payments, selected: selected);
  }
}

// eof

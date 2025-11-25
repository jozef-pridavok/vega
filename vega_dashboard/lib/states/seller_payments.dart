import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/seller_payment.dart";

@immutable
abstract class SellerPaymentsState {}

class SellerPaymentsInitial extends SellerPaymentsState {}

class SellerPaymentsLoading extends SellerPaymentsState {}

class SellerPaymentsSucceed extends SellerPaymentsState {
  final List<SellerPayment> payments;
  SellerPaymentsSucceed({required this.payments});
}

class SellerPaymentsRefreshing extends SellerPaymentsSucceed {
  SellerPaymentsRefreshing({required super.payments});
}

class SellerPaymentsFailed extends SellerPaymentsState implements FailedState {
  @override
  final CoreError error;
  @override
  SellerPaymentsFailed(this.error);
}

class SellerPaymentsNotifier extends StateNotifier<SellerPaymentsState> with LoggerMixin {
  final SellerPaymentRepositoryFilter filter;
  final SellerPaymentRepository paymentRepository;

  SellerPaymentsNotifier(
    this.filter, {
    required this.paymentRepository,
  }) : super(SellerPaymentsInitial());

  void reset() => state = SellerPaymentsInitial();

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<SellerPaymentsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! SellerPaymentsRefreshing) state = SellerPaymentsLoading();
      final payments = await paymentRepository.read(filter);
      state = SellerPaymentsSucceed(payments: payments);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerPaymentsFailed(err);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = SellerPaymentsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SellerPaymentsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<SellerPaymentsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = SellerPaymentsRefreshing(payments: succeed.payments);
    await load(reload: true);
  }
}

// eof

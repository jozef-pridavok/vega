import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/seller_payment.dart";

@immutable
abstract class SellerPaymentRequestState {}

extension SellerPaymentRequestStateActionButtonState on SellerPaymentRequestState {
  static const stateMap = {
    SellerPaymentRequestRequesting: MoleculeActionButtonState.loading,
    SellerPaymentRequestSucceed: MoleculeActionButtonState.success,
    SellerPaymentRequestFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class SellerPaymentRequestInitial extends SellerPaymentRequestState {}

class SellerPaymentRequestRequesting extends SellerPaymentRequestState {}

class SellerPaymentRequestSucceed extends SellerPaymentRequestState {
  final SellerPayment payment;
  SellerPaymentRequestSucceed({required this.payment});
}

class SellerPaymentRequestFailed extends SellerPaymentRequestState implements FailedState {
  @override
  final CoreError error;
  @override
  SellerPaymentRequestFailed(this.error);
}

class SellerPaymentRequestNotifier extends StateNotifier<SellerPaymentRequestState> with LoggerMixin {
  final SellerPaymentRepository paymentRepository;

  SellerPaymentRequestNotifier({
    required this.paymentRepository,
  }) : super(SellerPaymentRequestInitial());

  Future<void> reset() async => state = SellerPaymentRequestInitial();

  Future<void> requestPayment(List<ClientPayment> clientPayments, String invoiceNumber, IntDate? dueDate) async {
    try {
      final requesting = cast<SellerPaymentRequestRequesting>(state);
      if (requesting != null) return debug(() => errorAlreadyInProgress.toString());
      state = SellerPaymentRequestRequesting();
      final sellerPayment = await paymentRepository.request(clientPayments, invoiceNumber, dueDate);
      state = SellerPaymentRequestSucceed(payment: sellerPayment);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerPaymentRequestFailed(err);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = SellerPaymentRequestFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SellerPaymentRequestFailed(errorFailedToLoadData);
    }
  }
}

// eof

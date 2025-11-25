import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_stripe/flutter_stripe.dart";
import "package:vega_dashboard/repositories/client_payment.dart";

@immutable
abstract class ClientPaymentState {}

extension ClientPaymentPayStateActionButtonState on ClientPaymentState {
  static const stateMap = {
    ClientPaymentInProgress: MoleculeActionButtonState.loading,
    ClientPaymentFinished: MoleculeActionButtonState.success,
    ClientPaymentFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientPaymentInitial extends ClientPaymentState {}

class ClientPaymentInProgress extends ClientPaymentInitial {
  ClientPaymentInProgress();
}

class ClientPaymentFinished extends ClientPaymentInitial {
  final ClientPayment payment;
  ClientPaymentFinished(this.payment);

  bool hasPayment(ClientPayment payment) => this.payment.clientPaymentId == payment.clientPaymentId;
}

class ClientPaymentFailed extends ClientPaymentState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientPaymentFailed(this.error);
}

class ClientPaymentNotifier extends StateNotifier<ClientPaymentState> with LoggerMixin {
  final ClientPaymentRepository paymentRepository;

  ClientPaymentNotifier({
    required this.paymentRepository,
  }) : super(ClientPaymentInitial());

  Future<void> reset() async {
    state = ClientPaymentInitial();
  }

  Future<void> pay(ClientPaymentProvider provider, ClientPayment payment, Price price) async {
    try {
      state = ClientPaymentInProgress();

      if (kDebugMode) await Future.delayed(const Duration(seconds: 3));

      if (provider.type == ClientPaymentProviderType.stripe)
        await _payByStripe(provider, payment, price);
      else if (provider.type == ClientPaymentProviderType.demoCredit)
        await _payByDemoCredit(provider, payment, price);
      else
        throw Exception("Unsupported payment provider type: ${provider.type}");
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientPaymentFailed(err);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = ClientPaymentFailed(errorUnexpectedException(ex));
    } catch (e) {
      warning(e.toString());
      state = ClientPaymentFailed(errorUnexpectedException(e));
    }
  }

  Future<void> _payByStripe(ClientPaymentProvider provider, ClientPayment payment, Price price) async {
    final payments = [payment];
    final clientSecret = await paymentRepository.startStripePayment(provider, payments, price);
    final publicKey = provider.clientConfig?["publicKey"];
    if (publicKey == null) throw Exception("Invalid Stripe public key");
    Stripe.publishableKey = publicKey;
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
        options: const PaymentMethodOptions(setupFutureUsage: PaymentIntentsFutureUsage.OffSession),
      );
      final payload = paymentIntent.toJson();
      switch (paymentIntent.status) {
        case PaymentIntentsStatus.Succeeded:
          await paymentRepository.confirm(provider, payments, payload);
          state = ClientPaymentFinished(payment);
          break;
        case PaymentIntentsStatus.Canceled:
          await paymentRepository.cancel(provider, payments, {});
          state = ClientPaymentFailed(errorCancelled);
          break;
        case PaymentIntentsStatus.RequiresPaymentMethod:
        case PaymentIntentsStatus.RequiresConfirmation:
        case PaymentIntentsStatus.RequiresAction:
        case PaymentIntentsStatus.RequiresCapture:
        case PaymentIntentsStatus.Unknown:
          await paymentRepository.cancel(provider, payments, payload);
          state = ClientPaymentFailed(errorUnexpectedException("Stripe unexpected status: ${paymentIntent.status}"));
          break;
        case PaymentIntentsStatus.Processing:
          break;
      }
    } catch (e) {
      warning(e.toString());
      try {
        await paymentRepository.cancel(provider, payments, {"exception": e.toString()});
      } catch (e) {
        warning(e.toString());
      }
      throw errorUnexpectedException(e is StripeException ? (e.error.localizedMessage?.toString() ?? e) : e);
    }
  }

  Future<void> _payByDemoCredit(ClientPaymentProvider provider, ClientPayment payment, Price price) async {
    final payments = [payment];
    try {
      final charged = await paymentRepository.startDemoCreditPayment(provider, payments, price);
      if (charged) {
        await paymentRepository.confirm(provider, payments, {});
        state = ClientPaymentFinished(payment);
      } else {
        await paymentRepository.cancel(provider, payments, {});
        state = ClientPaymentFailed(errorCancelled);
      }
    } catch (e) {
      warning(e.toString());
      try {
        await paymentRepository.cancel(provider, payments, {"exception": e.toString()});
        state = ClientPaymentFailed(errorCancelled);
      } catch (e) {
        warning(e.toString());
        state = ClientPaymentFailed(errorUnexpectedException(e));
      }
      throw errorUnexpectedException(e is StripeException ? (e.error.localizedMessage?.toString() ?? e) : e);
    }
  }
}

// eof

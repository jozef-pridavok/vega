import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/repositories/currency.dart";

@immutable
abstract class ClientPaymentCalcState {}

class ClientPaymentCalcInitial extends ClientPaymentCalcState {}

class ClientPaymentCalcBase extends ClientPaymentCalcState {
  final ClientPaymentProvider provider;
  final ClientPayment payment;
  ClientPaymentCalcBase({required this.provider, required this.payment});

  bool isSame(ClientPaymentProvider provider, ClientPayment payment) =>
      this.provider.clientPaymentProviderId == provider.clientPaymentProviderId &&
      this.payment.clientPaymentId == payment.clientPaymentId;

  bool get isSameCurrency => provider.currency.code == payment.currency.code;
}

class ClientPaymentCalculating extends ClientPaymentCalcBase {
  ClientPaymentCalculating({required super.provider, required super.payment});
}

class ClientPaymentSucceed extends ClientPaymentCalcBase {
  final int totalPriceInProviderCurrency;
  final int totalPriceInPaymentCurrency;
  ClientPaymentSucceed({
    required super.provider,
    required super.payment,
    required this.totalPriceInProviderCurrency,
    required this.totalPriceInPaymentCurrency,
  });

  String formatPriceForProvider(String locale) => provider.currency.formatSymbol(totalPriceInProviderCurrency, locale);

  String formatPriceForPayment(String locale) => payment.currency.formatSymbol(totalPriceInPaymentCurrency, locale);

  String formatBothPrice(String locale) =>
      provider.currency.formatSymbol(totalPriceInProviderCurrency, locale) +
      (isSameCurrency ? "" : " / ${payment.currency.formatSymbol(totalPriceInPaymentCurrency, locale)}");
}

class ClientPaymentCalcFailed extends ClientPaymentCalcState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientPaymentCalcFailed(this.error);
}

class ClientPaymentCalcNotifier extends StateNotifier<ClientPaymentCalcState> with LoggerMixin {
  final CurrencyRepository currencyRepository;

  ClientPaymentCalcNotifier({
    required this.currencyRepository,
  }) : super(ClientPaymentCalcInitial());

  Future<void> calculate(ClientPaymentProvider provider, ClientPayment payment) async {
    try {
      state = ClientPaymentCalculating(provider: provider, payment: payment);

      final providerCurrency = provider.currency;
      final paymentCurrency = payment.currency;

      double rate = 1.0;
      final needConversion = providerCurrency.code != paymentCurrency.code;

      if (needConversion) {
        final pair = "${paymentCurrency.code}:${providerCurrency.code}";
        //await Future.delayed(const Duration(seconds: 3));
        rate = await currencyRepository.latest(pair);
      }

      final vegaPriceInPaymentCurrency = payment.totalPrice;
      final totalPriceInPaymentCurrency = vegaPriceInPaymentCurrency +
          paymentCurrency.collapse(providerCurrency.expand(provider.fixedPrice) / rate) +
          (vegaPriceInPaymentCurrency * (provider.percentage / 10000.0));

      final vegaPriceInProviderCurrency = providerCurrency.collapse(paymentCurrency.expand(payment.totalPrice) * rate);
      final totalPriceInProviderCurrency = vegaPriceInProviderCurrency +
          provider.fixedPrice +
          (vegaPriceInProviderCurrency * (provider.percentage / 10000.0));

      state = ClientPaymentSucceed(
        provider: provider,
        payment: payment,
        totalPriceInProviderCurrency: totalPriceInProviderCurrency.round(),
        totalPriceInPaymentCurrency: totalPriceInPaymentCurrency.round(),
      );
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientPaymentCalcFailed(err);
    } on Exception catch (ex) {
      state = ClientPaymentCalcFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientPaymentCalcFailed(errorFailedToLoadData);
    }
  }
}

// eof

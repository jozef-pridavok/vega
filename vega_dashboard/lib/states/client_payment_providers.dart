import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_payment_provider.dart";

@immutable
abstract class ClientPaymentProvidersState {}

class ClientPaymentProvidersInitial extends ClientPaymentProvidersState {}

class SellerClientLoading extends ClientPaymentProvidersState {}

class ClientPaymentProvidersSucceed extends ClientPaymentProvidersState {
  final List<ClientPaymentProvider> providers;
  ClientPaymentProvidersSucceed({required this.providers});
}

class ClientPaymentProvidersRefreshing extends ClientPaymentProvidersSucceed {
  ClientPaymentProvidersRefreshing({required super.providers});
}

class ClientPaymentProvidersFailed extends ClientPaymentProvidersState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientPaymentProvidersFailed(this.error);
}

class ClientPaymentProvidersNotifier extends StateNotifier<ClientPaymentProvidersState> with LoggerMixin {
  final ClientPaymentProviderRepository providerRepository;

  ClientPaymentProvidersNotifier({
    required this.providerRepository,
  }) : super(ClientPaymentProvidersInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ClientPaymentProvidersSucceed>(state) != null)
      return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ClientPaymentProvidersRefreshing) state = SellerClientLoading();
      final providers = await providerRepository.readAll();
      state = ClientPaymentProvidersSucceed(providers: providers);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientPaymentProvidersFailed(err);
    } on Exception catch (ex) {
      state = ClientPaymentProvidersFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientPaymentProvidersFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ClientPaymentProvidersSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ClientPaymentProvidersRefreshing(providers: succeed.providers);
    await load(reload: true);
  }
}

// eof

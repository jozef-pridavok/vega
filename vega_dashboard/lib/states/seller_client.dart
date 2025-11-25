import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/seller_client.dart";

@immutable
abstract class SellerClientsState {}

class SellerClientsInitial extends SellerClientsState {}

class SellerClientLoading extends SellerClientsState {}

class ClientPaymentProviders extends SellerClientsState {
  final List<ClientPaymentProvider> providerPayment;
  ClientPaymentProviders({required this.providerPayment});
}

class SellerClientsSucceed extends SellerClientsState {
  final List<Client> clients;
  SellerClientsSucceed({required this.clients});
}

class SellerClientsRefreshing extends SellerClientsSucceed {
  SellerClientsRefreshing({required super.clients});
}

class SellerClientsFailed extends SellerClientsState implements FailedState {
  @override
  final CoreError error;
  @override
  SellerClientsFailed(this.error);
}

class SellerClientsNotifier extends StateNotifier<SellerClientsState> with LoggerMixin {
  final SellerClientRepositoryFilter filter;
  final SellerClientRepository sellerClientRepository;

  SellerClientsNotifier(
    this.filter, {
    required this.sellerClientRepository,
  }) : super(SellerClientsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<SellerClientsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! SellerClientsRefreshing) state = SellerClientLoading();
      final client = await sellerClientRepository.readAll(filter: filter);
      state = SellerClientsSucceed(clients: client);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerClientsFailed(err);
    } on Exception catch (ex) {
      state = SellerClientsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SellerClientsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<SellerClientsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = SellerClientsRefreshing(clients: succeed.clients);
    await load(reload: true);
  }
}

// eof

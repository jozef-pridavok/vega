import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/order/offers.dart";

@immutable
abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersSucceed extends OffersState {
  final List<ProductOffer> offers;

  OffersSucceed({required this.offers});
}

class OffersRefreshing extends OffersSucceed {
  OffersRefreshing({required super.offers});
}

class OffersFailed extends OffersState implements FailedState {
  @override
  final CoreError error;
  OffersFailed(this.error);
}

class OffersNotifier extends StateNotifier<OffersState> with LoggerMixin {
  final String clientId;
  final OffersRepository offersRepository;

  OffersNotifier(this.clientId, {required this.offersRepository}) : super(OffersInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<OffersSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! OffersRefreshing) state = OffersLoading();
      final offers = await offersRepository.readAll(clientId);
      state = OffersSucceed(offers: offers);
    } on CoreError catch (e) {
      error(e.toString());
      state = OffersFailed(e);
    } catch (e) {
      error(e.toString());
      state = OffersFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! OffersSucceed) return;
    final offers = cast<OffersSucceed>(state)!.offers;
    state = OffersRefreshing(offers: offers);
    await _load(reload: true);
  }
}

// eof

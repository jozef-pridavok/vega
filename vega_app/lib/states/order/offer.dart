import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/order/offers.dart";

@immutable
abstract class OfferState {
  final ProductOffer offer;
  const OfferState(this.offer);
}

class OfferInitial extends OfferState {
  const OfferInitial(super.offer);
}

class OfferLoading extends OfferState {
  const OfferLoading(super.offer);
}

class OfferReady extends OfferState {
  const OfferReady(super.offer);

  List<ProductItem>? get items => offer.items;

  List<ProductItem>? getItems(String? sectionId) => items?.where((item) => item.sectionId == sectionId).sorted();
}

class OfferRefreshing extends OfferReady {
  const OfferRefreshing(super.offer);
}

class OfferLoadingFailed extends OfferState implements FailedState {
  @override
  final CoreError error;
  @override
  const OfferLoadingFailed(this.error, super.offers);
}

class OfferNotifier extends StateNotifier<OfferState> with LoggerMixin {
  final String offerId;
  final DeviceRepository deviceRepository;
  final OffersRepository offersRepository;

  OfferNotifier(this.offerId, {required this.offersRepository, required this.deviceRepository})
      : super(OfferInitial(ProductOffer.empty()));

  Future<void> reset() async => state = OfferInitial(state.offer);

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<OfferReady>(state) != null) {
      return debug(() => errorAlreadyLoaded.toString());
    }

    try {
      if (state is! OfferRefreshing) state = OfferLoading(state.offer);

      final offer = await offersRepository.read(offerId);
      //if (offer == null || reload) {
      //  offer = await offers.read(offerId, noCache: reload);
      //  if (offer != null) localRepository.create(program);
      //}
      if (offer != null) state = OfferReady(offer);
    } on CoreError catch (e) {
      error(e.toString());
      state = OfferLoadingFailed(e, state.offer);
    } catch (e) {
      error(e.toString());
      state = OfferLoadingFailed(errorUnexpectedException(e), state.offer);
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! OfferReady) return;
    final offer = cast<OfferReady>(state)!.offer;
    state = OfferRefreshing(offer);
    await _load(reload: true);
  }
}
// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_offer.dart";
import "../repositories/product_offer.dart";

@immutable
abstract class ProductOffersState {}

class ProductOffersInitial extends ProductOffersState {}

class ProductOffersLoading extends ProductOffersState {}

class ProductOffersSucceed extends ProductOffersState {
  final List<ProductOffer> productOffers;
  ProductOffersSucceed({required this.productOffers});
}

class ProductOffersRefreshing extends ProductOffersSucceed {
  ProductOffersRefreshing({required super.productOffers});
}

class ProductOffersFailed extends ProductOffersState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOffersFailed(this.error);
}

class ProductOffersNotifier extends StateNotifier<ProductOffersState> with LoggerMixin {
  final ProductOfferRepositoryFilter filter;
  final ProductOfferRepository productOfferRepository;

  ProductOffersNotifier(
    this.filter, {
    required this.productOfferRepository,
  }) : super(ProductOffersInitial());

  void reset() => state = ProductOffersInitial();

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductOffersSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductOffersRefreshing) state = ProductOffersLoading();
      final productOffers = await productOfferRepository.readAll(filter: filter);
      state = ProductOffersSucceed(productOffers: productOffers);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductOffersFailed(err);
    } on Exception catch (ex) {
      state = ProductOffersFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductOffersFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<ProductOffersSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductOffersRefreshing(productOffers: succeed.productOffers);
    await load(reload: true);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (state is! ProductOffersSucceed) return debug(() => errorUnexpectedState.toString());
    try {
      final currentProductOffers = cast<ProductOffersSucceed>(state)!.productOffers;
      final removedProductOffer = currentProductOffers.removeAt(oldIndex);
      currentProductOffers.insert(newIndex, removedProductOffer);
      final newProductOffers =
          currentProductOffers.map((offer) => offer.copyWith(rank: currentProductOffers.indexOf(offer))).toList();
      state = ProductOffersRefreshing(productOffers: newProductOffers);
      // ignore: unused_local_variable
      final affected = await productOfferRepository.reorder(newProductOffers);
      state = ProductOffersSucceed(productOffers: newProductOffers);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductOffersFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ProductOffersFailed(errorFailedToSaveData);
    }
  }
}

// eof

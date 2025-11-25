import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_offer.dart";

enum ProductOfferPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  failed,
}

extension ProductOfferPatchPhaseBool on ProductOfferPatchPhase {
  bool get isInProgress =>
      this == ProductOfferPatchPhase.blocking ||
      this == ProductOfferPatchPhase.unblocking ||
      this == ProductOfferPatchPhase.archiving;

  bool get isSuccessful =>
      this == ProductOfferPatchPhase.blocked ||
      this == ProductOfferPatchPhase.unblocked ||
      this == ProductOfferPatchPhase.archived;
}

class ProductOfferPatchState {
  final ProductOfferPatchPhase phase;
  final ProductOffer productOffer;
  ProductOfferPatchState(this.phase, this.productOffer);

  factory ProductOfferPatchState.initial() =>
      ProductOfferPatchState(ProductOfferPatchPhase.initial, ProductOffer.empty());

  factory ProductOfferPatchState.blocking(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.blocking, productOffer);
  factory ProductOfferPatchState.blocked(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.blocked, productOffer);

  factory ProductOfferPatchState.unblocking(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.unblocking, productOffer);
  factory ProductOfferPatchState.unblocked(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.unblocked, productOffer);

  factory ProductOfferPatchState.archiving(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.archiving, productOffer);
  factory ProductOfferPatchState.archived(ProductOffer productOffer) =>
      ProductOfferPatchState(ProductOfferPatchPhase.archived, productOffer);
}

extension ProductOfferPatchStateToActionButtonState on ProductOfferPatchState {
  static const stateMap = {
    ProductOfferPatchPhase.blocking: MoleculeActionButtonState.loading,
    ProductOfferPatchPhase.blocked: MoleculeActionButtonState.success,
    ProductOfferPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ProductOfferPatchPhase.unblocked: MoleculeActionButtonState.success,
    ProductOfferPatchPhase.archiving: MoleculeActionButtonState.loading,
    ProductOfferPatchPhase.archived: MoleculeActionButtonState.success,
    ProductOfferPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProductOfferPatchFailed extends ProductOfferPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOfferPatchFailed(this.error, ProductOffer productOffer) : super(ProductOfferPatchPhase.failed, productOffer);

  factory ProductOfferPatchFailed.from(CoreError error, ProductOfferPatchState state) =>
      ProductOfferPatchFailed(error, state.productOffer);
}

class ProductOfferPatchNotifier extends StateNotifier<ProductOfferPatchState> with LoggerMixin {
  final ProductOfferRepository productOfferRepository;

  ProductOfferPatchNotifier({
    required this.productOfferRepository,
  }) : super(ProductOfferPatchState.initial());

  Future<void> reset() async => state = ProductOfferPatchState.initial();

  Future<void> block(ProductOffer productOffer) async {
    try {
      state = ProductOfferPatchState.blocking(productOffer);
      bool stopped = await productOfferRepository.block(productOffer);
      state = stopped
          ? ProductOfferPatchState.blocked(productOffer)
          : ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    }
  }

  Future<void> unblock(ProductOffer productOffer) async {
    try {
      state = ProductOfferPatchState.unblocking(productOffer);
      bool stopped = await productOfferRepository.unblock(productOffer);
      state = stopped
          ? ProductOfferPatchState.unblocked(productOffer)
          : ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    }
  }

  Future<void> archive(ProductOffer productOffer) async {
    try {
      state = ProductOfferPatchState.archiving(productOffer);
      bool archived = await productOfferRepository.archive(productOffer);
      state = archived
          ? ProductOfferPatchState.archived(productOffer)
          : ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOfferPatchFailed(errorFailedToSaveData, productOffer);
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_item_modification.dart";

enum ProductItemModificationPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  failed,
}

extension ProductItemModificationPatchPhaseBool on ProductItemModificationPatchPhase {
  bool get isInProgress =>
      this == ProductItemModificationPatchPhase.blocking ||
      this == ProductItemModificationPatchPhase.unblocking ||
      this == ProductItemModificationPatchPhase.archiving;

  bool get isSuccessful =>
      this == ProductItemModificationPatchPhase.blocked ||
      this == ProductItemModificationPatchPhase.unblocked ||
      this == ProductItemModificationPatchPhase.archived;
}

class ProductItemModificationPatchState {
  final ProductItemModificationPatchPhase phase;
  final ProductItemModification productItemModification;
  ProductItemModificationPatchState(this.phase, this.productItemModification);

  factory ProductItemModificationPatchState.initial() =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.initial, ProductItemModification.empty());

  factory ProductItemModificationPatchState.blocking(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.blocking, productItemModification);
  factory ProductItemModificationPatchState.blocked(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.blocked, productItemModification);

  factory ProductItemModificationPatchState.unblocking(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.unblocking, productItemModification);
  factory ProductItemModificationPatchState.unblocked(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.unblocked, productItemModification);

  factory ProductItemModificationPatchState.archiving(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.archiving, productItemModification);
  factory ProductItemModificationPatchState.archived(ProductItemModification productItemModification) =>
      ProductItemModificationPatchState(ProductItemModificationPatchPhase.archived, productItemModification);
}

extension ProductItemModificationPatchStateToActionButtonState on ProductItemModificationPatchState {
  static const stateMap = {
    ProductItemModificationPatchPhase.blocking: MoleculeActionButtonState.loading,
    ProductItemModificationPatchPhase.blocked: MoleculeActionButtonState.success,
    ProductItemModificationPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ProductItemModificationPatchPhase.unblocked: MoleculeActionButtonState.success,
    ProductItemModificationPatchPhase.archiving: MoleculeActionButtonState.loading,
    ProductItemModificationPatchPhase.archived: MoleculeActionButtonState.success,
    ProductItemModificationPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProductItemModificationPatchFailed extends ProductItemModificationPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemModificationPatchFailed(this.error, ProductItemModification productItemModification)
      : super(ProductItemModificationPatchPhase.failed, productItemModification);

  factory ProductItemModificationPatchFailed.from(CoreError error, ProductItemModificationPatchState state) =>
      ProductItemModificationPatchFailed(error, state.productItemModification);
}

class ProductItemModificationPatchNotifier extends StateNotifier<ProductItemModificationPatchState> with LoggerMixin {
  final ProductItemModificationRepository productItemModificationRepository;

  ProductItemModificationPatchNotifier({
    required this.productItemModificationRepository,
  }) : super(ProductItemModificationPatchState.initial());

  Future<void> reset() async => state = ProductItemModificationPatchState.initial();

  Future<void> archive(ProductItemModification productItemModification) async {
    try {
      state = ProductItemModificationPatchState.archiving(productItemModification);
      bool archived = await productItemModificationRepository.archive(productItemModification);
      state = archived
          ? ProductItemModificationPatchState.archived(productItemModification)
          : ProductItemModificationPatchFailed(errorFailedToSaveData, productItemModification);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemModificationPatchFailed(errorFailedToSaveData, productItemModification);
    }
  }
}

// eof

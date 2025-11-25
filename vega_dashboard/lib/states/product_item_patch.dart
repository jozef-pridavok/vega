import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_item.dart";

enum ProductItemPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  changingSection,
  changedSection,
  failed,
}

extension ProductItemPatchPhaseBool on ProductItemPatchPhase {
  bool get isInProgress =>
      this == ProductItemPatchPhase.blocking ||
      this == ProductItemPatchPhase.unblocking ||
      this == ProductItemPatchPhase.archiving ||
      this == ProductItemPatchPhase.changingSection;

  bool get isSuccessful =>
      this == ProductItemPatchPhase.blocked ||
      this == ProductItemPatchPhase.unblocked ||
      this == ProductItemPatchPhase.archived ||
      this == ProductItemPatchPhase.changedSection;
}

class ProductItemPatchState {
  final ProductItemPatchPhase phase;
  final ProductItem productItem;
  ProductItemPatchState(this.phase, this.productItem);

  factory ProductItemPatchState.initial() => ProductItemPatchState(ProductItemPatchPhase.initial, ProductItem.empty());

  factory ProductItemPatchState.blocking(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.blocking, productItem);
  factory ProductItemPatchState.blocked(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.blocked, productItem);

  factory ProductItemPatchState.unblocking(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.unblocking, productItem);
  factory ProductItemPatchState.unblocked(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.unblocked, productItem);

  factory ProductItemPatchState.archiving(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.archiving, productItem);
  factory ProductItemPatchState.archived(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.archived, productItem);

  factory ProductItemPatchState.changingSection(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.changingSection, productItem);
  factory ProductItemPatchState.changedSection(ProductItem productItem) =>
      ProductItemPatchState(ProductItemPatchPhase.changedSection, productItem);
}

extension ProductItemPatchStateToActionButtonState on ProductItemPatchState {
  static const stateMap = {
    ProductItemPatchPhase.blocking: MoleculeActionButtonState.loading,
    ProductItemPatchPhase.blocked: MoleculeActionButtonState.success,
    ProductItemPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ProductItemPatchPhase.unblocked: MoleculeActionButtonState.success,
    ProductItemPatchPhase.archiving: MoleculeActionButtonState.loading,
    ProductItemPatchPhase.archived: MoleculeActionButtonState.success,
    ProductItemPatchPhase.changingSection: MoleculeActionButtonState.loading,
    ProductItemPatchPhase.changedSection: MoleculeActionButtonState.success,
    ProductItemPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProductItemPatchFailed extends ProductItemPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemPatchFailed(this.error, ProductItem productItem) : super(ProductItemPatchPhase.failed, productItem);

  factory ProductItemPatchFailed.from(CoreError error, ProductItemPatchState state) =>
      ProductItemPatchFailed(error, state.productItem);
}

class ProductItemPatchNotifier extends StateNotifier<ProductItemPatchState> with LoggerMixin {
  final ProductItemRepository productItemRepository;

  ProductItemPatchNotifier({
    required this.productItemRepository,
  }) : super(ProductItemPatchState.initial());

  Future<void> reset() async => state = ProductItemPatchState.initial();

  Future<void> block(ProductItem productItem) async {
    try {
      state = ProductItemPatchState.blocking(productItem);
      bool stopped = await productItemRepository.block(productItem);
      state = stopped
          ? ProductItemPatchState.blocked(productItem)
          : ProductItemPatchFailed(errorFailedToSaveData, productItem);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemPatchFailed(errorFailedToSaveData, productItem);
    }
  }

  Future<void> unblock(ProductItem productItem) async {
    try {
      state = ProductItemPatchState.unblocking(productItem);
      bool stopped = await productItemRepository.unblock(productItem);
      state = stopped
          ? ProductItemPatchState.unblocked(productItem)
          : ProductItemPatchFailed(errorFailedToSaveData, productItem);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemPatchFailed(errorFailedToSaveData, productItem);
    }
  }

  Future<void> archive(ProductItem productItem) async {
    try {
      state = ProductItemPatchState.archiving(productItem);
      bool archived = await productItemRepository.archive(productItem);
      state = archived
          ? ProductItemPatchState.archived(productItem)
          : ProductItemPatchFailed(errorFailedToSaveData, productItem);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemPatchFailed(errorFailedToSaveData, productItem);
    }
  }

  Future<void> changeSection(ProductItem productItem) async {
    try {
      state = ProductItemPatchState.changingSection(productItem);
      bool changed = await productItemRepository.update(productItem);
      state = changed
          ? ProductItemPatchState.changedSection(productItem)
          : ProductItemPatchFailed(errorFailedToSaveData, productItem);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemPatchFailed(errorFailedToSaveData, productItem);
    }
  }
}

// eof

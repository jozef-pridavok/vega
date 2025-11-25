import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_section.dart";

enum ProductSectionPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  failed,
}

extension ProductSectionPatchPhaseBool on ProductSectionPatchPhase {
  bool get isInProgress =>
      this == ProductSectionPatchPhase.blocking ||
      this == ProductSectionPatchPhase.unblocking ||
      this == ProductSectionPatchPhase.archiving;

  bool get isSuccessful =>
      this == ProductSectionPatchPhase.blocked ||
      this == ProductSectionPatchPhase.unblocked ||
      this == ProductSectionPatchPhase.archived;
}

class ProductSectionPatchState {
  final ProductSectionPatchPhase phase;
  final ProductSection productSection;
  ProductSectionPatchState(this.phase, this.productSection);

  factory ProductSectionPatchState.initial() =>
      ProductSectionPatchState(ProductSectionPatchPhase.initial, ProductSection.empty());

  factory ProductSectionPatchState.blocking(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.blocking, productSection);
  factory ProductSectionPatchState.blocked(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.blocked, productSection);

  factory ProductSectionPatchState.unblocking(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.unblocking, productSection);
  factory ProductSectionPatchState.unblocked(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.unblocked, productSection);

  factory ProductSectionPatchState.archiving(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.archiving, productSection);
  factory ProductSectionPatchState.archived(ProductSection productSection) =>
      ProductSectionPatchState(ProductSectionPatchPhase.archived, productSection);
}

extension ProductSectionPatchStateToActionButtonState on ProductSectionPatchState {
  static const stateMap = {
    ProductSectionPatchPhase.blocking: MoleculeActionButtonState.loading,
    ProductSectionPatchPhase.blocked: MoleculeActionButtonState.success,
    ProductSectionPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ProductSectionPatchPhase.unblocked: MoleculeActionButtonState.success,
    ProductSectionPatchPhase.archiving: MoleculeActionButtonState.loading,
    ProductSectionPatchPhase.archived: MoleculeActionButtonState.success,
    ProductSectionPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProductSectionPatchFailed extends ProductSectionPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductSectionPatchFailed(this.error, ProductSection productSection)
      : super(ProductSectionPatchPhase.failed, productSection);

  factory ProductSectionPatchFailed.from(CoreError error, ProductSectionPatchState state) =>
      ProductSectionPatchFailed(error, state.productSection);
}

class ProductSectionPatchNotifier extends StateNotifier<ProductSectionPatchState> with LoggerMixin {
  final ProductSectionRepository productSectionRepository;

  ProductSectionPatchNotifier({
    required this.productSectionRepository,
  }) : super(ProductSectionPatchState.initial());

  Future<void> reset() async => state = ProductSectionPatchState.initial();

  Future<void> block(ProductSection productSection) async {
    try {
      state = ProductSectionPatchState.blocking(productSection);
      bool stopped = await productSectionRepository.block(productSection);
      state = stopped
          ? ProductSectionPatchState.blocked(productSection)
          : ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    }
  }

  Future<void> unblock(ProductSection productSection) async {
    try {
      state = ProductSectionPatchState.unblocking(productSection);
      bool stopped = await productSectionRepository.unblock(productSection);
      state = stopped
          ? ProductSectionPatchState.unblocked(productSection)
          : ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    }
  }

  Future<void> archive(ProductSection productSection) async {
    try {
      state = ProductSectionPatchState.archiving(productSection);
      bool archived = await productSectionRepository.archive(productSection);
      state = archived
          ? ProductSectionPatchState.archived(productSection)
          : ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductSectionPatchFailed(errorFailedToSaveData, productSection);
    }
  }
}

// eof

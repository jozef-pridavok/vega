import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../repositories/product_order.dart";

enum ProductOrderPatchPhase {
  initial,
  accepting,
  accepted,
  marking,
  marked,
  canceling,
  canceled,
  returning,
  returned,
  closing,
  closed,
  failed,
}

extension ProductOrderPatchPhaseBool on ProductOrderPatchPhase {
  bool get isInProgress =>
      this == ProductOrderPatchPhase.accepting ||
      this == ProductOrderPatchPhase.marking ||
      this == ProductOrderPatchPhase.canceling ||
      this == ProductOrderPatchPhase.returning ||
      this == ProductOrderPatchPhase.closing;

  bool get isSuccessful =>
      this == ProductOrderPatchPhase.accepted ||
      this == ProductOrderPatchPhase.marked ||
      this == ProductOrderPatchPhase.canceled ||
      this == ProductOrderPatchPhase.returned ||
      this == ProductOrderPatchPhase.closed;
}

class ProductOrderPatchState {
  final ProductOrderPatchPhase phase;
  final UserOrder userOrder;
  ProductOrderPatchState(this.phase, this.userOrder);

  factory ProductOrderPatchState.initial({UserOrder? userOrder}) =>
      ProductOrderPatchState(ProductOrderPatchPhase.initial, userOrder ?? DataModel.emptyUserOrder());

  factory ProductOrderPatchState.accepting(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.accepting, userOrder);
  factory ProductOrderPatchState.accepted(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.accepted, userOrder);

  factory ProductOrderPatchState.marking(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.marking, userOrder);
  factory ProductOrderPatchState.marked(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.marked, userOrder);

  factory ProductOrderPatchState.canceling(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.canceling, userOrder);
  factory ProductOrderPatchState.canceled(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.canceled, userOrder);

  factory ProductOrderPatchState.returning(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.returning, userOrder);
  factory ProductOrderPatchState.returned(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.returned, userOrder);

  factory ProductOrderPatchState.closing(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.closing, userOrder);
  factory ProductOrderPatchState.closed(UserOrder userOrder) =>
      ProductOrderPatchState(ProductOrderPatchPhase.closed, userOrder);
}

extension ProductOrderPatchStateToActionButtonState on ProductOrderPatchState {
  static const stateMap = {
    ProductOrderPatchPhase.accepting: MoleculeActionButtonState.loading,
    ProductOrderPatchPhase.accepted: MoleculeActionButtonState.success,
    ProductOrderPatchPhase.marking: MoleculeActionButtonState.loading,
    ProductOrderPatchPhase.marked: MoleculeActionButtonState.success,
    ProductOrderPatchPhase.canceling: MoleculeActionButtonState.loading,
    ProductOrderPatchPhase.canceled: MoleculeActionButtonState.success,
    ProductOrderPatchPhase.returning: MoleculeActionButtonState.loading,
    ProductOrderPatchPhase.returned: MoleculeActionButtonState.success,
    ProductOrderPatchPhase.closing: MoleculeActionButtonState.loading,
    ProductOrderPatchPhase.closed: MoleculeActionButtonState.success,
    ProductOrderPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ProductOrderPatchFailed extends ProductOrderPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOrderPatchFailed(this.error, UserOrder userOrder) : super(ProductOrderPatchPhase.failed, userOrder);

  factory ProductOrderPatchFailed.from(CoreError error, ProductOrderPatchState state) =>
      ProductOrderPatchFailed(error, state.userOrder);
}

class ProductOrderPatchNotifier extends StateNotifier<ProductOrderPatchState> with LoggerMixin {
  final ProductOrderRepository productOrderRepository;

  ProductOrderPatchNotifier({
    required this.productOrderRepository,
  }) : super(ProductOrderPatchState.initial());

  void init({required UserOrder userOrder}) => state = ProductOrderPatchState.initial(userOrder: userOrder);

  void reset({UserOrder? userOrder}) => state = ProductOrderPatchState.initial(userOrder: userOrder);

  Future<void> accept(UserOrder userOrder, {DateTime? deliveryEstimate}) async {
    try {
      state = ProductOrderPatchState.accepting(userOrder);
      bool accepted =
          await productOrderRepository.mark(userOrder, ProductOrderStatus.accepted, deliveryEstimate: deliveryEstimate);
      state = accepted
          ? ProductOrderPatchState.accepted(userOrder.copyWith(status: ProductOrderStatus.accepted))
          : ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    }
  }

  Future<void> mark(UserOrder userOrder, ProductOrderStatus newStatus) async {
    try {
      state = ProductOrderPatchState.marking(userOrder);
      bool marked = await productOrderRepository.mark(userOrder, newStatus);
      state = marked
          ? ProductOrderPatchState.marked(userOrder.copyWith(status: newStatus))
          : ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    }
  }

  Future<void> cancel(UserOrder userOrder, {String? cancelledReason}) async {
    try {
      state = ProductOrderPatchState.canceling(userOrder);
      bool cancelled =
          await productOrderRepository.mark(userOrder, ProductOrderStatus.cancelled, cancelledReason: cancelledReason);
      state = cancelled
          ? ProductOrderPatchState.canceled(userOrder.copyWith(status: ProductOrderStatus.cancelled))
          : ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    }
  }

  Future<void> returnOrder(UserOrder userOrder) async {
    try {
      state = ProductOrderPatchState.returning(userOrder);
      bool returned = await productOrderRepository.mark(userOrder, ProductOrderStatus.returned);
      state = returned
          ? ProductOrderPatchState.returned(userOrder.copyWith(status: ProductOrderStatus.returned))
          : ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    }
  }

  Future<void> closeOrder(UserOrder userOrder) async {
    try {
      state = ProductOrderPatchState.closing(userOrder);
      bool closed = await productOrderRepository.mark(userOrder, ProductOrderStatus.closed);
      state = closed
          ? ProductOrderPatchState.closed(userOrder.copyWith(status: ProductOrderStatus.closed))
          : ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOrderPatchFailed(errorFailedToSaveData, userOrder);
    }
  }
}

// eof

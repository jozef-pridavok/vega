import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_order.dart";

@immutable
abstract class ProductOrderItemsState {}

class ProductOrderItemsInitial extends ProductOrderItemsState {}

class ProductOrderItemsLoading extends ProductOrderItemsState {}

class ProductOrderItemsSucceed extends ProductOrderItemsState {
  final List<UserOrderItem> userOrderItems;
  ProductOrderItemsSucceed({required this.userOrderItems});
}

class ProductOrderItemsRefreshing extends ProductOrderItemsSucceed {
  ProductOrderItemsRefreshing({required super.userOrderItems});
}

class ProductOrderItemsFailed extends ProductOrderItemsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOrderItemsFailed(this.error);
}

class ProductOrderItemsNotifier extends StateNotifier<ProductOrderItemsState> with LoggerMixin {
  final String productOrderId;
  final ProductOrderRepository productOrderRepository;

  ProductOrderItemsNotifier(
    this.productOrderId, {
    required this.productOrderRepository,
  }) : super(ProductOrderItemsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductOrderItemsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductOrderItemsRefreshing) state = ProductOrderItemsLoading();
      final userOrderItems = await productOrderRepository.readAllItems(productOrderId);
      state = ProductOrderItemsSucceed(userOrderItems: userOrderItems);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductOrderItemsFailed(err);
    } on Exception catch (ex) {
      state = ProductOrderItemsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductOrderItemsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ProductOrderItemsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductOrderItemsRefreshing(userOrderItems: succeed.userOrderItems);
    await load(reload: true);
  }
}

// eof

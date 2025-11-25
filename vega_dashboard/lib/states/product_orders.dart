import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_order.dart";

@immutable
abstract class ProductOrdersState {}

class ProductOrdersInitial extends ProductOrdersState {}

class ProductOrdersLoading extends ProductOrdersState {}

class ProductOrdersSucceed extends ProductOrdersState {
  final List<UserOrder> userOrders;
  ProductOrdersSucceed({required this.userOrders});
}

class ProductOrdersRefreshing extends ProductOrdersSucceed {
  ProductOrdersRefreshing({required super.userOrders});
}

class ProductOrdersFailed extends ProductOrdersState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOrdersFailed(this.error);
}

class ProductOrdersNotifier extends StateNotifier<ProductOrdersState> with StateMixin {
  final ProductOrderRepositoryFilter filter;
  final ProductOrderRepository productOrderRepository;

  ProductOrdersNotifier(
    this.filter, {
    required this.productOrderRepository,
  }) : super(ProductOrdersInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ProductOrdersInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false, bool resetToSucceedState = false}) async {
    if (!reload && cast<ProductOrdersSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    if (resetToSucceedState) {
      final currentState = cast<ProductOrdersSucceed>(state)!;
      state = ProductOrdersSucceed(userOrders: currentState.userOrders);
      return;
    }
    try {
      if (state is! ProductOrdersRefreshing) state = ProductOrdersLoading();
      final userOrders = await productOrderRepository.readAll(filter: filter);
      state = ProductOrdersSucceed(userOrders: userOrders);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductOrdersFailed(err);
    } on Exception catch (ex) {
      warning(ex.toString());
      state = ProductOrdersFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductOrdersFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<ProductOrdersSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductOrdersRefreshing(userOrders: succeed.userOrders);
    await load(reload: true);
  }

  bool added(UserOrder userOrder) {
    return next(state, [ProductOrdersSucceed], () {
      final userOrders = cast<ProductOrdersSucceed>(state)!.userOrders;
      final index = userOrders.indexWhere((r) => r.orderId == userOrder.orderId);
      if (index != -1) return false;
      userOrders.insert(0, userOrder);
      state = ProductOrdersSucceed(userOrders: userOrders);
      return true;
    });
  }

  bool updated(UserOrder userOrder) {
    return next(state, [ProductOrdersSucceed], () {
      final userOrders = cast<ProductOrdersSucceed>(state)!.userOrders;
      final index = userOrders.indexWhere((r) => r.orderId == userOrder.orderId);
      if (index == -1) return false;
      userOrders.replaceRange(index, index + 1, [userOrder]);
      state = ProductOrdersSucceed(userOrders: userOrders);
      return true;
    });
  }

  bool removed(UserOrder userOrder) {
    return next(state, [ProductOrdersSucceed], () {
      final userOrders = cast<ProductOrdersSucceed>(state)!.userOrders;
      final index = userOrders.indexWhere((r) => r.orderId == userOrder.orderId);
      if (index == -1) return false;
      userOrders.removeAt(index);
      state = ProductOrdersSucceed(userOrders: userOrders);
      return true;
    });
  }
}

// eof

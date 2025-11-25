import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/order/orders.dart";

@immutable
abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersSucceed extends OrdersState {
  final List<UserOrder> orders;

  OrdersSucceed({required this.orders});
}

class OrdersRefreshing extends OrdersSucceed {
  OrdersRefreshing({required super.orders});
}

class OrdersFailed extends OrdersState implements FailedState {
  @override
  final CoreError error;
  OrdersFailed(this.error);
}

class OrdersNotifier extends StateNotifier<OrdersState> with LoggerMixin {
  final String clientId;
  final OrdersRepository ordersRepository;

  OrdersNotifier(this.clientId, {required this.ordersRepository}) : super(OrdersInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<OrdersSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! OrdersRefreshing) state = OrdersLoading();
      final orders = await ordersRepository.readAll(clientId);
      state = OrdersSucceed(orders: orders);
    } on CoreError catch (e) {
      error(e.toString());
      state = OrdersFailed(e);
    } catch (e) {
      error(e.toString());
      state = OrdersFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! OrdersSucceed) return;
    final orders = cast<OrdersSucceed>(state)!.orders;
    state = OrdersRefreshing(orders: orders);
    await _load(reload: true);
  }
}

// eof

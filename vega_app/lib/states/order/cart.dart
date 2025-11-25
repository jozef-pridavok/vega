import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/repositories/order/order.dart";

import "../../repositories/order/offers.dart";
import "../../strings.dart";

@immutable
abstract class CartState {
  final UserOrder order;

  const CartState(this.order);
}

extension CartStateToActionButtonState on CartState {
  static const stateMap = {
    CartSending: MoleculeActionButtonState.loading,
    CartSent: MoleculeActionButtonState.success,
    CartSendFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class CartOpened extends CartState {
  const CartOpened(super.order);

  TimeOfDay? getStartOfOpeningHours(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return null;
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  TimeOfDay? getEndOfOpeningHours(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return null;
    }
    return const TimeOfDay(hour: 17, minute: 0);
  }

  bool hasOpeningHours(DateTime date) {
    final start = getStartOfOpeningHours(date);
    final end = getEndOfOpeningHours(date);
    return start != null && end != null;
  }

  bool get needsDeliveryAddress =>
      order.deliveryType == DeliveryType.delivery && (order.deliveryAddressLine2?.isEmpty ?? true);

  // return lang key with error, or null if no error
  String? isNotReadyForSent() {
    if (order.items?.isEmpty ?? true) return LangKeys.toastOrderIsEmpty.tr();
    if (needsDeliveryAddress) {
      return LangKeys.toastSelectDeliveryAddress.tr();
    }
    return null;
  }
}

class CartItemOpened extends CartState {
  final ProductItem productItem;
  final UserOrderItem orderItem;

  const CartItemOpened(super.order, this.productItem, this.orderItem);

  CartItemOpened next(UserOrderItem orderItem) => CartItemOpened(order, productItem, orderItem);

  int countOption(ProductItemOption option) {
    final orderOptions = orderItem.modifications
        ?.expand((mod) => mod.options ?? [])
        .where((orderOption) => orderOption.optionId == option.optionId);
    if (orderOptions?.isNotEmpty ?? false) return orderOptions!.length;
    return 0;
  }

  Price getPrice(ProductItem productItem, List<ProductItemModification> modifications) {
    assert(orderItem.itemId == productItem.itemId);
    final price = orderItem.getPrice(productItem, modifications);
    orderItem.price = price.fraction;
    orderItem.currency = price.currency;
    return price;
  }
}

class CartCanceled extends CartState {
  const CartCanceled(super.order);
}

class CartSending extends CartState {
  const CartSending(super.order);
}

class CartSent extends CartState {
  const CartSent(super.order);
}

class CartSendFailed extends CartState implements FailedState {
  @override
  final CoreError error;
  @override
  const CartSendFailed(this.error, super.order);
}

class CartNotifier extends StateNotifier<CartState> with StateMixin {
  final DeviceRepository deviceRepository;
  final OffersRepository offersRepository;
  final OrderRepository orderRepository;

  CartNotifier({required this.deviceRepository, required this.offersRepository, required this.orderRepository})
      : super(
          CartOpened(UserOrder.createNew("", "", "", deviceRepository.get(DeviceKey.user) as User)),
        );

  bool canOpenClient(String clientId) => state.order.clientId == clientId;

  void openClient(String clientId, String offerId, String userCardId) {
    final (opened, canceled) = expectOr<CartOpened, CartCanceled>(state);
    if (opened == null && canceled == null) return;
    //if (!canOpenClient(clientId)) return;
    state = CartOpened(
      UserOrder.createNew(clientId, offerId, userCardId, deviceRepository.get(DeviceKey.user) as User),
    );
  }

  void reopen() {
    //final opened = expect<CartOpened>(state);
    //if (opened == null) return;
    state = CartOpened(state.order);
  }

  void openItem(ProductItem productItem) {
    //final opened = expect<CartOpened>(state);
    //if (opened == null) return;
    final (itemOpened, opened) = expectOr<CartItemOpened, CartOpened>(state);
    if (itemOpened == null && opened == null) return;
    final orderItem = UserOrderItem(
      itemId: productItem.itemId,
      name: productItem.name,
      price: productItem.price ?? 0,
      currency: productItem.currency,
      qty: 1,
      qtyPrecision: productItem.qtyPrecision,
      unit: productItem.unit ?? "",
      photo: productItem.photo,
      photoBh: productItem.photoBh,
    );
    state = CartItemOpened(state.order, productItem, orderItem);
  }

  void incQty() {
    final cart = expect<CartItemOpened>(state);
    if (cart == null) return;

    final orderItem = cart.orderItem;
    orderItem.qty += 1;

    state = cart.next(orderItem);
  }

  void decQty() {
    final cart = expect<CartItemOpened>(state);
    if (cart == null) return;

    final orderItem = cart.orderItem;
    orderItem.qty = orderItem.qty > 1 ? orderItem.qty - 1 : 0;

    state = orderItem.qty > 0 ? cart.next(orderItem) : CartOpened(cart.order);
  }

  void toggleSingleOption(ProductItemModification modification, ProductItemOption option) {
    final cart = expect<CartItemOpened>(state);
    if (cart == null) return;

    final orderItem = cart.orderItem;

    final modifications = orderItem.modifications ?? [];
    modifications.removeWhere((e) => e.modificationId == modification.modificationId);
    modifications.add(UserOrderModification(
      modificationId: modification.modificationId,
      name: modification.name,
      options: [option],
    ));
    orderItem.modifications = modifications;

    state = cart.next(orderItem);
  }

  void toggleMultipleOption(ProductItemModification modification, ProductItemOption option) {
    final cart = expect<CartItemOpened>(state);
    if (cart == null) return;
    final item = cart.orderItem;

    final modifications = item.modifications ?? [];
    if (modifications.expand((e) => e.options ?? []).contains(option)) {
      for (final orderModification in modifications) {
        final options = orderModification.options ?? [];
        options.removeWhere((e) => e.optionId == option.optionId);
        orderModification.options = options;
      }
    } else {
      modifications.add(UserOrderModification(
        modificationId: modification.modificationId,
        name: modification.name,
        options: [option],
      ));
    }

    modifications.removeWhere((e) => e.options?.isEmpty ?? true);
    item.modifications = modifications;

    state = cart.next(item);
  }

  void confirmItem() {
    final cart = expect<CartItemOpened>(state);
    if (cart == null) return;

    final item = cart.orderItem;
    final order = cart.order;

    final items = order.items ?? [];
    items.add(item);
    order.items = items;

    //order.totalPriceCurrency = order.items?.firstOrNull?.currency;
    //order.totalPrice = order.items?.fold(0, (prev, item) => (prev ?? 0) + item.price) ?? 0;
    order.updateTotalPrice();

    state = CartOpened(order);
  }

  void increment(UserOrderItem item) {
    final order = state.order;
    final items = order.items ?? [];
    final index = items.indexOf(item);
    if (index == -1) return;

    final orderItem = items[index];
    orderItem.qty += 1;
    items[index] = orderItem;
    order.items = items;

    order.updateTotalPrice();
    state = CartOpened(order);
  }

  void decrement(UserOrderItem item) {
    final order = state.order;
    final items = order.items ?? [];
    final index = items.indexOf(item);
    if (index == -1) return;

    final orderItem = items[index];
    orderItem.qty = orderItem.qty > 1 ? orderItem.qty - 1 : 0;
    items[index] = orderItem;

    order.items = items;

    order.updateTotalPrice();
    state = CartOpened(order);
  }

  void setDeliveryType(DeliveryType type) {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.deliveryType = type;
    state = CartOpened(order);
  }

  void setDeliveryAddress(UserAddress? address) {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.deliveryAddressId = address?.userAddressId;
    order.deliveryAddressLine1 = address?.addressLine1;
    order.deliveryAddressLine2 = address?.addressLine2;
    order.deliveryCity = address?.city;
    state = CartOpened(order);
  }

  void setDeliveryDate(DateTime date, TimeOfDay time) {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.deliveryDate = date.copyWith(
      hour: order.deliveryDate?.hour ?? time.hour,
      minute: order.deliveryDate?.minute ?? time.minute,
    );
    state = CartOpened(order);
  }

  void setDeliveryTime(TimeOfDay time) {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.deliveryDate = (order.deliveryDate ?? DateTime.now()).copyWith(
      hour: time.hour,
      minute: time.minute,
    );
    state = CartOpened(order);
  }

  void setDeliveryAsap() {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.deliveryDate = null;
    state = CartOpened(order);
  }

  void setNotes(String notes) {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;
    order.notes = notes;
    state = CartOpened(order);
  }

  //void cancelOrder() => state = CartOpened(
  //      UserOrder.createNew("", "", "", deviceRepository.get(DeviceKey.user) as User),
  //    );

  void cancelOrder() =>
      state = CartCanceled(UserOrder.createNew("", "", "", deviceRepository.get(DeviceKey.user) as User));

  Future<void> sendOrder() async {
    final order = expect<CartOpened>(state)?.order;
    if (order == null) return;

    state = CartSending(order);

    try {
      final success = await orderRepository.create(order);
      state = success ? CartSent(order) : CartSendFailed(errorCancelled, order);
    } on CoreError catch (err) {
      state = CartSendFailed(err, order);
    } catch (ex) {
      error(ex.toString());
      state = CartSendFailed(errorUnexpectedException(ex), order);
    }
  }
}

// eof

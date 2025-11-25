import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/card/screen_order_detail.dart";
import "package:vega_app/states/providers.dart";

import "../../states/order/orders.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_offer.dart";
import "screen_offers.dart";

class OrdersScreen extends AppScreen {
  final UserCard userCard;
  const OrdersScreen(this.userCard, {super.key});

  @override
  createState() => _OrdersState();
}

class _OrdersState extends AppScreenState<OrdersScreen> {
  UserCard get _userCard => widget.userCard;
  String get _clientId => _userCard.clientId!;

  @override
  bool onPushNotification(PushNotification message) {
    /*
    final clientId = _userCard.clientId;
    if (clientId == null) return false;
    final action = message.actionType;
    final reservationChanged = action == ActionType.reservationAccepted || action == ActionType.reservationClosed;
    if (reservationChanged && message["clientId"] == clientId) {
      hapticHeavy();
      ref.read(ordersLogic(_clientId).notifier).refresh();
      return true;
    }
    */
    return super.onPushNotification(message);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenTitleOrders.tr(),
        actions: [
          IconButton(
            icon: const VegaIcon(name: AtomIcons.add),
            onPressed: () {
              context.slideUp(OffersScreen(
                _clientId,
                cancel: true,
                onOffer: (offer) {
                  ref.read(cartLogic.notifier).openClient(_clientId, offer.offerId, _userCard.userCardId);
                  context.pop();
                  //context.push(EditOrderScreen(userCard: widget.userCard, offerId: offer.offerId));
                  context.slideUp(OfferScreen(_userCard, offer));
                },
              ));
            },
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersLogic(_clientId).notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(ordersLogic(_clientId));
    if (state is OrdersSucceed) {
      if (state.orders.isNotEmpty) return _Orders(_clientId);
      return MoleculeErrorWidget(
        icon: AtomIcons.shoppingCard,
        iconColor: ref.scheme.content20,
        // translate to slovak, english, spanish
        // TODO localize: screen_reservation_no_orders "Nemáte žiadnu objednávku", "You have no orders", "No tenes pedidos"
        message: "screen_reservation_no_orders".tr(),
      );
    } else if (state is OrdersFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          ordersLogic(_clientId),
          onReload: () => ref.read(ordersLogic(_clientId).notifier).reload(),
        ),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _Orders extends ConsumerWidget {
  final String clientId;

  const _Orders(this.clientId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(ordersLogic(clientId)) as OrdersSucceed;
    final orders = succeed.orders;
    //final reservations = succeed.reservations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(ordersLogic(clientId).notifier).refresh(),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildRow(context, ref, orders[index]),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, UserOrder order) {
    final lang = context.languageCode;
    final price = order.totalPrice;
    final currency = order.totalPriceCurrency;

    String title = order.status.localizedName;
    if (price != null && currency != null) title = "${currency.formatSymbol(price, lang)} - $title";

    String date = formatDatePretty(lang, order.createdAt) ?? "";
    final address = formatAddress(order.deliveryAddressLine1, order.deliveryAddressLine2, order.deliveryCity);
    final label = "$date${address != null ? " - $address" : ""}";

    return MoleculeItemBasic(
      title: title,
      label: label,
      icon: AtomIcons.shoppingCard,
      actionIcon: AtomIcons.itemDetail,
      onAction: () => context.push(OrderDetailScreen(order)),
    );
  }
}

// eof

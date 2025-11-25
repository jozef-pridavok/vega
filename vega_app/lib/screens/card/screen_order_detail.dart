import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../caches.dart";
import "../../states/order/orders.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../screen_app.dart";

class OrderDetailScreen extends AppScreen {
  final UserOrder order;
  const OrderDetailScreen(this.order, {super.key});

  @override
  createState() => _OrderState();
}

class _OrderState extends AppScreenState<OrderDetailScreen> {
  UserOrder get _order => _updatedOrder ?? widget.order;
  List<UserOrderItem>? get _orderItems => _order.items;
  UserOrder? _updatedOrder;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        // TODO: localize: screen_order_detail "Detail objednávky", "Detalle del pedido", "Detalle del pedido"
        title: "screen_order_detail".tr(),
        /*actions: [
          IconButton(
            icon: const VegaIcon(name: AtomIcons.add),
            onPressed: () {
              toastWarning("TODO");
            },
          ),
        ],*/
      );

  @override
  void initState() {
    super.initState();
    //Future.microtask(() => ref.read(ordersLogic(_clientId).notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToOrdersLogic(context);
    return PullToRefresh(
      onRefresh: () {
        return ref.read(ordersLogic(_order.clientId).notifier).refresh();
      },
      child: SingleChildScrollView(
        //physics: vegaScrollPhysic,
        child: Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOverview(context),
              const MoleculeItemSpace(),
              _order.status.localizedName.h3.alignCenter,
              const MoleculeItemSpace(),
              if (_orderItems != null)
                ..._orderItems!.map(
                  (item) => Column(
                    children: [
                      _buildItem(context, item),
                      const MoleculeItemSpace(),
                    ],
                  ),
                ),
              const MoleculeItemSpace(),
            ],
          ),
        ),
      ),
    );
  }

  void _listenToOrdersLogic(BuildContext context) {
    ref.listen<OrdersState>(ordersLogic(_order.clientId), (previous, next) {
      if (next is OrdersSucceed) {
        final order = next.orders.firstWhereOrNull((o) => o.orderId == _order.orderId);
        if (order != null) {
          setState(() => _updatedOrder = order);
        }
      }
    });
  }

  Widget _buildItem(BuildContext context, UserOrderItem item) {
    final lang = context.languageCode;
    final photo = item.photo;
    final photoBh = item.photoBh;
    return MoleculeItemProgram(
      title: "${Quantity(item.qty, precision: item.qtyPrecision).format(lang)}x ${item.name}",
      label: kDebugMode
          ? "mods=${item.modifications?.length ?? 0} ${item.currency.formatSymbol(item.price, lang)}"
          : item.currency.formatSymbol(item.price, lang),
      image: photo != null ? CachedImage(config: Caches.productPhoto, url: photo, blurHash: photoBh) : null,
    );
  }

  Widget _buildOverview(BuildContext context) {
    final lang = context.languageCode;
    final price = _order.totalPrice;
    final currency = _order.totalPriceCurrency;

    String formattedPrice = _order.status.localizedName;
    if (price != null && currency != null) formattedPrice = currency.formatSymbol(price, lang);
    String date = formatDatePretty(lang, _order.createdAt) ?? "";
    final address = formatAddress(_order.deliveryAddressLine1, _order.deliveryAddressLine2, _order.deliveryCity);
    final label = "$date${address != null ? "\n$address" : ""}";

    final items = LangKeys.labelUserOrderItems.plural(_order.items?.length ?? 0);

    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paper),
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoleculeItemTitle(header: formattedPrice, action: items),
          const SizedBox(height: 16),
          const MoleculeItemSeparator(),
          const SizedBox(height: 16),
          label.label.color(ref.scheme.content).maxLine(2).overflowEllipsis,
        ],
      ),
    );
  }
}

// eof

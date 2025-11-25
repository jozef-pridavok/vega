import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../states/product_orders.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "screen_orders_dashboard.dart";
import "widget_active_orders.dart";
import "widget_closed_orders.dart";

class ProductOrdersScreen extends VegaScreen {
  const ProductOrdersScreen({super.showDrawer, super.key});

  @override
  createState() => _ProductOrdersState();
}

class _ProductOrdersState extends VegaScreenState<ProductOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductOrdersTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeOrders = ref.watch(activeProductOrdersLogic);
    final closedOrders = ref.watch(closedProductOrdersLogic);
    final isRefreshing = [activeOrders, closedOrders].any((state) => state is ProductOrdersRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.sidebar),
        onPressed: () => context.replace(const ProductOrdersDashboardScreen(showDrawer: true)),
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeProductOrdersLogic.notifier).refresh();
          ref.read(closedProductOrdersLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabFinished.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: const [
                ActiveProductOrdersWidget(),
                ClosedProductOrdersWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof

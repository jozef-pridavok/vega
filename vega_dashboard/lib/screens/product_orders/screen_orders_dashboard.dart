import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/product_order_patch.dart";
import "../../states/product_orders.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "screen_orders_list.dart";
import "widget_dashboard_order.dart";

class ProductOrdersDashboardScreen extends VegaScreen {
  const ProductOrdersDashboardScreen({super.showDrawer, super.key});

  @override
  createState() => _ProductOrdersDashboardState();
}

class _ProductOrdersDashboardState extends VegaScreenState<ProductOrdersDashboardScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeProductOrdersLogic.notifier).load());
  }

  @override
  String? getTitle() => LangKeys.screenProductOrdersTitle.tr();

  @override
  List<Widget>? buildAppBarActions() => [
        IconButton(
          icon: const VegaIcon(name: AtomIcons.menu),
          onPressed: () => context.replace(const ProductOrdersScreen(showDrawer: true)),
        ),
        IconButton(
          icon: const VegaIcon(name: AtomIcons.refresh),
          onPressed: () => ref.read(activeProductOrdersLogic.notifier).refresh(),
        ),
        const SizedBox(width: moleculeScreenPadding),
      ];

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(activeProductOrdersLogic);
    if (state is ProductOrdersSucceed)
      return Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: _buildColumns(context, ref, state.userOrders),
      );
    else if (state is ProductOrdersFailed)
      return StateErrorWidget(
        activeProductOrdersLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(activeProductOrdersLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ProductOrderPatchState>(productOrderPatchLogic, (previous, next) {
      bool closeDialog = next is ProductOrderPatchFailed;
      if ([ProductOrderPatchPhase.accepted, ProductOrderPatchPhase.marked].contains(next.phase)) {
        closeDialog = ref.read(activeProductOrdersLogic.notifier).updated(next.userOrder);
      }
      if ([
        ProductOrderPatchPhase.canceled,
        ProductOrderPatchPhase.returned,
        ProductOrderPatchPhase.closed,
      ].contains(next.phase)) {
        ref.read(activeProductOrdersLogic.notifier).removed(next.userOrder);
        ref.read(closedProductOrdersLogic.notifier).added(next.userOrder);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ProductOrderPatchFailed) toastCoreError(next.error);
    });
  }

  Widget _buildColumns(BuildContext context, WidgetRef ref, List<UserOrder> userOrders) {
    final newOrders = userOrders.where((order) => order.status == ProductOrderStatus.created).toList();
    final acceptedOrders = userOrders
        .where((order) => [ProductOrderStatus.accepted, ProductOrderStatus.inProgress].contains(order.status))
        .toList();
    final readyOrders = userOrders
        .where((order) => [ProductOrderStatus.ready, ProductOrderStatus.dispatched, ProductOrderStatus.delivered]
            .contains(order.status))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Row(
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: moleculeScreenPadding),
              child: _buildOrderColumn(ref, title: LangKeys.columnNewOrders.tr(), orders: newOrders),
            ),
            flex: 2,
          ),
          const MoleculeItemSpace(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: moleculeScreenPadding),
              child: _buildOrderColumn(ref, title: LangKeys.columnAcceptedOrders.tr(), orders: acceptedOrders),
            ),
            flex: 2,
          ),
          const MoleculeItemSpace(),
          Flexible(
            child: _buildOrderColumn(ref, title: LangKeys.columnReadyOrders.tr(), orders: readyOrders),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderColumn(WidgetRef ref, {required String title, required List<UserOrder> orders}) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "$title (${orders.length})".h4,
          const MoleculeItemSpace(),
          Expanded(
            child: ListView(
              children: orders.map((order) => DashboardOrderWidget(order: order)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// eof

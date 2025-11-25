import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/product_order_patch.dart";
import "../../states/product_orders.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class ActiveProductOrdersWidget extends ConsumerStatefulWidget {
  const ActiveProductOrdersWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ActiveProductOrdersWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeProductOrdersLogic.notifier).load());
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
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeProductOrdersLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeProductOrdersLogic.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(activeProductOrdersLogic);
    if (state is ProductOrdersSucceed)
      return const _GridWidget();
    else if (state is ProductOrdersFailed)
      return StateErrorWidget(
        activeProductOrdersLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(activeProductOrdersLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnDate = "date";
  static const _columnStatus = "status";
  static const _columnPrice = "price";
  static const _columnFirstItem = "firstItem";
  static const _columnCustomerName = "customerName";
  static const _columnCustomerAddress = "customerAddress";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.read(activeProductOrdersLogic) as ProductOrdersSucceed;
    final userOrders = succeed.userOrders;
    return PullToRefresh(
      onRefresh: () => ref.read(activeProductOrdersLogic.notifier).refresh(),
      child: DataGrid<UserOrder>(
        rows: userOrders,
        columns: [
          DataGridColumn(name: _columnDate, label: LangKeys.columnDate.tr()),
          DataGridColumn(name: _columnStatus, label: LangKeys.columnStatus.tr()),
          DataGridColumn(name: _columnPrice, label: LangKeys.columnPrice.tr()),
          DataGridColumn(name: _columnFirstItem, label: LangKeys.columnFirstItem.tr()),
          DataGridColumn(name: _columnCustomerName, label: LangKeys.columnClient.tr()),
          DataGridColumn(name: _columnCustomerAddress, label: LangKeys.columnAddress.tr()),
        ],
        onBuildCell: (column, userOrder) => _buildCell(context, ref, column, userOrder),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, UserOrder userOrder) {
    final lang = context.languageCode;
    final columnMap = <String, ThemedText>{
      _columnDate: formatDateTimePretty(lang, userOrder.createdAt).text.color(ref.scheme.content),
      _columnStatus: userOrder.status.localizedName.text.color(ref.scheme.content),
      _columnPrice: (userOrder.totalPrice != null && userOrder.totalPriceCurrency != null
              ? userOrder.totalPriceCurrency!.formatSymbol(userOrder.totalPrice!)
              : "")
          .text
          .color(ref.scheme.content),
      //! _columnFirstItem: userOrder.orderItems?.first.name.text.color(ref.scheme.content),
      _columnCustomerName: userOrder.userNickname.text.color(ref.scheme.content),
      _columnCustomerAddress: userOrder.deliveryAddressId.text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  void _popupOperations(BuildContext context, WidgetRef ref, UserOrder userOrder, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: "",
        items: [
          ProductOrderMenuItems.viewOrder(context, ref, userOrder),
          ProductOrderMenuItems.sendMessageToUser(context, ref, userOrder),
          if (userOrder.status == ProductOrderStatus.created) ...{
            ProductOrderMenuItems.acceptOrder(context, ref, userOrder),
            ProductOrderMenuItems.cancelOrder(context, ref, userOrder),
          },
          if (userOrder.status == ProductOrderStatus.accepted) ...{
            ProductOrderMenuItems.markAsInProgress(context, ref, userOrder),
            ProductOrderMenuItems.markAsReady(context, ref, userOrder),
            ProductOrderMenuItems.cancelOrder(context, ref, userOrder),
          },
          if (userOrder.status == ProductOrderStatus.inProgress) ...{
            ProductOrderMenuItems.markAsReady(context, ref, userOrder),
            ProductOrderMenuItems.cancelOrder(context, ref, userOrder),
          },
          if (userOrder.status == ProductOrderStatus.ready) ...{
            ProductOrderMenuItems.markAsDispatched(context, ref, userOrder),
            ProductOrderMenuItems.cancelOrder(context, ref, userOrder),
          },
          if (userOrder.status == ProductOrderStatus.dispatched) ...{
            ProductOrderMenuItems.markAsDelivered(context, ref, userOrder),
            ProductOrderMenuItems.markAsReturned(context, ref, userOrder),
          },
          if (userOrder.status == ProductOrderStatus.delivered) ...{
            ProductOrderMenuItems.closeOrder(context, ref, userOrder),
          },
        ],
      );
}

// eof

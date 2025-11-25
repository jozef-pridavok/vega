import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/product_orders.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class ClosedProductOrdersWidget extends ConsumerStatefulWidget {
  const ClosedProductOrdersWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ClosedProductOrdersWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(closedProductOrdersLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(closedProductOrdersLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(closedProductOrdersLogic.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(closedProductOrdersLogic);
    if (state is ProductOrdersSucceed)
      return const _GridWidget();
    else if (state is ProductOrdersFailed)
      return StateErrorWidget(
        closedProductOrdersLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(closedProductOrdersLogic.notifier).refresh(),
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
    final succeed = ref.read(closedProductOrdersLogic) as ProductOrdersSucceed;
    final userOrders = succeed.userOrders;
    return PullToRefresh(
      onRefresh: () => ref.read(closedProductOrdersLogic.notifier).refresh(),
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
      _columnFirstItem: (userOrder.items?.first.name ?? "").text.color(ref.scheme.content),
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
        ],
      );
}

// eof

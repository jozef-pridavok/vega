import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../product_orders/screen_orders_list.dart";

class OrdersRow extends ConsumerStatefulWidget {
  const OrdersRow({super.key});

  @override
  createState() => _OrdersRowState();
}

class _OrdersRowState extends ConsumerState<OrdersRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: "shopping_cart",
      title: LangKeys.menuClientOrders.tr(),
      label: LangKeys.menuClientOrdersDescription.tr(),
      onAction: () => context.replace(const ProductOrdersScreen(showDrawer: true)),
    );
  }
}

// eof

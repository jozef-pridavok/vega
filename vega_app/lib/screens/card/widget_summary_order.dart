import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";

class OrderSummaryWidget extends ConsumerWidget {
  final UserOrder order;

  const OrderSummaryWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = order.totalPriceCurrency;
    final price = order.totalPrice;
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paper),
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoleculeItemTitle(header: LangKeys.titleOrderSummary.tr()),
          const SizedBox(height: 16),
          const MoleculeItemSeparator(),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.screenReservationLocation.tr(),
            value: formatAddress(order.deliveryAddressLine1, order.deliveryAddressLine2, order.deliveryCity),
          ),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.labelDeliveryDate.tr(),
            value: formatDate(context.languageCode, order.deliveryDate),
          ),
          /*
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.orderItemCount.tr(),
            value: formatTime(context.languageCode, order.reservationDateFrom),
          ),
          */
          if (currency != null && price != null) ...[
            const SizedBox(height: 16),
            MoleculeTableRow(
              label: LangKeys.labelPrice.tr(),
              value: currency.formatCode(price, context.languageCode),
            ),
          ],
        ],
      ),
    );
  }
}

// eof

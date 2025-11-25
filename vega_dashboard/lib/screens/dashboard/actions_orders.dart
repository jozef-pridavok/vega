import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/states/product_orders.dart";

import "../../states/dashboard.dart";
import "../../states/product_offers.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../product_offers/screen_product_offers.dart";
import "../product_orders/screen_orders_dashboard.dart";
import "action.dart";

extension DashboardActions on DashboardSucceed {
  List<DashboardAction> getActionsForOrders(BuildContext context, WidgetRef ref) {
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    if (!client.licenseModuleOrders) return [];

    final lang = context.languageCode;
    List<DashboardAction> actions = [];

    final offersStatus = ref.watch(activeProductOffersLogic);
    final offers = cast<ProductOffersSucceed>(offersStatus);

    if (offers?.productOffers.isEmpty ?? true) {
      actions.add(
        DashboardAction(
          type: DashboardActionType.orders,
          title: LangKeys.menuClientOffers.tr(),
          // translate to slovak, english, spanish
          label: LangKeys.labelNoOffers.tr(),
          icon: AtomIcons.offer,
          actions: [
            MoleculeAction.secondary(
              title: LangKeys.operationCreateOffer.tr(),
              onTap: () => context.push(const ProductOffersScreen()),
            ),
          ],
        ),
      );
    } else {
      final orders = cast<ProductOrdersSucceed>(activeProductOrdersLogic);
      if (orders?.userOrders.isNotEmpty ?? false) {
        final action = DashboardAction(
          type: DashboardActionType.orders,
          title: LangKeys.menuClientOrders.tr(),
          icon: AtomIcons.offer,
          label: LangKeys.menuClientOrdersDescription.tr(),
          actions: [
            MoleculeAction.secondary(
              title: LangKeys.buttonView.tr(),
              onTap: () => context.push(const ProductOrdersDashboardScreen()),
            ),
          ],
        );
        actions.add(action);
      }
    }

    //
    final max = 3;

    final List<OrderForDashboard> ordersForAcceptance = dashboard.ordersForAcceptance.take(max).toList();

    if (ordersForAcceptance.isNotEmpty) {
      for (final order in ordersForAcceptance) {
        final totalCurrency = order.totalPriceCurrency;
        final totalPrice = order.totalPrice;
        final formattedTotalPrice =
            (totalCurrency != null && totalPrice != null) ? totalCurrency.formatSymbol(totalPrice) : null;
        final deliveryDate = formatDateTimePretty(lang, order.deliveryDate);
        final formattedAddress =
            formatAddress(order.deliveryAddressLine1, order.deliveryAddressLine2, order.deliveryAddressCity);
        final title =
            "${order.orderStatus.localizedName} ${formatDateTimePretty(lang, order.createdAt)}${formattedTotalPrice != null ? " - $formattedTotalPrice" : ""}${order.userName != null ? ", ${order.userName}" : ""}";
        var label = deliveryDate ?? "";
        if (deliveryDate != null && formattedAddress != null) {
          label += " - $formattedAddress";
        } else if (formattedAddress != null) {
          label = formattedAddress;
        }
        label += label.isEmpty ? order.deliveryType.localizedName : " - ${order.deliveryType.localizedName}";
        final action = DashboardAction(
          type: DashboardActionType.orders,
          title: title,
          icon: AtomIcons.offer,
          label: label,
          actions: [
            MoleculeAction.positive(
              title: LangKeys.buttonConfirm.tr(),
              onTap: () {
                ref.read(toastLogic.notifier).warning("TODO");
                //showWaitDialog(context, ref, LangKeys.toastConfirmingBooking.tr());
                //ref.read(reservationForDashboardLogic.notifier).confirm(order);
                context.push(const ProductOrdersDashboardScreen());
              },
            ),
            MoleculeAction.negative(
              title: LangKeys.buttonCancel.tr(),
              onTap: () {
                ref.read(toastLogic.notifier).warning("TODO");
                //showWaitDialog(context, ref, LangKeys.toastCancelingBooking.tr());
                //ref.read(reservationForDashboardLogic.notifier).cancel(order);
                context.push(const ProductOrdersDashboardScreen());
              },
            ),
          ],
        );
        actions.add(action);
      }
    }

    if (dashboard.ordersForAcceptance.length > max) {
      int restLength = dashboard.ordersForAcceptance.length - max;
      actions.add(
        DashboardAction(
          type: DashboardActionType.orders,
          layout: DashboardActionLayout.info,
          title: "label_unconfirmed_orders_count".tr(args: [restLength.toString()]),
          icon: AtomIcons.plusCircle,
        ),
      );
    }

    //

    final List<OrderForDashboard> ordersForFinalization = dashboard.ordersForFinalization.take(max).toList();

    if (ordersForFinalization.isNotEmpty) {
      for (final order in ordersForFinalization) {
        final totalCurrency = order.totalPriceCurrency;
        final totalPrice = order.totalPrice;
        final formattedTotalPrice =
            (totalCurrency != null && totalPrice != null) ? totalCurrency.formatSymbol(totalPrice) : null;
        final deliveryDate = formatDateTimePretty(lang, order.deliveryDate);
        final formattedAddress =
            formatAddress(order.deliveryAddressLine1, order.deliveryAddressLine2, order.deliveryAddressCity);
        final title =
            "${order.orderStatus.localizedName} ${formatDateTimePretty(lang, order.createdAt)}${formattedTotalPrice != null ? " - $formattedTotalPrice" : ""}${order.userName != null ? ", ${order.userName}" : ""}";
        var label = deliveryDate ?? "";
        if (deliveryDate != null && formattedAddress != null) {
          label += " - $formattedAddress";
        } else if (formattedAddress != null) {
          label = formattedAddress;
        }
        final action = DashboardAction(
          type: DashboardActionType.orders,
          title: title,
          icon: AtomIcons.offer,
          label: label,
          actions: [
            MoleculeAction.positive(
              title: LangKeys.buttonCompleteBooking.tr(),
              onTap: () {
                ref.read(toastLogic.notifier).warning("TODO");
                //showWaitDialog(context, ref, LangKeys.toastCompletingBooking.tr());
                //ref.read(reservationForDashboardLogic.notifier).complete(order);
                context.push(const ProductOrdersDashboardScreen());
              },
            ),
            MoleculeAction.negative(
              title: LangKeys.buttonForfeitBooking.tr(),
              onTap: () {
                ref.read(toastLogic.notifier).warning("TODO");
                //showWaitDialog(context, ref, LangKeys.toastForfeitingBooking.tr());
                //ref.read(reservationForDashboardLogic.notifier).forfeit(order);
                context.push(const ProductOrdersDashboardScreen());
              },
            ),
          ],
        );
        actions.add(action);
      }
    }

    if (dashboard.ordersForFinalization.length > max) {
      int restLength = dashboard.ordersForFinalization.length - max;
      actions.add(
        DashboardAction(
          type: DashboardActionType.orders,
          layout: DashboardActionLayout.info,
          title: LangKeys.labelUnfinishedOrdersCount.tr(args: [restLength.toString()]),
          icon: AtomIcons.plusCircle,
        ),
      );
    }

    return actions;
  }
}

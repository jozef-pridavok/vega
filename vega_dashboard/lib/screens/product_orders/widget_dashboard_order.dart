import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_cards/screen_send_message.dart";
import "../dialog.dart";
import "popup_menu_items.dart";
import "screen_order_view.dart";
import "widget_accept_order.dart";
import "widget_cancel_order.dart";

class DashboardOrderWidget extends ConsumerWidget {
  final UserOrder order;
  const DashboardOrderWidget({required this.order, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.only(bottom: moleculeScreenPadding, left: 4, top: 4, right: 4),
      //child: isMobile ? _mobileLayout(context, ref) : _defaultLayout(context, ref),
      child: _defaultLayout(context, ref),
    );
  }

  Widget _defaultLayout(BuildContext context, WidgetRef ref) {
    final lang = context.languageCode;
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paper),
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MoleculeChip(
                    label: order.userNickname, style: AtomStyles.textBold, backgroundColor: ref.scheme.paperBold),
                const SizedBox(width: 8),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const VegaIcon(name: AtomIcons.send, size: 16),
                  onPressed: () => context.push(SendMessageScreen(order.userId, order.userNickname)),
                ),
                //
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const VegaIcon(name: AtomIcons.phone, size: 16),
                  onPressed: () => context.push(SendMessageScreen(order.userId, order.userNickname)),
                ),
                const Spacer(),
                const SizedBox(width: 8),
                formatDateTimePretty(lang, order.createdAt).micro,
              ],
            ),
            const SizedBox(height: 8),
            ..._buildOrderBody(context, ref, order),
            const SizedBox(height: 8),
            ..._buildActionButtons(context, ref, order),
          ],
        ),
      ),
    );
  }

  static const _newOrderStatuses = [ProductOrderStatus.created];
  static const _acceptedOrderStatuses = [ProductOrderStatus.accepted, ProductOrderStatus.inProgress];
  static const _readyOrderStatuses = [
    ProductOrderStatus.ready,
    ProductOrderStatus.dispatched,
    ProductOrderStatus.delivered
  ];

  List<Widget> _buildOrderBody(BuildContext context, WidgetRef ref, UserOrder order) {
    final currency = order.totalPriceCurrency;
    final locale = context.locale.languageCode;
    final orderPrice =
        (currency != null && order.totalPrice != null) ? currency.formatSymbol(order.totalPrice!, locale) : "";
    final address = formatAddress(
      order.deliveryAddressLine1,
      order.deliveryAddressLine2,
      order.deliveryCity,
      singleLine: true,
    );
    final isNewOrder = _newOrderStatuses.contains(order.status);
    final isAcceptedOrder = _acceptedOrderStatuses.contains(order.status);
    final isReadyOrder = _readyOrderStatuses.contains(order.status);
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (address != null)
            MoleculeChip(
              label: address,
              backgroundColor: order.deliveryType == DeliveryType.delivery &&
                      ![ProductOrderStatus.delivered, ProductOrderStatus.dispatched].contains(order.status)
                  ? ref.scheme.accent
                  : null,
              icon: order.deliveryType == DeliveryType.delivery ? AtomIcons.home : AtomIcons.package,
            ),
          if (order.deliveryDate != null)
            MoleculeChip(
              label: formatDateTimePretty(locale, order.deliveryDate!)!,
              icon: AtomIcons.reservation,
            ),
          if (F().isDev) MoleculeChip(label: order.status.localizedName),
        ],
      ),
      const SizedBox(height: 8),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        textColor: ref.scheme.content,
        iconColor: ref.scheme.primary,
        collapsedIconColor: ref.scheme.primary,
        trailing: VegaIcon(name: !isReadyOrder ? AtomIcons.chevronUp : AtomIcons.chevronDown),
        dense: true,
        title: LangKeys.productItemsCount.plural(order.items?.length ?? 0).label,
        shape: Border(),
        children: buildOrderItems(context, ref, order),
        initiallyExpanded: !isReadyOrder,
      ),
      //--
      Container(height: 1, color: ref.scheme.content50),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: LangKeys.labelTotalPrice.tr().label), orderPrice.label]),
      if (order.notes?.isNotEmpty ?? false) ...[
        const SizedBox(height: 8),
        order.notes.micro,
      ],
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildActionButtons(BuildContext context, WidgetRef ref, UserOrder userOrder) {
    if (userOrder.status == ProductOrderStatus.created) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            Expanded(child: _buildCancelButton(context, ref, userOrder), flex: 1),
            Expanded(child: _buildAcceptButton(context, ref, userOrder), flex: 2),
          ],
        ),
      ];
    } else if (userOrder.status == ProductOrderStatus.accepted) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            Expanded(child: _buildCancelButton(context, ref, userOrder), flex: 1),
            Expanded(child: _buildReadyButton(context, ref, userOrder), flex: 2),
            Expanded(child: _buildInProgressButton(context, ref, userOrder), flex: 2),
          ],
        ),
      ];
    } else if (userOrder.status == ProductOrderStatus.inProgress) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            Expanded(child: _buildCancelButton(context, ref, userOrder), flex: 1),
            Expanded(child: _buildReadyButton(context, ref, userOrder), flex: 2),
          ],
        ),
      ];
    } else if (userOrder.status == ProductOrderStatus.ready) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _buildCancelButton(context, ref, userOrder),
            _buildDispatchButton(context, ref, userOrder),
          ],
        ),
      ];
    } else if (userOrder.status == ProductOrderStatus.dispatched) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _buildReturnedButton(context, ref, userOrder),
            _buildDeliveredButton(context, ref, userOrder),
          ],
        ),
      ];
    } else if (userOrder.status == ProductOrderStatus.delivered) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _buildCloseButton(context, ref, userOrder),
          ],
        ),
      ];
    } else {
      return [];
    }
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonCancel.tr(),
        type: MoleculeActionType.negative,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: LangKeys.labelCancelOrder.tr().text,
              content: CancelOrderWidget(userOrder: userOrder),
            ),
          );
        },
      );

  Widget _buildAcceptButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonAccept.tr(),
        type: MoleculeActionType.positive,
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: LangKeys.labelAcceptOrder.tr().text,
            content: AcceptOrderWidget(userOrder: userOrder),
          ),
        ),
      );

  Widget _buildInProgressButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonInProgress.tr(),
        type: MoleculeActionType.positive,
        onTap: () {
          showWaitDialog(context, ref, "toast_marking_order_in_progress".tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.inProgress);
        },
      );

  Widget _buildReadyButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonReady.tr(),
        type: MoleculeActionType.primary,
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderReady.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.ready);
        },
      );

  Widget _buildDispatchButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonDispatch.tr(),
        type: MoleculeActionType.primary,
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDispatched.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.dispatched);
        },
      );

  Widget _buildReturnedButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonReturned.tr(),
        type: MoleculeActionType.negative,
        onTap: () => Future.delayed(
            fastRefreshDuration, () => ProductOrderMenuItems.askToMarkAsReturned(context, ref, userOrder)),
      );

  Widget _buildDeliveredButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonDelivered.tr(),
        type: MoleculeActionType.primary,
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDelivered.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.delivered);
        },
      );

  Widget _buildCloseButton(BuildContext context, WidgetRef ref, UserOrder userOrder) => MoleculeActionChip(
        label: LangKeys.buttonClose.tr(),
        type: MoleculeActionType.primary,
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastClosingOrder.tr());
          ref.read(productOrderPatchLogic.notifier).closeOrder(userOrder);
        },
      );
}

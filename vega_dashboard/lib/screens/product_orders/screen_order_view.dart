import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/product_order_patch.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../client_user_cards/screen_send_message.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class ViewProductOrder extends VegaScreen {
  const ViewProductOrder({super.key});

  @override
  createState() => _ViewState();
}

class _ViewState extends VegaScreenState<ViewProductOrder> {
  final notificationsTag = "6332cf17-4fa8-4af5-8246-32838fc87e31";
  final unsavedWarningText = LangKeys.notificationUnsavedData.tr();

  final _userNickController = TextEditingController();
  final _dateController = TextEditingController();
  final _priceController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final lang = context.languageCode;

      final userOrder = ref.read(productOrderPatchLogic).userOrder;

      _userNickController.text = userOrder.userNickname;
      _dateController.text = formatDateTimePretty(lang, userOrder.createdAt) ?? "";
      _address1Controller.text = userOrder.deliveryAddressLine1 ?? "";
      _address2Controller.text = userOrder.deliveryAddressLine2 ?? "";
      _cityController.text = userOrder.deliveryCity ?? "";
      _notesController.text = userOrder.notes ?? "";

      final currency = userOrder.totalPriceCurrency;
      final price = userOrder.totalPrice;
      final locale = context.locale.languageCode;
      _priceController.text = (currency != null && price != null) ? currency.format(price, locale) : "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userNickController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _notesController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductOrderViewTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final userOrder = ref.read(productOrderPatchLogic).userOrder;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: IconButton(
          icon: const VegaIcon(name: AtomIcons.send),
          onPressed: () {
            context.push(SendMessageScreen(userOrder.userId, userOrder.userNickname));
          },
        ),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    final userOrder = ref.watch(productOrderPatchLogic).userOrder;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: isMobile ? _mobileLayout(userOrder) : _defaultLayout(userOrder),
      ),
    );
  }

  void refresh() => setState(() {});

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

  // TODO: Mobile layout
  Widget _mobileLayout(UserOrder userOrder) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildUserNick()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildOrderDate()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildAddressLine1(), flex: 2),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCity(), flex: 1),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildAddressLine2(), flex: 1),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: Container(), flex: 2),
            ],
          ),
          const MoleculeItemSpace(),
          Row(children: [Expanded(child: _buildNotes())]),
          const MoleculeItemSpace(),
          _buildOrderTitle(userOrder),
          const MoleculeItemSpace(),
          ...buildOrderItems(context, ref, userOrder),
          const MoleculeItemSpace(),
          Row(
            children: _buildActionButtons(userOrder),
          ),
        ],
      );

  Widget _defaultLayout(UserOrder userOrder) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildUserNick()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildOrderDate()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildAddressLine1(), flex: 2),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCity(), flex: 1),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildAddressLine2(), flex: 1),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: Container(), flex: 2),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildNotes()),
            ],
          ),
          const MoleculeItemSpace(),
          _buildOrderTitle(userOrder),
          const MoleculeItemSpace(),
          ...buildOrderItems(context, ref, userOrder),
          const MoleculeItemSpace(),
          Row(
            children: _buildActionButtons(userOrder),
          ),
        ],
      );

  Widget _buildOrderTitle(UserOrder userOrder) {
    if (userOrder.status == ProductOrderStatus.created) {
      return LangKeys.newOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.accepted) {
      return LangKeys.acceptedOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.inProgress) {
      return LangKeys.inProgressOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.ready) {
      return LangKeys.readyOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.dispatched) {
      return LangKeys.dispatchedOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.delivered) {
      return LangKeys.deliveredOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.closed) {
      return LangKeys.closedOrder.tr().h3;
    } else if (userOrder.status == ProductOrderStatus.returned) {
      return LangKeys.returnedOrder.tr().h3;
    } else {
      return "".h2;
    }
  }

  Widget _buildUserNick() => MoleculeInput(
        title: LangKeys.labelCustomer.tr(),
        controller: _userNickController,
        maxLines: 1,
        readOnly: true,
      );

  Widget _buildOrderDate() => MoleculeInput(
        title: LangKeys.labelOrderDate.tr(),
        controller: _dateController,
        maxLines: 1,
        readOnly: true,
      );

  Widget _buildPrice() => MoleculeInput(
        title: LangKeys.labelPrice.tr(),
        controller: _priceController,
        maxLines: 1,
        readOnly: true,
      );

  Widget _buildAddressLine1() => MoleculeInput(
        title: LangKeys.labelCustomerAddressLine1.tr(),
        controller: _address1Controller,
        readOnly: true,
      );

  Widget _buildCity() => MoleculeInput(
        title: LangKeys.labelCity.tr(),
        controller: _priceController,
        maxLines: 1,
        readOnly: true,
      );

  Widget _buildAddressLine2() => MoleculeInput(
        title: LangKeys.labelCustomerAddressLine2.tr(),
        controller: _address2Controller,
        readOnly: true,
      );

  Widget _buildNotes() => MoleculeInput(
        title: LangKeys.labelOrderNotes.tr(),
        controller: _notesController,
        maxLines: 3,
        readOnly: true,
      );

  List<Widget> _buildActionButtons(UserOrder userOrder) {
    if (userOrder.status == ProductOrderStatus.created) {
      return [
        Expanded(child: _buildCancelButton(userOrder)),
        const MoleculeItemHorizontalSpace(),
        Expanded(child: _buildAcceptButton(userOrder)),
      ];
    } else if (userOrder.status == ProductOrderStatus.accepted) {
      return [
        Expanded(child: _buildCancelButton(userOrder)),
        const MoleculeItemHorizontalSpace(),
        Expanded(child: _buildInProgressButton(userOrder)),
        const MoleculeItemHorizontalSpace(),
        Expanded(child: _buildReadyButton(userOrder)),
      ];
    } else if (userOrder.status == ProductOrderStatus.ready) {
      return [
        Expanded(child: _buildCancelButton(userOrder)),
        const MoleculeItemHorizontalSpace(),
        Expanded(child: _buildDispatchButton(userOrder)),
      ];
    } else if (userOrder.status == ProductOrderStatus.dispatched) {
      return [
        Expanded(child: _buildReturnedButton(userOrder)),
        const MoleculeItemHorizontalSpace(),
        Expanded(child: _buildDeliveredButton(userOrder)),
      ];
    } else if (userOrder.status == ProductOrderStatus.delivered) {
      return [
        Expanded(child: _buildCloseButton(userOrder)),
      ];
    } else {
      return [];
    }
  }

  Widget _buildCancelButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonCancel.tr(),
        color: ref.scheme.negative,
        onTap: () {
          Future.delayed(fastRefreshDuration, () => ProductOrderMenuItems.askToCancelOrder(context, ref, userOrder));
        },
      );

  Widget _buildAcceptButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonAccept.tr(),
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastAcceptingOrder.tr(args: [userOrder.userNickname]));
          ref.read(productOrderPatchLogic.notifier).accept(userOrder);
        },
      );

  Widget _buildInProgressButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonInProgress.tr(),
        color: ref.scheme.paperBold,
        onTap: () {
          showWaitDialog(context, ref, "toast_marking_order_in_progress".tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.inProgress);
        },
      );

  Widget _buildReadyButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonReady.tr(),
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderReady.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.ready);
        },
      );

  Widget _buildDispatchButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonDispatch.tr(),
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDispatched.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.dispatched);
        },
      );

  Widget _buildReturnedButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonReturned.tr(),
        color: ref.scheme.negative,
        onTap: () {
          Future.delayed(fastRefreshDuration, () => ProductOrderMenuItems.askToMarkAsReturned(context, ref, userOrder));
        },
      );

  Widget _buildDeliveredButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonDelivered.tr(),
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastMarkingOrderDelivered.tr());
          ref.read(productOrderPatchLogic.notifier).mark(userOrder, ProductOrderStatus.delivered);
        },
      );

  Widget _buildCloseButton(UserOrder userOrder) => MoleculePrimaryButton(
        titleText: LangKeys.buttonClose.tr(),
        onTap: () {
          showWaitDialog(context, ref, LangKeys.toastClosingOrder.tr());
          ref.read(productOrderPatchLogic.notifier).closeOrder(userOrder);
        },
      );
}

/*
List<Widget> buildOrderItems(BuildContext context, WidgetRef ref, UserOrder userOrder) {
  final List<Widget> widgets = [];
  final orderItems = userOrder.orderItems;
  final currency = userOrder.totalPriceCurrency;
  final locale = context.locale.languageCode;
  final orderPrice =
      (currency != null && userOrder.totalPrice != null) ? currency.formatSymbol(userOrder.totalPrice!, locale) : "";
  if (orderItems != null)
    for (final item in orderItems) {
      widgets.add(MoleculeTableRow(label: "${item.qty}x ${item.itemName}", value: orderPrice));
      final List<String> modificationNames = [];
      item.modifications.sort((a, b) => a.modificationName.compareTo(b.modificationName));
      for (final modification in item.modifications) {
        if (!modificationNames.contains(modification.modificationName)) {
          widgets.add(MoleculeTableRow(label: "   ${modification.modificationName}"));
          modificationNames.add("${modification.modificationName} (${modification.optionName})");
        }
        widgets.add(
          MoleculeTableRow(
            label: modification.optionName,
            value: "+ ${currency!.formatSymbol(modification.optionPrice, locale)}",
          ),
        );
      }
    }
  widgets.add(
    MoleculeTableRow(
        label: LangKeys.deliveryFee.tr(),
        value: "+ ${userOrder.deliverPrice != null ? currency!.formatSymbol(userOrder.deliverPrice!, locale) : 0}"),
  );
  return widgets;
}
*/

List<Widget> buildOrderItems(BuildContext context, WidgetRef ref, UserOrder order) {
  final List<Widget> widgets = [];
  final orderItems = order.items;
  if (orderItems == null) return widgets;
  final locale = context.languageCode;
  final currency = order.totalPriceCurrency;
  final orderPrice =
      (currency != null && order.totalPrice != null) ? currency.formatSymbol(order.totalPrice!, locale) : "";
  for (final item in orderItems) {
    widgets.add(
      Row(
        children: [
          SizedBox(child: "${item.qty}x".label, width: 32),
          Expanded(child: item.name.label),
          orderPrice.label,
        ],
      ),
    );
    item.modifications?.forEach((modification) {
      if (modification.options != null)
        for (final option in modification.options!) {
          widgets.add(
            Row(
              children: [
                SizedBox(width: 32),
                Expanded(child: option.name.label.thin),
                currency!.formatSymbol(option.price, locale).label.thin,
              ],
            ),
          );
        }
    });
  }
  widgets.add(SizedBox(height: 8));
  widgets.add(
    Row(
      children: [
        Expanded(child: LangKeys.deliveryFee.tr().label),
        orderPrice.label,
      ],
    ),
  );
  widgets.add(SizedBox(height: 8));
  return widgets;
}

// eof

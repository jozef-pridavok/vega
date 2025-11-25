import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:vega_app/states/order/cart.dart";
import "package:vega_app/states/user/addresses.dart";
import "package:vega_app/widgets/address.dart";

import "../../caches.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../profile/screen_address_edit.dart";
import "../screen_app.dart";
import "widget_summary_order.dart";

class OrderConfirmScreen extends AppScreen {
  const OrderConfirmScreen({super.key});

  @override
  createState() => _OrderState();
}

class _OrderState extends AppScreenState<OrderConfirmScreen> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenTitleOrderConfirm.tr(),
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userAddressesLogic.notifier).load());
  }

  void _listenToCartLogic(BuildContext context) {
    ref.listen<CartState>(cartLogic, (previous, state) {
      if (state is CartSent) {
        ref.read(ordersLogic(state.order.clientId).notifier).refresh();
        ref.read(cartLogic.notifier).cancelOrder();
        toastInfo(LangKeys.operationSuccessful.tr());
        context.pop();
      } else if (state is CartCanceled) {
        context.pop();
      } else if (state is CartSendFailed) {
        toastError(LangKeys.operationFailed.tr());
        Future.delayed(stateRefreshDuration, () => ref.read(cartLogic.notifier).reopen());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToCartLogic(context);
    final cart = ref.watch(cartLogic);
    final order = cart.order;
    final items = order.items;
    final currency = order.totalPriceCurrency;
    final price = order.totalPrice;
    final formattedPrice = price != null ? currency?.formatCode(price, context.languageCode) : null;
    return PullToRefresh(
      onRefresh: () => ref.read(userAddressesLogic.notifier).refresh(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(moleculeScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Addresses(),
                const MoleculeItemSpace(),
                const _DeliveryType(),
                const MoleculeItemSpace(),
                const _DeliveryDateTime(),
                const MoleculeItemSpace(),
                const _DeliveryNotes(),
                if (items != null) ...[
                  const MoleculeItemSpace(),
                  MoleculeItemTitle(header: LangKeys.sectionItemsInOrder.tr()),
                  const MoleculeItemSpace(),
                  ...items.expand((item) => [_buildItem(context, item), const MoleculeItemSpace()]),
                ],
                const MoleculeItemSpace(),
                OrderSummaryWidget(order: order),
                if (formattedPrice != null) ...[
                  const MoleculeItemSpace(),
                  formattedPrice.h3.color(ref.scheme.content).alignCenter,
                ],
                const MoleculeItemSpace(),
                const _ConfirmOrderButton(),
                const MoleculeItemSpace(),
                const _CancelOrderButton(),
                const MoleculeItemSpace(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, UserOrderItem item) {
    final lang = context.languageCode;
    final photo = item.photo;
    final photoBh = item.photoBh;
    return MoleculeItemProgram(
      title: item.name,
      label: kDebugMode
          ? "${item.currency.formatSymbol(item.price, lang)} mods=${item.modifications?.length ?? 0} ${item.currency.formatSymbol(item.price, lang)}, photo=$photo"
          : item.currency.formatSymbol(item.price, lang),
      image: photo != null ? CachedImage(config: Caches.productPhoto, url: photo, blurHash: photoBh) : null,
      qty: item.qty,
      onQtyChanged: (isIncrement) {
        final notifier = ref.read(cartLogic.notifier);
        if (isIncrement) {
          notifier.increment(item);
        } else {
          notifier.decrement(item);
        }
      },
    );
  }
}

class _Addresses extends ConsumerStatefulWidget {
  // not const!
  @override
  createState() => _AddressesState();
}

class _AddressesState extends ConsumerState<_Addresses> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    final userAddresses = cast<UserAddressesSucceed>(ref.read(userAddressesLogic));
    if (userAddresses == null) {
      Future.microtask(() => ref.read(userAddressesLogic.notifier).load());
    } else {
      _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
      _updateAddress(context, userAddresses.addresses);
    }
  }

  void _updateAddress(BuildContext context, List<UserAddress> addresses) {
    final cart = ref.read(cartLogic);
    final currentAddressId = cart.order.deliveryAddressId;
    if (currentAddressId == null && addresses.isNotEmpty) {
      final preferredAddress = addresses.first;
      Future.microtask(() => ref.read(cartLogic.notifier).setDeliveryAddress(preferredAddress));
      int index = addresses.indexOf(preferredAddress);
      _pageController = PageController(viewportFraction: 0.9, initialPage: index);
    } else {
      final index = addresses.indexWhere((e) => e.userAddressId == currentAddressId);
      if (index >= 0)
        _pageController = PageController(viewportFraction: 0.9, initialPage: index);
      else
        _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    }
  }

  void _listenToUserAddressesLogic(BuildContext context) {
    ref.listen<UserAddressesState>(userAddressesLogic, (previous, state) {
      if (state is UserAddressesSucceed) {
        _updateAddress(context, state.addresses);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToUserAddressesLogic(context);
    final state = ref.watch(userAddressesLogic);
    if (state is UserAddressesSucceed || state is UserAddressesRefreshing) {
      final addresses =
          cast<UserAddressesSucceed>(state)?.addresses ?? cast<UserAddressesRefreshing>(state)?.addresses ?? [];

      return PageViewEx(
        physics: vegaScrollPhysic,
        padEnds: addresses.isNotEmpty,
        onPageChanged: (value) {
          ref.read(cartLogic.notifier).setDeliveryAddress(value == addresses.length ? null : addresses[value]);
        },
        controller: _pageController,
        children: [
          for (final address in addresses)
            AddressWidget(
              name: address.name,
              addressLine1: address.addressLine1,
              addressLine2: address.userAddressId,
              city: address.city,
              zip: address.zip,
              action: LangKeys.buttonEdit.tr(),
              onAction: () {
                ref.read(userAddressEditorLogic.notifier).edit(address);
                context.slideUp(const EditAddressScreen());
              },
            ),
          AddressWidget(
            icon: AtomIcons.plusCircle,
            name: LangKeys.labelNewAddress.tr(),
            action: "action_add".tr(),
            onAction: () {
              ref.read(userAddressEditorLogic.notifier).create();
              context.slideUp(const EditAddressScreen());
            },
          ),
        ],
        /*
        itemCount: addresses.length + 1,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8),
          child: (index == addresses.length)
              ? AddressWidget(
                  icon: AtomIcons.plusCircle,
                  name: LangKeys.labelNewAddress.tr(),
                  action: "action_add".tr(),
                  onAction: () {
                    ref.read(userAddressEditorLogic.notifier).create();
                    context.slideUp(const EditAddressScreen());
                  },
                )
              : AddressWidget(
                  name: addresses[index].name,
                  addressLine1: addresses[index].addressLine1,
                  addressLine2: addresses[index].userAddressId,
                  city: addresses[index].city,
                  zip: addresses[index].zip,
                  action: LangKeys.buttonEdit.tr(),
                  onAction: () {
                    ref.read(userAddressEditorLogic.notifier).edit(addresses[index]);
                    context.slideUp(const EditAddressScreen());
                  },
                ),
        ),
        */
      );
    } else if (state is UserAddressesFailed)
      return StatusErrorWidget(
        userAddressesLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.leaflet : null,
        onReload: () => ref.read(userAddressesLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _DeliveryType extends ConsumerStatefulWidget {
  const _DeliveryType();

  @override
  createState() => _DeliveryTypeState();
}

class _DeliveryTypeState extends ConsumerState<_DeliveryType> {
  final TextEditingController _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final cart = ref.read(cartLogic);
    _typeController.text = cart.order.deliveryType.localizedName;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartLogic);
    return MoleculeInput(
      controller: _typeController,
      title: LangKeys.labelDeliveryType.tr(),
      suffixIcon: const VegaIcon(name: AtomIcons.chevronDown),
      inputAction: TextInputAction.done,
      enableSuggestions: false,
      hint: LangKeys.hintDeliveryType.tr(),
      readOnly: true,
      maxLines: 1,
      enableInteractiveSelection: false,
      onTap: () => (cart is CartOpened) ? _pickDeliveryType(context, ref, cart) : null,
    );
  }

  void _pickDeliveryType(BuildContext context, WidgetRef ref, CartOpened cart) {
    const types = DeliveryType.values;
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.labelDeliveryType.tr()),
          const MoleculeItemSpace(),
          ...types.map(
            (e) => MoleculeItemBasic(
              title: e.localizedName,
              actionIcon: cart.order.deliveryType == e ? AtomIcons.check : null,
              onAction: () {
                context.pop();
                _typeController.text = e.localizedName;
                ref.read(cartLogic.notifier).setDeliveryType(e);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryDateTime extends ConsumerStatefulWidget {
  const _DeliveryDateTime();

  @override
  createState() => _DeliveryDateTimeState();
}

class _DeliveryDateTimeState extends ConsumerState<_DeliveryDateTime> {
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _update());
  }

  void _update() {
    final lang = context.languageCode;
    final cart = ref.read(cartLogic);
    final deliveryDate = cart.order.deliveryDate;
    _dateTimeController.text =
        deliveryDate != null ? formatDateTimePretty(lang, deliveryDate)! : LangKeys.deliveryDateTimeAsap.tr();
  }

  @override
  Widget build(BuildContext context) {
    return MoleculeInput(
      title: LangKeys.labelDeliveryDateTime.tr(),
      controller: _dateTimeController,
      suffixIcon: const VegaIcon(name: AtomIcons.chevronDown),
      inputAction: TextInputAction.done,
      enableSuggestions: false,
      readOnly: true,
      maxLines: 1,
      enableInteractiveSelection: false,
      onTap: () => _pickDateTime(context, ref),
    );
  }

  void _pickDateTime(BuildContext context, WidgetRef ref) => modalBottomSheet(
        context,
        Consumer(
          builder: (context, ref, _) {
            final cart = ref.watch(cartLogic) as CartOpened;
            final deliveryDate = cart.order.deliveryDate ?? DateTime.now();
            final startOfDay = cart.getStartOfOpeningHours(deliveryDate);
            final endOfDay = cart.getEndOfOpeningHours(deliveryDate);
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const MoleculeItemSpace(),
                MoleculeItemTitle(
                  header: LangKeys.labelDeliveryDateTime.tr(),
                  //action: LangKeys.coreDayToday.tr(),
                  //onAction: () {},
                ),
                const MoleculeItemSpace(),
                _DeliveryDate(
                  currentDate: deliveryDate,
                  //enabledDayPredicate: (day) => day.isToday || day.isAfter(DateTime.now()),
                  enabledDayPredicate: (day) =>
                      (day.isToday || day.isAfter(DateTime.now())) && cart.hasOpeningHours(day),
                  onChanged: (date) {
                    final startOfDay = cart.getStartOfOpeningHours(date);
                    if (startOfDay == null) {
                      //ref.read(cartLogic.notifier).refresh();
                      setState(() => _update());
                      return;
                    }
                    ref.read(cartLogic.notifier).setDeliveryDate(date, startOfDay);
                    setState(() => _update());
                  },
                ),
                const MoleculeItemSpace(),
                _DeliveryTime(
                  currentTime: TimeOfDay.fromDateTime(deliveryDate),
                  startOfDay: startOfDay,
                  endOfDay: endOfDay,
                  onChanged: (time) {
                    ref.read(cartLogic.notifier).setDeliveryTime(time);
                    setState(() => _update());
                  },
                ),
                const MoleculeItemSpace(),
                MoleculeSecondaryButton(
                  titleText: LangKeys.deliveryDateTimeAsap.tr(),
                  onTap: () {
                    ref.read(cartLogic.notifier).setDeliveryAsap();
                    setState(() => _update());
                    context.pop();
                  },
                ),
                const MoleculeItemSpace(),
              ],
            );
          },
        ),
      );
}

class _DeliveryDate extends ConsumerStatefulWidget {
  final DateTime currentDate;
  final bool Function(DateTime day)? enabledDayPredicate;
  //final bool Function(DateTime day)? selectedDayPredicate;
  final void Function(DateTime) onChanged;

  const _DeliveryDate(
      {required this.currentDate,
      required this.enabledDayPredicate,
      //required this.selectedDayPredicate,
      required this.onChanged});

  @override
  createState() => _DeliveryDateState();
}

class _DeliveryDateState extends ConsumerState<_DeliveryDate> {
  late DateTime? currentDate;

  @override
  initState() {
    super.initState();
    currentDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lang = context.languageCode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: Row(
            children: [
              Expanded(child: LangKeys.labelDate.tr().text.maxLine(1).overflowEllipsis.color(ref.scheme.content)),
              formatDatePretty(lang, currentDate).text.alignRight.maxLine(1).overflowEllipsis.color(ref.scheme.content),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MoleculeMonth(
          weekMode: true,
          focusedDay: currentDate ?? now,
          enabledDayPredicate: widget.enabledDayPredicate,
          selectedDayPredicate: (day) => currentDate != null && day.isSameDay(currentDate!),
          //selectedDayPredicate: widget.selectedDayPredicate,
          onPageChanged: (dateFrom) {},
          onDaySelected: (day) {
            setState(() => currentDate = day);
            widget.onChanged(day);
          },
        ),
      ],
    );
  }
}

class _DeliveryTime extends ConsumerStatefulWidget {
  final TimeOfDay currentTime;
  final TimeOfDay? startOfDay;
  final TimeOfDay? endOfDay;

  final void Function(TimeOfDay) onChanged;

  const _DeliveryTime({
    required this.currentTime,
    required this.startOfDay,
    required this.endOfDay,
    required this.onChanged,
  });

  @override
  createState() => _DeliveryTimeState();
}

class _DeliveryTimeState extends ConsumerState<_DeliveryTime> {
  int _divisions = 1;
  double _currentValue = 0;

  TimeOfDay _getTimeOfDay(TimeOfDay startOfDay, double value) {
    int totalMinutes = startOfDay.hour * 60 + startOfDay.minute + (value * 15).round();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  String _getTimeString(String locale) {
    if (widget.startOfDay == null) return "";
    final time = _getTimeOfDay(widget.startOfDay!, _currentValue);
    return DateFormat.Hm(locale).format(DateTime(0, 0, 0, time.hour, time.minute));
  }

  int calculateDivision(TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;
    return ((endMinutes - startMinutes) / 15).floor();
  }

  double calculateCurrentValue(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;
    int currentMinutes = current.hour * 60 + current.minute;
    if (currentMinutes < startMinutes) {
      return 0;
    } else if (currentMinutes > endMinutes) {
      return _divisions.toDouble();
    } else {
      return ((currentMinutes - startMinutes) / 15).floor().toDouble();
    }
  }

  void _setup() {
    final startOfDay = widget.startOfDay;
    final endOfDay = widget.endOfDay;
    if (startOfDay == null || endOfDay == null) return;
    _divisions = calculateDivision(startOfDay, endOfDay);
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant _DeliveryTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setup();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.languageCode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: Row(
            children: [
              Expanded(child: LangKeys.labelTime.tr().text.maxLine(1).overflowEllipsis.color(ref.scheme.content)),
              Expanded(
                  child: (widget.currentTime.toString()).text.maxLine(1).overflowEllipsis.color(ref.scheme.content)),
              _getTimeString(lang).text.alignRight.maxLine(1).overflowEllipsis.color(ref.scheme.content),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MoleculeSlider(
          initialValue: _currentValue,
          max: _divisions.toDouble(),
          divisions: _divisions,
          onChanged: (val) {
            final startOfDay = widget.startOfDay;
            if (startOfDay == null) return;
            setState(() => _currentValue = val);
            final time = _getTimeOfDay(startOfDay, val);
            widget.onChanged(time);
          },
        ),
      ],
    );
  }
}

class _DeliveryNotes extends ConsumerWidget {
  const _DeliveryNotes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartLogic);
    final notes = cart.order.notes;
    return MoleculeInput(
      title: LangKeys.labelNote.tr(),
      hint: LangKeys.hintNoteOrder.tr(),
      initialValue: notes,
      //controller: _notesController,
      inputAction: TextInputAction.done,
      maxLines: 3,
      onChanged: (val) => ref.read(cartLogic.notifier).setNotes(val),
    );
  }
}

class _ConfirmOrderButton extends ConsumerWidget {
  const _ConfirmOrderButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = cast<CartOpened>(ref.watch(cartLogic));
    return MoleculeActionButton(
      title: LangKeys.buttonOrder.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: cart?.buttonState ?? MoleculeActionButtonState.idle,
      onPressed: cart == null ? null : () => _sendOrder(context, ref, cart),
    );
  }

  void _sendOrder(BuildContext context, WidgetRef ref, CartOpened cart) {
    final error = cart.isNotReadyForSent();
    if (error != null) {
      ref.read(toastLogic.notifier).warning(error);
      if (cart.needsDeliveryAddress) _askToAddAddress(context, ref);
      return;
    }
    ref.read(cartLogic.notifier).sendOrder();
  }

  void _askToAddAddress(BuildContext context, WidgetRef ref) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogAddDeliveryAddressTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogAddDeliveryAddressMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: LangKeys.buttonAddAddress.tr(),
                onTap: () {
                  ref.read(userAddressEditorLogic.notifier).create();
                  context.pop();
                  context.slideUp(const EditAddressScreen());
                },
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: LangKeys.buttonClose.tr(),
                onTap: () => context.pop(),
                color: ref.scheme.negative,
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelOrderButton extends ConsumerWidget {
  const _CancelOrderButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeSecondaryButton(
      titleText: LangKeys.buttonCancelOrder.tr(),
      color: ref.scheme.negative,
      onTap: () => _askToCancelOrder(context, ref),
    );
  }

  void _askToCancelOrder(BuildContext context, WidgetRef ref) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogCancelOrderTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogCancelOrderMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: LangKeys.buttonCancelOrder.tr(),
                onTap: () => _cancelOrder(context, ref),
                color: ref.scheme.negative,
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(titleText: LangKeys.buttonClose.tr(), onTap: () => context.pop()),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, WidgetRef ref) async {
    context.pop();
    ref.read(cartLogic.notifier).cancelOrder();
  }
}
// eof

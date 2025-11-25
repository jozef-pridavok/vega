import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/extensions/time_of_day.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/src/consumer.dart";
import "package:intl/intl.dart";

import "../../enums/coupon_item_price.dart";
import "../../extensions/select_item.dart";
import "../../states/coupon_code.dart";
import "../../states/coupon_editor.dart";
import "../../states/locations.dart";
import "../../states/product_items.dart";
import "../../states/providers.dart";
import "../../states/reservation_slots.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../utils/validations.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";
import "screen_codes.dart";
import "screen_settings.dart";

class Item {
  String? itemId;
  int? itemPrice;

  Item(this.itemId, this.itemPrice);
}

class ScreenCouponEdit extends VegaScreen {
  static final notificationsTag = "ce964918-6c53-4e14-8304-434d340b9bc3";

  const ScreenCouponEdit({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<ScreenCouponEdit> {
  final notificationsTag = ScreenCouponEdit.notificationsTag;

  final unsavedWarningText = LangKeys.notificationUnsavedData.tr();

  //Coupon get _coupon => widget.coupon;

  final _formKey = GlobalKey<FormState>();

  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();
  final _productDiscountControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  late String _name;
  late String _discount;
  late CouponType _couponType;
  late String _code;
  late List<String> _codes;
  late String _description;
  String? _locationId;
  Reservation? _reservation;
  ReservationSlot? _slot;
  TimeOfDay? _timeFrom;
  TimeOfDay? _timeTo;
  IntDate? _validFrom;
  IntDate? _validTo;
  String? _image;
  List<Country>? _countries;

  late List<Country> _eligibleCountries;

  bool _loadingImage = false;
  List<int>? _newImage;

  var _days = [Day.monday, Day.tuesday, Day.wednesday, Day.thursday, Day.friday];

  int _productCount = 2;
  Map<int, Item> selectedItems = {};

  @override
  void initState() {
    super.initState();

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    _eligibleCountries = client.countries ?? [];

    final coupon = (ref.read(couponEditorLogic) as CouponEditorEditing).coupon;

    _name = coupon.name;
    _discount = coupon.discount ?? "";
    _couponType = coupon.type;
    _description = coupon.description ?? "";
    _countries = coupon.countries;
    _code = coupon.code ?? "";
    _codes = coupon.codes ?? [];
    if (_couponType == CouponType.array) _code = coupon.codes?.join(", ") ?? "";
    _locationId = coupon.locationId;
    _image = coupon.image;
    _validFrom = coupon.validFrom;
    _validTo = coupon.validTo;

    Future.microtask(() async {
      ref.read(locationsLogic.notifier).load();
      if (_couponType == CouponType.reservation) {
        _days = coupon.reservation?.days ?? _days;
        if (coupon.reservation?.from != null) {
          _timeFrom = coupon.reservation!.from!.toTimeOfDay();
          _timeFromController.text = _formattedTimeFrom(context.languageCode);
        }
        if (coupon.reservation?.to != null) {
          _timeTo = coupon.reservation!.to!.toTimeOfDay();
          _timeToController.text = _formattedTimeTo(context.languageCode);
        }

        await ref.read(activeReservationsLogic.notifier).load();
        if (coupon.reservation?.reservationId != null) {
          final reservations = cast<ReservationsSucceed>(ref.read(activeReservationsLogic))?.reservations ?? [];
          _reservation = reservations.firstWhereOrNull((r) => r.reservationId == coupon.reservation?.reservationId);
        }
        if (coupon.reservation?.slotId != null) {
          await ref.read(activeReservationsSlotLogic.notifier).load(coupon.reservation!.reservationId!, reload: true);
          final slots = cast<ReservationSlotsSucceed>(ref.read(activeReservationsSlotLogic))?.slots ?? [];
          _slot = slots.firstWhereOrNull((slot) => slot.reservationSlotId == coupon.reservation?.slotId);
        }
      } else if (_couponType == CouponType.product) {
        await ref.read(productItemsLogic.notifier).load();
        if (coupon.order?.itemIds != null) {
          coupon.order?.itemIds.asMap().forEach((index, itemId) {
            addItemId(index, itemId);
            addItemPrice(index, coupon.order!.itemPrices[index]);
            _productDiscountControllers[index].text =
                (coupon.order!.itemPrices[index] ?? 0) < 0 ? (coupon.order!.itemPrices[index]!).abs().toString() : "0";
          });
          _productCount = coupon.order!.itemIds.length;
          refresh();
        }
      }
    });
  }

  @override
  void dispose() {
    _timeFromController.dispose();
    _timeToController.dispose();
    for (final controller in _productDiscountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenCouponTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return super.onBack(ref);
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final coupon = (ref.watch(couponEditorLogic) as CouponEditorEditing).coupon;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: _buildSaveButton(),
        ),
      ],
      VegaMenuButton(
        items: [
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonSettings.tr(),
              onAction: () => context.popPush(SettingsScreen(coupon: coupon)),
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    final coupon = (ref.read(couponEditorLogic) as CouponEditorEditing).coupon;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _buildMobileLayout(coupon) : _buildDefaultLayout(coupon),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void addItemId(int index, String itemId) {
    if (selectedItems[index] != null) {
      selectedItems[index]!.itemId = itemId;
    } else {
      selectedItems[index] = Item(itemId, null);
    }
  }

  void addItemPrice(int index, int? itemPrice) {
    if (selectedItems[index] != null) {
      selectedItems[index]!.itemPrice = itemPrice;
    } else {
      selectedItems[index] = Item(null, itemPrice);
    }
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<CouponEditorState>(couponEditorLogic, (previous, next) {
      if (next is CouponEditorFailed) {
        toastCoreError(next.error);
        delayedStateRefresh(() => ref.read(couponEditorLogic.notifier).reedit());
      } else if (next is CouponEditorSaved) {
        dismissUnsaved(notificationsTag);
        delayedStateRefresh(() => ref.read(couponEditorLogic.notifier).reedit());
        var key = ref.read(activeCouponsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        key = ref.read(preparedCouponsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
    ref.listen<CouponCodesGeneratorState>(couponCodesGeneratorLogic, (previous, next) {
      if (next is CouponCodesGenerated) {
        setState(() => _codes = next.codes.map((e) => e.code).toList());
      }
    });
  }

  Widget _buildMobileLayout(Coupon coupon) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildName(),
          const MoleculeItemSpace(),
          _buildDiscount(),
          const MoleculeItemSpace(),
          _buildType(),
          const MoleculeItemSpace(),
          if (_couponType == CouponType.universal || _couponType == CouponType.array) ...[
            _buildCode(),
            const MoleculeItemSpace(),
          ],
          Row(
            children: [
              Flexible(child: _buildCountries()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLocation()),
            ],
          ),
          const MoleculeItemSpace(),
          if (_couponType == CouponType.reservation) ...[
            Row(
              children: [
                Flexible(child: _buildReservation(coupon)),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildSlot(coupon)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Flexible(child: _buildTimeFromField(context)),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildTimeToField(context)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Flexible(child: _buildDaysField()),
              ],
            ),
            const MoleculeItemSpace(),
          ],
          if (_couponType == CouponType.product) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildProductCount(), flex: 1),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: Container(), flex: 2),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProductSelect(0, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductPrice(0, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductDiscount(0)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProductSelect(1, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductPrice(1, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductDiscount(1)),
              ],
            ),
            const MoleculeItemSpace(),
            if (_productCount > 2) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(2, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(2, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(2)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
            if (_productCount > 3) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(3, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(3, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(3)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
            if (_productCount > 4) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(4, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(4, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(4)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
          ],
          Row(
            children: [
              Flexible(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildValidTo()),
            ],
          ),
          const MoleculeItemSpace(),
          _buildImage(),
          const MoleculeItemSpace(),
          _buildDescription(),
          const MoleculeItemSpace(),
          _buildSaveButton(),
          const MoleculeItemSpace(),
        ],
      );

  Widget _buildDefaultLayout(Coupon coupon) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDiscount()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildType()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_couponType == CouponType.universal || _couponType == CouponType.array) ...[
                Flexible(child: _buildCode(), flex: 1),
                const MoleculeItemHorizontalSpace(),
              ],
              Flexible(child: _buildCountries(), flex: 1),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLocation(), flex: 1),
            ],
          ),
          const MoleculeItemSpace(),
          if (_couponType == CouponType.reservation) ...[
            Row(
              children: [
                Flexible(child: _buildReservation(coupon)),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildSlot(coupon)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Flexible(child: _buildTimeFromField(context)),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildTimeToField(context)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Flexible(child: _buildDaysField()),
              ],
            ),
            const MoleculeItemSpace(),
          ],
          if (_couponType == CouponType.product) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildProductCount(), flex: 1),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: Container(), flex: 2),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProductSelect(0, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductPrice(0, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductDiscount(0)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProductSelect(1, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductPrice(1, coupon)),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildProductDiscount(1)),
              ],
            ),
            const MoleculeItemSpace(),
            if (_productCount > 2) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(2, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(2, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(2)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
            if (_productCount > 3) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(3, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(3, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(3)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
            if (_productCount > 4) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductSelect(4, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductPrice(4, coupon)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(child: _buildProductDiscount(4)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildValidTo()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildImage()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.couponNameLabel.tr(),
        initialValue: _name,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.length ?? 0) < 1 ? LangKeys.couponNameRequired.tr() : null,
        onChanged: (value) async {
          notifyUnsaved(notificationsTag);
          _name = value;
        },
      );

  Widget _buildType() {
    return MoleculeSingleSelect(
      title: LangKeys.labelCouponType.tr(),
      hint: "",
      items: CouponType.values.toSelectItems(),
      selectedItem: _couponType.toSelectItem(),
      onChanged: (selectedItem) {
        notifyUnsaved(notificationsTag);
        setState(() {
          _couponType = CouponType.values.firstWhere((element) => element.code.toString() == selectedItem.value);
          if (_couponType == CouponType.reservation) ref.read(activeReservationsLogic.notifier).load();
          if (_couponType == CouponType.product) ref.read(productItemsLogic.notifier).load();
        });
      },
    );
  }

  Widget _buildDiscount() => MoleculeInput(
        title: LangKeys.labelCouponDiscount.tr(),
        initialValue: _discount,
        maxLines: 1,
        onChanged: (value) async {
          notifyUnsaved(notificationsTag);
          _discount = value;
        },
      );

  Widget _buildCountries() => MoleculeMultiSelect(
        title: LangKeys.labelCountries.tr(),
        hint: LangKeys.locationEverywhere.tr(),
        items: _eligibleCountries.toSelectItems(),
        maxSelectedItems: 99,
        selectedItems: _countries?.toSelectItems() ?? [],
        clearable: true,
        onChanged: (selectedItems) {
          _countries = selectedItems.map((e) => CountryCode.fromCode(e.value)).toList();
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildLocation() {
    final locations = cast<LocationsSucceed>(ref.watch(locationsLogic))?.locations ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelLocation.tr(),
      hint: LangKeys.locationEverywhere.tr(),
      items: locations.toSelectItems(),
      selectedItem: locations.firstWhereOrNull((e) => e.locationId == _locationId)?.toSelectItem(),
      onChangedOrClear: (selectedItem) {
        notifyUnsaved(notificationsTag);
        _locationId = selectedItem?.value;
      },
    );
  }

  Widget _buildReservation(Coupon coupon) {
    final reservations = cast<ReservationsSucceed>(ref.watch(activeReservationsLogic))?.reservations ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelReservation.tr(),
      hint: "",
      items: reservations.toSelectItems(),
      onChangedOrClear: (selectedItem) {
        _reservation = reservations.firstWhereOrNull((r) => r.reservationId == selectedItem?.value);
        if (selectedItem != null) {
          ref.read(activeReservationsSlotLogic.notifier).load(_reservation!.reservationId, reload: true);
        } else {
          _slot = null;
        }
        notifyUnsaved(notificationsTag);
        refresh();
      },
      selectedItem: reservations
          .firstWhereOrNull((res) => res.reservationId == coupon.reservation?.reservationId)
          ?.toSelectItem(),
    );
  }

  Widget _buildSlot(Coupon coupon) {
    final slotsState = ref.watch(activeReservationsSlotLogic);
    final slots = cast<ReservationSlotsSucceed>(slotsState)?.slots ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelReservationSlot.tr(),
      hint: "",
      items: slots.toSelectItems(),
      onChangedOrClear: (selectedItem) {
        _slot = slots.firstWhereOrNull((slot) => slot.reservationSlotId == selectedItem?.value);
        notifyUnsaved(notificationsTag);
      },
      enabled: _reservation != null && slotsState is ReservationSlotsSucceed,
      selectedItem:
          slots.firstWhereOrNull((slot) => slot.reservationSlotId == coupon.reservation?.slotId)?.toSelectItem(),
    );
  }

  void _selectTimeFrom(
    BuildContext context, {
    TimeOfDay? timeFrom,
    Function(TimeOfDay newTimeFrom)? onSelected,
  }) async {
    final newTimeFrom = await showTimePicker(
      context: context,
      initialTime: timeFrom ?? TimeOfDay.now(),
    );
    if (newTimeFrom != null) onSelected?.call(newTimeFrom);
  }

  Widget _buildTimeFromField(BuildContext context) => MoleculeInput(
        controller: _timeFromController,
        readOnly: true,
        validator: (val) => (val?.length ?? 0) > 0 ? null : LangKeys.validationTimeFrom.tr(),
        onTap: () => _selectTimeFrom(
          context,
          timeFrom: _timeFrom,
          onSelected: (newTimeFrom) => setState(() {
            _timeFrom = newTimeFrom;
            _timeFromController.text = _formattedTimeFrom(context.languageCode);
          }),
        ),
        title: LangKeys.labelTimeFrom.tr(),
      );

  void _selectTimeTo(
    BuildContext context, {
    TimeOfDay? timeTo,
    Function(TimeOfDay newTimeTo)? onSelected,
  }) async {
    final newTimeTo = await showTimePicker(
      context: context,
      initialTime: timeTo ?? TimeOfDay.now(),
    );
    if (newTimeTo != null) onSelected?.call(newTimeTo);
  }

  Widget _buildTimeToField(BuildContext context) {
    return MoleculeInput(
      controller: _timeToController,
      readOnly: true,
      validator: (val) => (val?.length ?? 0) > 0 ? null : LangKeys.validationTimeTo.tr(),
      onTap: () => _selectTimeTo(
        context,
        timeTo: _timeTo,
        onSelected: (newTimeTo) => setState(() {
          _timeTo = newTimeTo;
          _timeToController.text = _formattedTimeTo(context.languageCode);
        }),
      ),
      title: LangKeys.labelTimeTo.tr(),
    );
  }

  Widget _buildDaysField() {
    final weekdays = DateFormat().dateSymbols.SHORTWEEKDAYS.toList();
    String sundayString = weekdays.removeAt(0);
    weekdays.add(sundayString);
    return Wrap(
      children: weekdays.asMap().entries.map((e) {
        int index = e.key;
        String value = e.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _days.contains(Day.values[index]),
              onChanged: (value) => setState(() =>
                  _days.contains(Day.values[index]) ? _days.remove(Day.values[index]) : _days.add(Day.values[index])),
            ),
            value.text,
            const MoleculeItemHorizontalSpace(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProductCount() {
    return MoleculeSingleSelect(
      title: LangKeys.labelProductCount.tr(),
      hint: "",
      items: [
        SelectItem(label: "2", value: "2"),
        SelectItem(label: "3", value: "3"),
        SelectItem(label: "4", value: "4"),
        SelectItem(label: "5", value: "5"),
      ],
      selectedItem: SelectItem(label: _productCount.toString(), value: _productCount.toString()),
      onChanged: (selectedItem) {
        notifyUnsaved(notificationsTag);
        _productCount = tryParseInt(selectedItem.value)!;
        refresh();
      },
    );
  }

  Widget _buildProductSelect(int productIndex, Coupon coupon) {
    final itemsState = ref.read(productItemsLogic);
    final List<ProductItem> items = itemsState is ProductItemsSucceed ? itemsState.productItems : [];
    final itemId = coupon.order?.itemIds != null && coupon.order!.itemIds.length > productIndex
        ? coupon.order!.itemIds[productIndex]
        : null;
    return MoleculeSingleSelect(
      title: LangKeys.labelProductItem.tr(),
      hint: "",
      items: items.toSelectItems(),
      onChanged: (selectedItem) {
        final itemId = selectedItem.value;
        addItemId(productIndex, itemId);
        notifyUnsaved(notificationsTag);
      },
      selectedItem: items.firstWhereOrNull((item) => item.itemId == itemId)?.toSelectItem(),
    );
  }

  Widget _buildProductPrice(int productIndex, Coupon coupon) {
    return MoleculeSingleSelect(
      title: LangKeys.labelPrice.tr(),
      hint: "",
      items: CouponItemPrice.values.toSelectItems(),
      onChanged: (selectedItem) {
        CouponItemPrice selectedPrice = CouponItemPrice.values.firstWhere((e) => e.toString() == selectedItem.value);
        switch (selectedPrice) {
          case CouponItemPrice.original:
            addItemPrice(productIndex, null);
            _productDiscountControllers[productIndex].text = "0";
          case CouponItemPrice.free:
            addItemPrice(productIndex, 0);
            _productDiscountControllers[productIndex].text = "0";
          case CouponItemPrice.percentage:
            addItemPrice(productIndex, -20);
            _productDiscountControllers[productIndex].text = "20";
        }
        notifyUnsaved(notificationsTag);
        refresh();
      },
      selectedItem: (coupon.order?.itemPrices.length ?? 0) > productIndex
          ? switch (coupon.order?.itemPrices[productIndex]) {
              null => CouponItemPrice.original.toSelectItem(),
              0 => CouponItemPrice.free.toSelectItem(),
              _ => CouponItemPrice.percentage.toSelectItem()
            }
          : null,
    );
  }

  Widget _buildProductDiscount(int productIndex) {
    return MoleculeInput(
      title: LangKeys.labelPercentageDiscount.tr(),
      controller: _productDiscountControllers[productIndex],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: 1,
      onChanged: (value) {
        notifyUnsaved(notificationsTag);
        if (value.isEmpty || !isInt(value, min: 1, max: 100)) return;
        addItemPrice(productIndex, -tryParseInt(value)!);
      },
      suffixText: "%",
      validator: (value) {
        if (value == null || value.isEmpty || !isInt(value, min: 1, max: 100))
          return LangKeys.validationValueInvalid.tr();
        return null;
      },
      enabled: selectedItems[productIndex]?.itemPrice != null && selectedItems[productIndex]!.itemPrice! < 0,
    );
  }

  Widget _buildValidFrom() => MoleculeDatePicker(
        title: LangKeys.labelValidFrom.tr(),
        hint: LangKeys.hintValidFrom.tr(),
        initialValue: _validFrom?.toDate(),
        onChanged: (selectedDate) {
          _validFrom = IntDate.fromDate(selectedDate);
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildValidTo() => MoleculeDatePicker(
        title: LangKeys.labelValidTo.tr(),
        hint: LangKeys.hintValidTo.tr(),
        initialValue: _validTo?.toDate(),
        onChangedOrNull: (selectedDate) {
          _validTo = selectedDate?.toIntDate();
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildDescription() => MoleculeInput(
      title: LangKeys.labelCouponDescription.tr(),
      initialValue: _description,
      maxLines: 5,
      onChanged: (value) {
        notifyUnsaved(notificationsTag);
        _description = value;
      });

  Widget _buildCode() {
    if (_couponType == CouponType.universal)
      return MoleculeInput(
        title: LangKeys.labelCouponCode.tr(),
        initialValue: _code,
        maxLines: 1,
        onChanged: (value) {
          notifyUnsaved(notificationsTag);
          _code = value;
        },
      );
    else if (_couponType == CouponType.array) {
      final maxCodes = 3;
      final codes = _codes;
      final headCodes = codes.take(maxCodes);
      final remainingCodes = codes.length - headCodes.length;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: MoleculeInput(
              title: LangKeys.labelCouponCode.tr(),
              initialValue: headCodes.join(", ") + (remainingCodes > 0 ? " +$remainingCodes" : ""),
              maxLines: 1,
              readOnly: true,
            ),
          ),
          const MoleculeItemHorizontalSpace(),
          Expanded(
            child: MoleculeSecondaryButton(
              titleText: LangKeys.buttonCouponCodeSetup.tr(),
              onTap: () => context.push(EditCouponCodesScreen(_codes)),
            ),
          ),
        ],
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget _buildImage() {
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    final clientLogo = client.logo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickFile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding / 4),
        child: MoleculeCardLoyaltyMedium(
          label: _description,
          image: AspectRatio(
            aspectRatio: 3 / 1,
            child: IndexedStack(
              index: _loadingImage ? 0 : 1,
              alignment: Alignment.center,
              children: [
                const CenteredWaitIndicator(),
                _newImage != null
                    ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.cover)
                    : _image != null
                        ? Image.network(_image!, fit: BoxFit.cover)
                        : LangKeys.hintClickToSetImage.tr().text.alignCenter,
              ],
            ),
          ),
          logo: MoleculusCardGrid1(
            backgroundColor: ref.scheme.paperCard,
            shadow: false,
            image: clientLogo != null
                ? Image.network(clientLogo, fit: BoxFit.cover)
                : Container(color: ref.scheme.content10),
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    setState(() => _loadingImage = true);
    final image = await ImagePicker().pickImage();
    if (image == null) return setState(() => _loadingImage = false);
    _newImage = image.toList();
    setState(() => _loadingImage = false);
    notifyUnsaved(notificationsTag);
  }

  Widget _buildSaveButton() {
    final buttonState = ref.watch(couponEditorLogic).buttonState;
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: buttonState,
      onPressed: () {
        if (!_formKey.currentState!.validate()) return;
        final editing = ref.read(couponEditorLogic) as CouponEditorEditing;
        if (editing.isNew && _newImage == null) return toastError(LangKeys.validationImageRequired.tr());
        if (!isValidFromTo(ref, _validFrom, _validTo, validFromInFuture: false, validToIsRequired: true)) return;
        CouponReservation? reservation;
        CouponOrder? order;
        if (_couponType == CouponType.reservation) {
          _days.sort((a, b) => a.index.compareTo(b.index));
          reservation = CouponReservation(
            reservationId: _reservation?.reservationId,
            slotId: _slot?.reservationSlotId,
            from: _timeFrom!.toIntDayMinutes(),
            to: _timeTo!.toIntDayMinutes(),
            days: _days,
          );
        } else if (_couponType == CouponType.product) {
          if (selectedItems.length < _productCount) {
            toastError(LangKeys.validationProductsRequired.tr());
            return;
          }
          Map<int, Item> filteredItems =
              Map.fromEntries(selectedItems.entries.where((entry) => entry.key < _productCount));
          order = CouponOrder(
            itemIds: filteredItems.values.map((e) => e.itemId!).toList(),
            itemPrices: filteredItems.values.map((e) => e.itemPrice).toList(),
          );
        }
        ref.read(couponEditorLogic.notifier).set(
              name: _name,
              discount: _discount,
              type: _couponType,
              code: _couponType == CouponType.universal ? _code : null,
              codes: _couponType == CouponType.array ? _codes : null,
              description: _description,
              countries: _countries,
              validFrom: _validFrom,
              validTo: _validTo,
              locationId: _locationId,
              couponReservation: reservation,
              couponOrder: order,
            );
        ref.read(couponEditorLogic.notifier).save(newImage: _newImage);
      },
    );
  }

  String _formattedTimeFrom(String locale) {
    final target = DateTime.now().copyWith(
      hour: _timeFrom?.hour,
      minute: _timeFrom?.minute,
    );
    return DateFormat.jm(locale).format(target.toLocal());
  }

  String _formattedTimeTo(String locale) {
    final target = DateTime.now().copyWith(
      hour: _timeTo?.hour,
      minute: _timeTo?.minute,
    );
    return DateFormat.jm(locale).format(target.toLocal());
  }
}

// eof

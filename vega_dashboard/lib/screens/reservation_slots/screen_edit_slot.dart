import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/locations.dart";
import "../../states/providers.dart";
import "../../states/reservation_slot_editor.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_color.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditSlotScreen extends VegaScreen {
  final Reservation reservation;
  const EditSlotScreen(this.reservation, {super.key}) : super();

  @override
  createState() => _EditSlotState();
}

class _EditSlotState extends VegaScreenState<EditSlotScreen> {
  final notificationsTag = "40fcd679-43a7-428c-a711-35665cba6fc4";

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _colorController = TextEditingController();
  final _discountController = TextEditingController();

  late Currency _currency;
  late String? _locationId;
  late Color _color;

  @override
  void initState() {
    super.initState();

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    final slot = (ref.read(reservationSlotEditorLogic) as ReservationSlotEditorEditing).slot;

    _color = slot.color;
    _currency = slot.currency ?? client.currency;
    _locationId = slot.locationId;
    _color = slot.color;

    Future.microtask(() {
      _nameController.text = slot.name;
      _descriptionController.text = slot.description ?? "";
      _durationController.text = slot.duration?.toString() ?? "";
      _colorController.text = _color.toHex();
      _discountController.text =
          slot.meta?["discount"]?.toString() ?? widget.reservation.meta?["discount"]?.toString() ?? "";
      final currency = slot.currency;
      final price = slot.price;
      final locale = context.locale.languageCode;
      _priceController.text = (currency != null && price != null) ? currency.format(price, locale) : "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _colorController.dispose();
    _discountController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationSlotEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout() : _defaultLayout(),
        ),
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ReservationSlotEditorState>(reservationSlotEditorLogic, (previous, next) {
      if (next is ReservationSlotEditorFailed) {
        toastError(LangKeys.operationFailed.tr());
        Future.delayed(stateRefreshDuration, () => ref.read(reservationSlotEditorLogic.notifier).reedit());
      } else if (next is ReservationSlotEditorSaved) {
        dismissUnsaved(notificationsTag);
        Future.delayed(stateRefreshDuration, () => ref.read(reservationSlotEditorLogic.notifier).reedit());
        final key = ref.read(activeReservationsSlotLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
  }

  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDuration()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildLocation()),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildColor()),
              ],
            ),
          ),
          if (widget.reservation.loyaltyMode == LoyaltyMode.discountForCreditPayment) ...[
            _buildDiscount(),
            const MoleculeItemSpace(),
            _buildDiscountResetButton(),
            const MoleculeItemSpace(),
            _buildNoDiscountButton(),
          ],
          const MoleculeItemSpace(),
          Row(children: [Expanded(child: _buildDescription())]),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDuration()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildLocation()),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildColor()),
              ],
            ),
          ),
          if (widget.reservation.loyaltyMode == LoyaltyMode.discountForCreditPayment) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildDiscount()),
                const MoleculeItemHorizontalSpace(),
                _buildDiscountResetButton(),
                const MoleculeItemHorizontalSpace(),
                _buildNoDiscountButton(),
              ],
            ),
          ],
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(
                child: _buildDescription(),
              )
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: _nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildPrice() {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      title: LangKeys.labelPrice.tr(),
      controller: _priceController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) {
        if (val?.isEmpty ?? true) return null;
        return !((_currency.parse(val, locale) ?? -1) >= _currency.expand(0))
            ? LangKeys.validationPriceInvalidFormat.tr()
            : null;
      },
      maxLines: 1,
      onChanged: (value) => notifyUnsaved(notificationsTag),
      suffixText: _currency.code,
    );
  }

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  static const _minimalDuration = 5;

  Widget _buildDuration() => MoleculeInput(
        title: LangKeys.labelDuration.tr(),
        suffixText: "min",
        controller: _durationController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => (val?.isNotEmpty ?? false) && !isInt(val!, min: _minimalDuration)
            ? LangKeys.validationMinimalNumber.tr(args: [_minimalDuration.toString()])
            : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildColor() => MoleculeColorPicker(
        title: LangKeys.labelColor.tr(),
        hint: LangKeys.hintPickColor.tr(),
        initialValue: _color,
        onChanged: (newColor) {
          if (newColor == null) return;
          _color = newColor;
          _colorController.text = _color.toHex();
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
        _locationId = selectedItem?.value;
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildDiscount() => MoleculeInput(
        title: LangKeys.labelDiscount.tr(),
        hint: LangKeys.hintDiscount.tr(),
        controller: _discountController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
          if (!isInt(value!, min: 0, max: 99)) return LangKeys.validationValueInvalid.tr();
          return null;
        },
        suffixText: "%",
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildDiscountResetButton() => MoleculeSecondaryButton(
        titleText: LangKeys.buttonProgramToPoints.tr(),
        onTap: () {
          _discountController.text = widget.reservation.meta?["discount"]?.toString() ?? "";
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildNoDiscountButton() => MoleculeSecondaryButton(
        titleText: LangKeys.buttonNoDiscount.tr(),
        onTap: () {
          _discountController.text = "0";
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildSaveButton() {
    final state = ref.watch(reservationSlotEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;
        ref.read(reservationSlotEditorLogic.notifier).set(
              name: _nameController.text,
              price: _currency.parse(_priceController.text),
              currency: _currency,
              duration: tryParseInt(_durationController.text),
              locationId: _locationId,
              color: _color,
              description: _descriptionController.text,
              discount: tryParseInt(_discountController.text),
            );
        await ref.read(reservationSlotEditorLogic.notifier).save();
      },
    );
  }
}

// eof

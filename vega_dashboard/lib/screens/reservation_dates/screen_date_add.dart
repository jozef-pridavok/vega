import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/src/consumer.dart";
import "package:intl/intl.dart";

import "../../extensions/select_item.dart";
import "../../states/providers.dart";
import "../../states/reservation_date_editor.dart";
import "../../states/reservation_slots.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class AddReservationDate extends VegaScreen {
  final bool createMany;
  final DateTime dateOfReservation;
  final ReservationSlot? newDateForSlot;

  const AddReservationDate({
    super.key,
    required this.createMany,
    required this.dateOfReservation,
    this.newDateForSlot,
  });

  @override
  createState() => _AddDateState();
}

class _AddDateState extends VegaScreenState<AddReservationDate> {
  final _formKey = GlobalKey<FormState>();

  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();
  final _durationController = TextEditingController();
  final _pauseController = TextEditingController();
  final _days = [true, true, true, true, true, false, false];
  late TimeOfDay _timeFrom;
  late TimeOfDay _timeTo;
  String _pickedReservationSlotId = "";
  late DateTime _dayFrom;
  late DateTime _dayTo;

  @override
  void initState() {
    super.initState();
    _timeFrom = widget.createMany
        ? const TimeOfDay(hour: 8, minute: 0)
        : TimeOfDay(hour: widget.dateOfReservation.hour, minute: 0);
    _timeTo = widget.createMany
        ? const TimeOfDay(hour: 16, minute: 30)
        : TimeOfDay(hour: widget.dateOfReservation.hour + 1, minute: 0);
    _dayFrom = widget.createMany ? DateTimeExtensions.tomorrow : widget.dateOfReservation;
    _dayTo = widget.createMany ? DateTimeExtensions.tomorrow.addDays(30) : widget.dateOfReservation;
    Future.microtask(() {
      final state = cast<ReservationDateEditorLoaded>(ref.read(reservationDateEditorLogic));
      _timeFromController.text = _formattedTimeFrom(context.languageCode);
      _timeToController.text = _formattedTimeTo(context.languageCode);
      if (state != null) _pickedReservationSlotId = state.slots[0].reservationSlotId;
      _durationController.text =
          widget.newDateForSlot?.duration?.toString() ?? state?.slots[0].duration?.toString() ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    _durationController.dispose();
    _pauseController.dispose();
  }

  @override
  String? getTitle() =>
      widget.createMany ? LangKeys.screenReservationDatesAddTitle.tr() : LangKeys.screenReservationDateAddTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    final key = ref.read(reservationDatesLogic.notifier).reset();
    ref.read(refreshLogic.notifier).mark(key);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildGenerateButton()),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _buildMobileLayout() : _buildDefaultLayout(),
        ),
      ),
    );
  }

  void _listenToLogic(BuildContext context) {
    ref.listen<ReservationDateEditorState>(reservationDateEditorLogic, (previous, next) {
      if (next is ReservationDateEditorFailed) {
        final error = next.error;
        toastCoreError(error);
        Future.delayed(stateRefreshDuration, () => ref.read(reservationDateEditorLogic.notifier).reset());
      } else if (next is ReservationDateEditorSucceed) {
        Future.delayed(stateRefreshDuration, () => ref.read(reservationDateEditorLogic.notifier).reset());
      }
    });
  }

  Widget _buildMobileLayout() {
    final reservationSlots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSlot(reservationSlots),
        const MoleculeItemSpace(),
        _buildDaysField(),
        const MoleculeItemSpace(),
        Row(
          children: [
            Expanded(child: _buildDayFrom()),
            const MoleculeItemHorizontalSpace(),
            Expanded(child: _buildTimeFromField(context)),
          ],
        ),
        const MoleculeItemSpace(),
        Row(
          children: [
            Expanded(child: _buildDayTo()),
            const MoleculeItemHorizontalSpace(),
            Expanded(child: _buildTimeToField(context)),
          ],
        ),
        const MoleculeItemSpace(),
        Row(
          children: [
            Flexible(child: _buildDurationField()),
            const MoleculeItemHorizontalSpace(),
            Flexible(child: _buildPauseField()),
          ],
        ),
        const MoleculeItemSpace(),
        _buildGenerateButton(),
        const MoleculeItemSpace(),
      ],
    );
  }

  Widget _buildDefaultLayout() {
    final reservationSlots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSlot(reservationSlots),
        const MoleculeItemSpace(),
        _buildDaysField(),
        const MoleculeItemSpace(),
        Row(
          children: [
            Expanded(child: _buildDayFrom()),
            const MoleculeItemHorizontalSpace(),
            Expanded(child: _buildTimeFromField(context)),
          ],
        ),
        const MoleculeItemSpace(),
        Row(
          children: [
            Expanded(child: _buildDayTo()),
            const MoleculeItemHorizontalSpace(),
            Expanded(child: _buildTimeToField(context)),
          ],
        ),
        const MoleculeItemSpace(),
        _buildDurationField(),
        const MoleculeItemSpace(),
        _buildPauseField(),
      ],
    );
  }

  Widget _buildSlot(List<ReservationSlot> slots) => MoleculeSingleSelect(
        title: LangKeys.labelReservationSlot.tr(),
        hint: "",
        items: slots.toSelectItems(),
        selectedItem: ((widget.newDateForSlot != null
                    ? slots
                        .firstWhereOrNull((slot) => slot.reservationSlotId == widget.newDateForSlot!.reservationSlotId)
                    : slots[0]) ??
                slots[0])
            .toSelectItem(),
        onChanged: (selectedItem) {
          _pickedReservationSlotId = selectedItem.value;
          _durationController.text =
              (slots.firstWhere((slot) => slot.reservationSlotId == selectedItem.value).duration ??
                      _durationController.text)
                  .toString();
        },
      );

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
              value: _days[index],
              onChanged: widget.createMany ? (value) => setState(() => _days[index] = value ?? false) : null,
            ),
            value.text,
            const MoleculeItemHorizontalSpace(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDayFrom() => MoleculeDatePicker(
        title: LangKeys.labelDateFrom.tr(),
        hint: LangKeys.hintPickDateFrom.tr(),
        initialValue: _dayFrom,
        onChanged: (selectedDate) => _dayFrom = selectedDate,
        enabled: widget.createMany,
      );

  Widget _buildDayTo() => MoleculeDatePicker(
        title: LangKeys.labelDateTo.tr(),
        hint: LangKeys.hintPickDateTo.tr(),
        initialValue: _dayTo,
        onChanged: (selectedDate) => _dayTo = selectedDate,
        enabled: widget.createMany,
      );

  Widget _buildDurationField() => MoleculeInput(
        controller: _durationController,
        inputType: TextInputType.number,
        validator: (val) =>
            isInt(val ?? "", min: 5, max: (60 * 8)) ? null : LangKeys.validationReservationDateDuration.tr(),
        title: LangKeys.labelDuration.tr(),
        suffixText: "min",
      );

  Widget _buildPauseField() => MoleculeInput(
        controller: _pauseController,
        inputType: TextInputType.number,
        validator: (val) => isInt(val ?? "", min: 0, max: 180) ? null : LangKeys.validationReservationDatePause.tr(),
        title: LangKeys.labelDurationPause.tr(),
        suffixText: "min",
      );

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

  Widget _buildGenerateButton() {
    final state = ref.watch(reservationDateEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonGenerate.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () {
        if (!_formKey.currentState!.validate() && _pickedReservationSlotId != "") return;
        ref.read(reservationDateEditorLogic.notifier).createMany(
              reservationSlotId: _pickedReservationSlotId,
              days: widget.createMany ? _days : [true, true, true, true, true, true, true],
              dateFrom: _dayFrom,
              dateTo: _dayTo,
              timeFrom: _timeFrom,
              timeTo: _timeTo,
              duration: tryParseInt(_durationController.text),
              pause: tryParseInt(_pauseController.text),
            );
      },
    );
  }

  String _formattedTimeFrom(String locale) {
    final target = DateTime.now().copyWith(
      hour: _timeFrom.hour,
      minute: _timeFrom.minute,
    );
    return DateFormat.jm(locale).format(target.toLocal());
  }

  String _formattedTimeTo(String locale) {
    final target = DateTime.now().copyWith(
      hour: _timeTo.hour,
      minute: _timeTo.minute,
    );
    return DateFormat.jm(locale).format(target.toLocal());
  }
}

// eof

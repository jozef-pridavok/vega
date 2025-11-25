import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/src/consumer.dart";
import "package:intl/intl.dart";

import "../../extensions/select_item.dart";
import "../../states/providers.dart";
import "../../states/reservation_date_editor.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class RemoveReservationDates extends VegaScreen {
  final DateTime? calendarDayFrom;
  final DateTime? calendarDayTo;
  const RemoveReservationDates({
    super.key,
    this.calendarDayFrom,
    this.calendarDayTo,
  });

  @override
  createState() => _RemoveDatesState();
}

class _RemoveDatesState extends VegaScreenState<RemoveReservationDates> {
  final _formKey = GlobalKey<FormState>();

  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();
  final _days = [true, true, true, true, true, false, false];
  TimeOfDay _timeFrom = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _timeTo = const TimeOfDay(hour: 16, minute: 30);
  String _pickedReservationSlotId = "";
  DateTime _dayFrom = DateTimeExtensions.tomorrow;
  DateTime _dayTo = DateTimeExtensions.tomorrow.addDays(30);
  bool _removeReservedDates = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = cast<ReservationDateEditorLoaded>(ref.read(reservationDateEditorLogic));
      _timeFromController.text = _formattedTimeFrom(context.languageCode);
      _timeToController.text = _formattedTimeTo(context.languageCode);
      if (state != null) {
        _pickedReservationSlotId = state.slots[0].reservationSlotId;
      }
      if (widget.calendarDayFrom != null && widget.calendarDayTo != null) {
        _dayFrom = widget.calendarDayFrom!;
        _dayTo = widget.calendarDayTo!;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationDatesRemoveTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    final key = ref.read(reservationDatesLogic.notifier).reset();
    ref.read(refreshLogic.notifier).mark(key);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildRemoveButton()),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic(context);
    final watchedLogic = cast<ReservationDateEditorLoaded>(ref.watch(reservationDateEditorLogic));
    final reservationSlots = watchedLogic!.slots;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout(reservationSlots) : _defaultLayout(reservationSlots),
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

  // TODO: Mobile layout
  Widget _mobileLayout(List<ReservationSlot> reservationSlots) => Column(
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
          _buildRemoveReservedCheckBox(),
        ],
      );

  Widget _defaultLayout(List<ReservationSlot> reservationSlots) => Column(
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
          _buildRemoveReservedCheckBox(),
        ],
      );

  Widget _buildSlot(List<ReservationSlot> slots) => MoleculeSingleSelect(
        title: LangKeys.labelReservationSlot.tr(),
        hint: "",
        items: slots.toSelectItems(),
        selectedItem: slots[0].toSelectItem(),
        onChanged: (selectedItem) => _pickedReservationSlotId = selectedItem.value,
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
            Checkbox(value: _days[index], onChanged: (value) => setState(() => _days[index] = value ?? false)),
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
        initialValue: widget.calendarDayFrom ?? _dayFrom,
        onChanged: (selectedDate) => _dayFrom = selectedDate,
      );

  Widget _buildDayTo() => MoleculeDatePicker(
        title: LangKeys.labelDateTo.tr(),
        hint: LangKeys.hintPickDateTo.tr(),
        initialValue: widget.calendarDayTo ?? _dayTo,
        onChanged: (selectedDate) => _dayTo = selectedDate,
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

  Widget _buildTimeFromField(BuildContext context) {
    return MoleculeInput(
      controller: _timeFromController,
      readOnly: true,
      validator: (val) => (val?.length ?? 0) > 0 ? null : LangKeys.validationTimeFrom.tr(),
      onTap: () => _selectTimeFrom(
        context,
        timeFrom: _timeFrom,
        onSelected: (newTimeFrom) {
          setState(() {
            _timeFrom = newTimeFrom;
            _timeFromController.text = _formattedTimeFrom(context.languageCode);
          });
        },
      ),
      title: LangKeys.labelTimeFrom.tr(),
    );
  }

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
        onSelected: (newTimeTo) {
          setState(() {
            _timeTo = newTimeTo;
            _timeToController.text = _formattedTimeTo(context.languageCode);
          });
        },
      ),
      title: LangKeys.labelTimeTo.tr(),
    );
  }

  Widget _buildRemoveReservedCheckBox() => Row(
        children: [
          Text(LangKeys.labelRemoveReservedDates.tr()),
          const MoleculeItemHorizontalSpace(),
          Checkbox(
            checkColor: ref.scheme.content,
            fillColor: null,
            value: _removeReservedDates,
            onChanged: (bool? value) => setState(() => _removeReservedDates = value!),
          ),
        ],
      );

  Widget _buildRemoveButton() {
    final state = ref.watch(reservationDateEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonRemove.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () {
        if (!_formKey.currentState!.validate() && _pickedReservationSlotId != "") return;
        ref.read(reservationDateEditorLogic.notifier).removeMany(
              reservationSlotId: _pickedReservationSlotId,
              days: _days,
              dateFrom: _dayFrom,
              dateTo: _dayTo,
              timeFrom: _timeFrom,
              timeTo: _timeTo,
              removeReservedDates: _removeReservedDates,
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

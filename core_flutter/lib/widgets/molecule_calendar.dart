import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:table_calendar/table_calendar.dart";

import "../extensions/widget_ref.dart";
import "../themes/theme.dart";
import "basic.dart";
import "molecule_chip.dart";

class MoleculeMonth extends ConsumerWidget {
  final DateTime focusedDay;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final bool Function(DateTime day)? selectedDayPredicate;
  final bool Function(DateTime day)? enabledDayPredicate;
  //final bool Function(DateTime day)? holidayPredicate;
  final void Function(DateTime day)? onDaySelected;
  final void Function(DateTime day)? onPageChanged;
  final bool weekMode;

  const MoleculeMonth({
    required this.focusedDay,
    this.selectedDayPredicate,
    this.enabledDayPredicate,
    //this.holidayPredicate,
    this.onDaySelected,
    this.onPageChanged,
    this.firstDay,
    this.lastDay,
    this.weekMode = false,
    super.key,
  });

  factory MoleculeMonth.empty() => MoleculeMonth(
        focusedDay: DateTime.now(),
        enabledDayPredicate: (_) => false,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TableCalendar(
      calendarFormat: weekMode ? CalendarFormat.week : CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: AtomStyles.text.copyWith(color: ref.scheme.content),
        titleCentered: true,
        leftChevronIcon: const VegaIcon(name: "arrow_left"),
        leftChevronMargin: EdgeInsets.zero,
        rightChevronIcon: const VegaIcon(name: "arrow_right"),
        rightChevronMargin: EdgeInsets.zero,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: AtomStyles.labelText),
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        isTodayHighlighted: false,
        outsideDaysVisible: false,
        //
        //todayDecoration: BoxDecoration(color: ref.scheme.positive),
        // has something
        defaultTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        defaultDecoration: const BoxDecoration(),
        weekendTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        weekendDecoration: const BoxDecoration(),
        todayTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        todayDecoration: BoxDecoration(
          color: ref.scheme.primary,
          border: Border.fromBorderSide(BorderSide(width: 1, color: ref.scheme.primary)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        /*
        // empty rounded
        selectedTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        selectedDecoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(width: 1, color: ref.scheme.primary)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        */
        // filled rounded
        selectedTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.light),
        selectedDecoration: BoxDecoration(
          color: ref.scheme.primary,
          border: Border.fromBorderSide(BorderSide(width: 1, color: ref.scheme.primary)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),

        /*
        // filled rounded
        holidayTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.light),
        holidayDecoration: BoxDecoration(
          color: ref.scheme.primary,
          border: Border.fromBorderSide(BorderSide(width: 1, color: ref.scheme.primary)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        */
        // empty rounded
        holidayTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        holidayDecoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(width: 1, color: ref.scheme.primary)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),

        //
        disabledTextStyle: AtomStyles.labelText.copyWith(color: ref.scheme.content20),
        //
        rangeStartDecoration: const BoxDecoration(),
        rangeEndDecoration: const BoxDecoration(),
        withinRangeDecoration: const BoxDecoration(),
        outsideDecoration: const BoxDecoration(),
        disabledDecoration: const BoxDecoration(),
        //todayDecoration: const BoxDecoration(),
        markerDecoration: const BoxDecoration(),
      ),
      startingDayOfWeek: StartingDayOfWeek.monday,
      firstDay: firstDay ?? DateTime.utc(2023, 1, 1),
      lastDay: lastDay ?? DateTime.utc(2033, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: selectedDayPredicate,
      enabledDayPredicate: enabledDayPredicate,
      //holidayPredicate: holidayPredicate,
      holidayPredicate: (day) => day.isToday,
      onDaySelected: (selectedDay, focusedDay) => onDaySelected?.call(selectedDay),
      onPageChanged: (focusedDay) => onPageChanged?.call(focusedDay),
    );
  }
}

class MoleculeTime extends ConsumerStatefulWidget {
  final List<TimeOfDay> times;
  final String emptyLabel;
  final void Function(TimeOfDay time)? onTimeSelected;
  final bool Function(TimeOfDay time)? selectedPredicate;

  const MoleculeTime(
      {required this.times, required this.emptyLabel, this.selectedPredicate, this.onTimeSelected, super.key});

  factory MoleculeTime.empty() => const MoleculeTime(times: [], emptyLabel: "");

  @override
  createState() => MoleculeTimeState();
}

class MoleculeTimeState extends ConsumerState<MoleculeTime> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.times.isEmpty
            ? [MoleculeChip(active: false, label: widget.emptyLabel, backgroundColor: ref.scheme.paper)]
            : widget.times
                .map((e) => Padding(
                      padding: const EdgeInsets.only(right: moleculeScreenPadding),
                      child: MoleculeChip(
                        active: widget.selectedPredicate?.call(e) ?? false,
                        label: e.format(context),
                        onTap: () => widget.onTimeSelected?.call(e),
                      ),
                    ))
                .toList(),
      ),
    );
  }
}

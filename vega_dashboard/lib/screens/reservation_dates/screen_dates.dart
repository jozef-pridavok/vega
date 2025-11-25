import "package:calendar_view/calendar_view.dart";
import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:vega_dashboard/screens/reservations/screen_reservations.dart";

import "../../extensions/reservation_date.dart";
import "../../extensions/select_item.dart";
import "../../states/providers.dart";
import "../../states/reservation_dates.dart";
import "../../states/reservation_slots.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../reservation_slots/screen_slots.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";
import "screen_date_add.dart";
import "screen_dates_remove.dart";
import "widget_event.dart";

class ReservationDatesScreen extends VegaScreen {
  final String? reservationId;
  final ReservationSlot? pickedSlot;
  const ReservationDatesScreen({super.showDrawer, this.reservationId, this.pickedSlot, super.key})
      : assert((reservationId == null && pickedSlot == null) ||
            (reservationId != null && pickedSlot == null) ||
            (reservationId == null && pickedSlot != null));

  @override
  createState() => _ReservationDatesState();
}

class _ReservationDatesState extends VegaScreenState<ReservationDatesScreen>
    with SingleTickerProviderStateMixin, LoggerMixin {
  String? _reservationId;
  final List<ReservationSlot> _pickedSlots = [];

  final _eventController = EventController();

  int _calendarMode = 0;
  DateTime _calendarDate = DateTime.now();

  final _weekCalendarKey = GlobalKey<WeekViewState>();
  final _dayCalendarKey = GlobalKey<WeekViewState>();

  @override
  void initState() {
    super.initState();

    _calendarMode = ref.read(layoutLogic).isMobile ? 1 : 0;

    if (widget.reservationId != null)
      _reservationId = widget.reservationId!;
    else if (widget.pickedSlot != null) {
      _pickedSlots.add(widget.pickedSlot!);
      _reservationId = widget.pickedSlot!.reservationId;
    }

    Future.microtask(() {
      if (_reservationId != null) {
        ref.read(activeReservationsSlotLogic.notifier).load(_reservationId!);
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
      } else
        ref.read(activeReservationsLogic.notifier).load();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _eventController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationDatesTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final dates = ref.watch(reservationDatesLogic);
    final slotsState = ref.watch(activeReservationsSlotLogic);
    final slots = cast<ReservationSlotsSucceed>(slotsState)?.slots ?? [];
    final isRefreshing =
        dates.runtimeType == ReservationDatesLoading || slotsState.runtimeType == ReservationSlotsRefreshing;
    return [
      if (!isMobile)
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: _buildReservationPicker(context, hideTitle: true),
          ),
          width: 350,
        ),
      VegaButton(
        icon: AtomIcons.calendar, // 2 - max number of calendar modes
        onPressed: () {
          setState(() => _calendarMode = (_calendarMode + 1) % 2);
          // doesn't work properly
          //_updateCalendar(slots, animate: true);
        },
        disabled: _reservationId == null || slots.isEmpty,
      ),
      VegaButton(
        icon: AtomIcons.plusCircle,
        onPressed: () {
          if (dates is ReservationDatesLoaded) {
            //if (state.reservationSlots.isEmpty) return toastError(LangKeys.toastNoReservationSlot.tr());
            ref.read(reservationDateEditorLogic.notifier).init(slots);
            context.push(AddReservationDate(createMany: true, dateOfReservation: DateTime.now()));
          }
        },
        disabled: _reservationId == null || slots.isEmpty || dates is! ReservationDatesLoaded,
      ),
      VegaButton(
        icon: AtomIcons.minusCircle,
        onPressed: () {
          if (dates is ReservationDatesLoaded) {
            ref.read(reservationDateEditorLogic.notifier).init(slots);
            context.push(RemoveReservationDates());
          }
        },
        disabled: _reservationId == null || slots.isEmpty || dates is! ReservationDatesLoaded,
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeReservationsSlotLogic.notifier).refresh(_reservationId!);
          ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
        },
        isRotating: isRefreshing,
        disabled: _reservationId == null,
      ),
      VegaMenuButton(
        items: [
          _buildSelectAllSlots(context, ref),
          _buildUnselectAllSlots(context, ref),
        ],
        disabled: _reservationId == null || slots.isEmpty,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  void _listenToLogics(BuildContext context) {
    /*
    ref.listen<ReservationsState>(activeReservationsLogic, (previous, next) {
      if (_reservationId == null && next is ReservationsSucceed) {
        _reservationId = next.reservations.first.reservationId;
        setState(() => _reservationId = _reservationId);
        ref.read(activeReservationsSlotLogic.notifier).load(_reservationId!, reload: true);
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
      }
    });
    */
    ref.listen<ReservationSlotsState>(activeReservationsSlotLogic, (previous, next) {
      if (next is ReservationSlotsSucceed && next is! ReservationSlotsRefreshing) {
        _pickedSlots.clear();
        if (_pickedSlots.isEmpty && next.slots.isNotEmpty) _pickedSlots.addAll(next.slots);
      }
    });
    ref.listen<ReservationDatesState>(reservationDatesLogic, (previous, next) {
      if (next is ReservationDatesOperationSucceed) {
        closeWaitDialog(context, ref);
        ref.read(reservationDatesLogic.notifier).afterOperation();
      } else if (next is ReservationDatesOperationFailed) {
        toastError(LangKeys.operationFailed.tr());
        closeWaitDialog(context, ref);
        ref.read(reservationDatesLogic.notifier).afterOperation();
      } else if (next is ReservationDatesLoaded && next is! ReservationDatesOperationInProgress) {
        final slots = cast<ReservationSlotsSucceed>(ref.read(activeReservationsSlotLogic))?.slots ?? [];
        _updateCalendar(slots, animate: next.newData);
      }
    });
    ref.listen<List<String>>(refreshLogic, (previous, next) {
      final key = ref.read(reservationDatesLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
    });
  }

  void _updateCalendar(List<ReservationSlot> slots, {bool animate = false}) {
    final dates = cast<ReservationDatesLoaded>(ref.watch(reservationDatesLogic));
    _eventController.removeWhere((element) => true);
    if (dates == null) return;
    final slots = cast<ReservationSlotsSucceed>(ref.read(activeReservationsSlotLogic))?.slots ?? [];
    for (final slot in slots) {
      if (_pickedSlots.contains(slot)) {
        final eventList = dates.forSlot(slot).toEventList(slot.color.toMaterial());
        _eventController.addAll(eventList);
      }
    }
    if (!animate) return;
    CalendarEventData? minEvent;
    for (final event in _eventController.allEvents) {
      final eventMinutes = event.startTime!.dayMinutes;
      if (minEvent == null || eventMinutes < minEvent.startTime!.dayMinutes) {
        minEvent = event;
      }
    }
    if (minEvent != null) {
      Future.delayed(fastRefreshDuration, () {
        _weekCalendarKey.currentState?.animateTo(
          minEvent!.startTime!.dayMinutes * 2.0 - 32,
          duration: Duration(microseconds: 50),
        );
        _dayCalendarKey.currentState?.animateTo(
          minEvent!.startTime!.dayMinutes * 2.0 - 32,
          duration: Duration(microseconds: 50),
        );
      });
    }
  }

  PopupMenuItem _buildSelectAllSlots(BuildContext context, WidgetRef ref) {
    final dates = ref.watch(reservationDatesLogic);
    final slots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    return PopupMenuItem(
      child: MoleculeItemBasic(title: LangKeys.buttonSelectAll.tr()),
      onTap: () async {
        if (dates is ReservationDatesLoaded) {
          _pickedSlots.clear();
          _pickedSlots.addAll(slots);
          _updateCalendar(slots);
          setState(() {});
        }
      },
    );
  }

  PopupMenuItem _buildUnselectAllSlots(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reservationDatesLogic);
    final slots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    return PopupMenuItem(
      child: MoleculeItemBasic(title: LangKeys.buttonUnselectAll.tr()),
      onTap: () async {
        if (state is ReservationDatesLoaded) {
          _pickedSlots.clear();
          _pickedSlots.add(slots.first);
          _updateCalendar(slots);
          setState(() {});
        }
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    final reservations = ref.watch(activeReservationsLogic);
    if (reservations is ReservationsFailed)
      return StateErrorWidget(
        activeReservationsLogic,
        onReload: () => ref.read(activeReservationsLogic.notifier).load(),
      );
    final slots = ref.watch(activeReservationsSlotLogic);
    if (slots is ReservationSlotsFailed)
      return StateErrorWidget(
        activeReservationsSlotLogic,
        onReload: () => ref.read(activeReservationsSlotLogic.notifier).load(_reservationId!),
      );
    final dates = ref.watch(reservationDatesLogic);
    if (dates is ReservationDatesFailed)
      return StateErrorWidget(
        reservationDatesLogic,
        onReload: () => ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate),
      );
    if (reservations is ReservationsLoading) return CenteredWaitIndicator();
    if (slots is ReservationSlotsLoading) return CenteredWaitIndicator();
    if (reservations is ReservationsSucceed && reservations.reservations.isEmpty) {
      return SimpleErrorWidget(
        icon: AtomIcons.reservation,
        message: LangKeys.labelNoReservations.tr(),
        buttonText: LangKeys.operationDefineReservations.tr(),
        buttonAction: () => context.popPush(const ReservationsScreen()),
      );
    }
    if (slots is ReservationSlotsSucceed && slots.slots.isEmpty && reservations is ReservationsSucceed) {
      final reservation = reservations.reservations.firstWhereOrNull((r) => r.reservationId == _reservationId);
      if (reservation == null) {
        return SimpleErrorWidget(
          icon: AtomIcons.reservation,
          message: LangKeys.operationFailed.tr(),
        );
      }
      return SimpleErrorWidget(
        icon: AtomIcons.slot,
        message: LangKeys.labelNoSlots.tr(),
        buttonText: LangKeys.operationDefineServices.tr(),
        buttonAction: () => context.popPush(ReservationSlotsScreen(reservation)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_reservationId == null)
            SimpleErrorWidget(
              icon: AtomIcons.calendar,
              message: LangKeys.labelPickReservation.tr(),
            ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: moleculeScreenPadding),
              child: _buildReservationPicker(context),
            ),
          if (_reservationId != null) ...[
            _buildSlotChipsState(context),
            Expanded(child: _buildCalendarState(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationPicker(BuildContext context, {bool hideTitle = false}) {
    final reservations = cast<ReservationsSucceed>(ref.watch(activeReservationsLogic))?.reservations ?? [];
    return MoleculeSingleSelect(
      title: hideTitle ? null : LangKeys.labelReservation.tr(),
      hint: LangKeys.labelPickReservation.tr(),
      items: reservations.toSelectItems(),
      selectedItem:
          reservations.firstWhereOrNull((r) => r.reservationId == widget.pickedSlot?.reservationId)?.toSelectItem(),
      onChanged: (selectedItem) {
        setState(() => _reservationId = selectedItem.value);
        ref.read(activeReservationsSlotLogic.notifier).load(_reservationId!, reload: true);
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
      },
    );
  }

  Widget _buildSlotChipsState(BuildContext context) {
    final slots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    if (slots.isEmpty) return const SizedBox();
    return _buildSlotChips(context, slots);
  }

  Widget _buildSlotChips(BuildContext context, List<ReservationSlot> slots) {
    return Padding(
      padding: const EdgeInsets.only(bottom: moleculeScreenPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: vegaScrollPhysic,
        child: Row(
          children: [
            for (final slot in slots) ...{
              MoleculeChip(
                label: slot.name,
                border: Border.all(color: ref.scheme.primary, width: 1),
                backgroundColor: _pickedSlots.contains(slot) ? slot.color.toMaterial() : ref.scheme.paperBold,
                onTap: () {
                  bool changed = false;
                  if (!_pickedSlots.contains(slot)) {
                    _pickedSlots.add(slot);
                    changed = true;
                  } else if (_pickedSlots.length > 1) {
                    _pickedSlots.remove(slot);
                    changed = true;
                  }
                  if (changed) {
                    _updateCalendar(slots);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(width: 16),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarState(BuildContext context) {
    final state = ref.watch(reservationDatesLogic);
    if (state is ReservationDatesLoaded) {
      return IndexedStack(
        index: _calendarMode,
        children: [
          _buildWeekCalendar(context, state),
          _buildDayCalendar(context, state),
          _buildMonthCalendar(context, state),
        ],
      );
    } else if (state is ReservationDatesFailed) {
      return StateErrorWidget(reservationDatesLogic,
          onReload: () => ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate));
    } else if (state is ReservationDatesLoading) {
      return CenteredWaitIndicator();
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget _buildDayCalendar(BuildContext context, ReservationDatesLoaded state) {
    return DayView(
      key: _dayCalendarKey,
      heightPerMinute: 2,
      backgroundColor: ref.scheme.paper,
      dateStringBuilder: (date, {secondaryDate}) => DateFormat.MMMMd().format(date),
      headerStyle: HeaderStyle(
        headerTextStyle: AtomStyles.textBold,
        leftIcon: VegaIcon(name: "arrow_left"),
        rightIcon: VegaIcon(name: "arrow_right"),
        decoration: BoxDecoration(
          color: ref.scheme.paper,
          border: Border(bottom: BorderSide(color: ref.scheme.content20)),
        ),
      ),
      hourIndicatorSettings: HourIndicatorSettings(color: ref.scheme.content20, offset: 8, height: 0),
      timeLineWidth: 50,
      timeLineBuilder: (date) {
        final time = DateFormat.Hm().format(date);
        return Transform.translate(
          offset: const Offset(0, -7.5),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: time.label.alignRight.color(ref.scheme.content20),
          ),
        );
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        if (events.isEmpty) return Container();
        final calendarEvent = events[0];
        return ReservationEvent.full(calendarEvent);
      },
      controller: _eventController,
      initialDay: _calendarDate,
      onPageChange: (date, page) {
        _calendarDate = date; // date.add(const Duration(days: 1));
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
        setState(() {});
      },
      onDateTap: (date) => _onDateTap(date),
      onEventTap: (events, date) => _onEventTap(events, date),
    );
  }

  Widget _buildWeekCalendar(BuildContext context, ReservationDatesLoaded state) {
    return WeekView(
      //eventArranger: SlotEventArranger(slotsCount: _pickedSlots.length),
      key: _weekCalendarKey,
      heightPerMinute: 2,
      backgroundColor: ref.scheme.paper,
      headerStyle: HeaderStyle(
        headerTextStyle: AtomStyles.textBold,
        leftIcon: VegaIcon(name: AtomIcons.arrowLeft),
        rightIcon: VegaIcon(name: AtomIcons.arrowRight),
        decoration: BoxDecoration(
          color: ref.scheme.paper,
          border: Border(bottom: BorderSide(color: ref.scheme.content20)),
        ),
      ),
      headerStringBuilder: (date, {secondaryDate}) {
        final from = DateFormat.MMMMd().format(date);
        final to = secondaryDate != null ? (" - ${DateFormat.MMMMd().format(secondaryDate)}") : "";
        return "$from$to";
      },
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(height: 0),
      hourIndicatorSettings: HourIndicatorSettings(color: ref.scheme.content20, offset: 8, height: 0),
      timeLineWidth: 50,
      timeLineBuilder: (date) {
        final time = DateFormat.Hm().format(date);
        return Transform.translate(
          offset: const Offset(0, -7.5),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: time.label.alignRight.color(ref.scheme.content20),
          ),
        );
      },
      // kustomizácia celého headeru
      //weekPageHeaderBuilder: (startDate, endDate) {
      //  return "ok".text;
      //},
      weekDayBuilder: (date) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateFormat.E().format(date).micro.color(ref.scheme.content),
              DateFormat.Md().format(date).label.color(ref.scheme.content),
            ],
          ),
        );
      },
      weekNumberBuilder: (date) {
        final daysToAdd = DateTime.thursday - date.weekday;
        final thursday =
            daysToAdd > 0 ? date.add(Duration(days: daysToAdd)) : date.subtract(Duration(days: daysToAdd.abs()));
        final weekNumber = (date.difference(DateTime(thursday.year)).inDays / 7).floor() + 1;
        return Center(child: weekNumber.toString().label.color(ref.scheme.content50));
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        if (events.isEmpty) return const SizedBox();
        final calendarEvent = events[0];
        if (_pickedSlots.length < 3) return ReservationEvent.normal(calendarEvent);
        return ReservationEvent.compact(calendarEvent);
      },
      controller: _eventController,
      initialDay: _calendarDate,
      onPageChange: (date, page) {
        _calendarDate = date; // date.add(const Duration(days: 1));
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
        setState(() {});
      },
      onDateTap: (date) => _onDateTap(date),
      onEventTap: (events, date) => _onEventTap(events, date),
    );
  }

  Widget _buildMonthCalendar(BuildContext context, ReservationDatesLoaded state) {
    return MonthView(
      dateStringBuilder: (date, {secondaryDate}) => DateFormat.MMMMd().format(date),
      headerStyle: HeaderStyle(
        headerTextStyle: AtomStyles.textBold,
        leftIcon: VegaIcon(name: "arrow_left"),
        rightIcon: VegaIcon(name: "arrow_right"),
        decoration: BoxDecoration(
          color: ref.scheme.paper,
          border: Border(bottom: BorderSide(color: ref.scheme.content20)),
        ),
      ),
      controller: _eventController,
      onPageChange: (date, page) {
        _calendarDate = date; // date.add(const Duration(days: 1));
        ref.read(reservationDatesLogic.notifier).load(_reservationId!, _calendarDate);
        setState(() {});
      },
      //onDateTap: (date) => _onDateTap(date),
      //onEventTap: (events, date) => _onEventTap(events, date),
    );
  }

  Future<void> _onDateTap(DateTime date) async {
    final dates = cast<ReservationDatesLoaded>(ref.read(reservationDatesLogic));
    if (dates == null)
      return debug(() => "Calendar onDateTap error: Expected state ReservationDatesLoaded, actual state: $dates");
    final slots = cast<ReservationSlotsSucceed>(ref.watch(activeReservationsSlotLogic))?.slots ?? [];
    final Locale currentLocale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat.yMMMMEEEEd(currentLocale.toString());
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  formatter.format(date).h4,
                  const MoleculeItemHorizontalSpace(),
                  "${DateFormat.Hm().format(date)} - ${DateFormat.Hm().format(date.addHours(1))}".h4,
                ],
              ),
              const MoleculeItemSpace(),
              DateMenuItems.add(context, ref, slots, date),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onEventTap(List<CalendarEventData<Object?>> events, DateTime date) async {
    final state = cast<ReservationDatesLoaded>(ref.read(reservationDatesLogic));
    if (state == null)
      return debug(() => "Calendar onEventTap error: Expected state ReservationDatesLoaded, actual state: $state");
    final Locale currentLocale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat.yMMMMEEEEd(currentLocale.toString());
    final timeFormatter = DateFormat.Hm(currentLocale.toString());
    final event = events[0].event as ReservationDate;
    debug(() => "Event tapped: ${event.reservationDateId}");
    final reservedByUserId = event.reservedByUserId;
    final dateInfo = formatter.format(event.dateTimeFrom);
    final timeInfo =
        "${timeFormatter.format(event.dateTimeFrom.toLocal())} - ${timeFormatter.format(event.dateTimeTo.toLocal())}";
    final userInfo =
        (event.userNick?.isNotEmpty ?? false) ? LangKeys.labelReservedBy.tr(args: [event.userNick ?? ""]) : null;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dateInfo.label.alignCenter,
                  const MoleculeItemHorizontalSpace(),
                  timeInfo.h4.alignCenter,
                ],
              ),
              if (userInfo != null) ...[
                const MoleculeItemSpace(),
                userInfo.h4.alignCenter,
              ],
              const MoleculeItemSpace(),
              if (reservedByUserId != null && event.status == ReservationDateStatus.available)
                DateMenuItems.confirm(context, ref, event),
              if (reservedByUserId != null) DateMenuItems.cancel(context, ref, event),
              if (reservedByUserId != null) DateMenuItems.sendMessage(context, ref, event),
              if (reservedByUserId != null) DateMenuItems.openUserData(context, ref, event),
              if (reservedByUserId == null) DateMenuItems.book(context, ref, event),
              if (reservedByUserId == null) DateMenuItems.delete(context, ref, event),
            ],
          ),
        );
      },
    );
  }
}

// eof

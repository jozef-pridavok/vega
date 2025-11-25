import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../screens/screen_app.dart";
import "../../states/providers.dart";
import "../../states/reservation_slots.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "screen_edit_slot.dart";
import "widget_active_slots.dart";
import "widget_archived_slots.dart";

class ReservationSlotsScreen extends VegaScreen {
  final Reservation reservation;
  const ReservationSlotsScreen(this.reservation, {super.key}) : super();

  @override
  createState() => _ReservationSlotsState();
}

class _ReservationSlotsState extends VegaScreenState<ReservationSlotsScreen>
    with SingleTickerProviderStateMixin, LoggerMixin {
  String get _reservationId => widget.reservation.reservationId;
  String get _reservationName => widget.reservation.name;

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationSlotsTitle.tr(args: [_reservationName]);

  @override
  List<Widget>? buildAppBarActions() {
    final activeSlots = ref.watch(activeReservationsSlotLogic);
    final archivedSlots = ref.watch(archivedReservationsSlotLogic);
    final isRefreshing = [activeSlots, archivedSlots].any((state) => state is ReservationSlotsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(reservationSlotEditorLogic.notifier).create(widget.reservation);
          context.push(EditSlotScreen(widget.reservation));
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeReservationsSlotLogic.notifier).refresh(_reservationId);
          ref.read(archivedReservationsSlotLogic.notifier).refresh(_reservationId);
        },
        isRotating: isRefreshing,
      ),
      const MoleculeItemHorizontalSpace(),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                ActiveSlotsWidget(widget.reservation),
                ArchivedSlotsWidget(_reservationId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof

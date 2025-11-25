import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../states/providers.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "screen_reservation_edit.dart";
import "widget_active_reservations.dart";
import "widget_archived_reservations.dart";

class ReservationsScreen extends VegaScreen {
  const ReservationsScreen({super.showDrawer, super.key});

  @override
  createState() => _ReservationsState();
}

class _ReservationsState extends VegaScreenState<ReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
    Future(() => ref.read(activeProgramsLogic.notifier).load());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeReservations = ref.watch(activeReservationsLogic);
    final archivedReservations = ref.watch(archivedReservationsLogic);
    final isRefreshing = [activeReservations, archivedReservations].any((state) => state is ReservationsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(reservationEditorLogic.notifier).create();
          context.push(const EditReservation());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeReservationsLogic.notifier).refresh();
          ref.read(archivedReservationsLogic.notifier).refresh();
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
                ActiveReservationsWidget(),
                ArchivedReservationsWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof

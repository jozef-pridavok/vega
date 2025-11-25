import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/dashboard.dart";
import "../../states/providers.dart";
import "../../states/reservation_for_dashboard.dart";
import "../../strings.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "action.dart";
import "actions_admin.dart";
import "actions_orders.dart";
import "actions_pos.dart";
import "actions_reservation.dart";

class ActionsWidget extends ConsumerWidget {
  const ActionsWidget();

  void _listenReservationForDashboardLogic(BuildContext context, WidgetRef ref) {
    ref.listen<ReservationForDashboardState>(reservationForDashboardLogic, (previous, next) async {
      bool closeDialog = next is ReservationForDashboardFailed;
      if ([
        ReservationForDashboardPhase.confirmed,
        ReservationForDashboardPhase.cancelled,
        ReservationForDashboardPhase.completed,
        ReservationForDashboardPhase.forfeited
      ].contains(next.phase)) {
        toastInfo(ref, LangKeys.operationSuccessful.tr());
        ref.read(dashboardLogic.notifier).refresh();
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ReservationForDashboardFailed) toastCoreError(ref, next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeReservationsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeReservationsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenReservationForDashboardLogic(context, ref);

    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final state = ref.watch(dashboardLogic) as DashboardSucceed;
    final items = <DashboardAction>[];

    if (user.isAdmin) items.addAll(state.getActionsForAdmin(context, ref));

    if (user.isAdmin || user.isReservation) items.addAll(state.getActionsForReservation(context, ref));

    if (user.isAdmin || user.isOrder) items.addAll(state.getActionsForOrders(context, ref));

    if (user.isAdmin || user.isPos) items.addAll(state.getActionsForPos(context, ref));

    final grouped = groupBy(items, (DashboardAction action) => action.type);
    grouped.removeWhere((key, value) => value.isEmpty);
    final sorted = grouped.entries.toList()..sort((a, b) => a.key.index.compareTo(b.key.index));

    final slivers = <Widget>[];

    for (final entry in sorted) {
      final title = entry.key.localizedName;
      final actions = entry.value;

      slivers.add(SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 18),
        child: MoleculeItemTitle(header: title),
      )));

      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final action = actions[index];
            return Padding(
                padding: const EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 12),
                child: switch (action.layout) {
                  DashboardActionLayout.tile => MoleculeActions(
                      icon: action.icon,
                      title: action.title ?? "",
                      label: action.label,
                      actions: action.actions,
                      primaryActionIcon: action.primaryActionIcon,
                      onPrimaryAction: action.onPrimaryAction,
                    ),
                  DashboardActionLayout.info => (action.title ?? "").label.color(ref.scheme.content50).alignRight,
                });
          },
          childCount: actions.length,
        ),
      ));

      slivers.add(SliverToBoxAdapter(child: const MoleculeItemSpace()));
    }

    return PullToRefresh(
      onRefresh: () => ref.read(dashboardLogic.notifier).refresh(),
      child: CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  /*
  @override
  Widget build2(BuildContext context, WidgetRef ref) {
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final state = ref.watch(dashboardLogic) as DashboardSucceed;
    final isMobile = ref.watch(layoutLogic).isMobile;
    final items = <DashboardAction>[];

    if (user.isAdmin) items.addAll(state.getActionsForAdmin(context, ref));

    if (user.isAdmin || user.isReservation) items.addAll(state.getActionsForReservation(context, ref));

    if (user.isAdmin || user.isPos) items.addAll(state.getActionsForPos(context, ref));

    return PullToRefresh(
      onRefresh: () => ref.read(dashboardLogic.notifier).refresh(),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 12),
          child: MoleculeActions(
            icon: items[index].icon,
            title: items[index].title ?? "",
            label: items[index].label,
            actions: items[index].actions,
            primaryActionIcon: items[index].primaryActionIcon,
            onPrimaryAction: items[index].onPrimaryAction,
          ),
        ),
      ),
    );
  }
  */
}

// eof

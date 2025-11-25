import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/reservation_patch.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
// ignore: prefer_double_quotes
import '../../widgets/state_error.dart';
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class ActiveReservationsWidget extends ConsumerStatefulWidget {
  ActiveReservationsWidget({super.key});

  @override
  createState() => _ReservationsWidgetState();
}

class _ReservationsWidgetState extends ConsumerState<ActiveReservationsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeReservationsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeReservationsLogic);
    if (state is ReservationsSucceed)
      return const _GridWidget();
    else if (state is ReservationsFailed)
      return StateErrorWidget(
        activeReservationsLogic,
        onReload: () => ref.read(activeReservationsLogic.notifier).load(),
      );
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnDescription = "description";
  //static bool _reorderInProgress = false;

  void _listenToLogics(BuildContext context, WidgetRef ref) {
    ref.listen<ReservationPatchState>(reservationPatchLogic, (previous, next) async {
      bool closeDialog = next is ReservationPatchFailed;
      if ([ReservationPatchPhase.blocked, ReservationPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(activeReservationsLogic.notifier).updated(next.reservation);
      }
      if ([ReservationPatchPhase.archived].contains(next.phase)) {
        ref.read(activeReservationsLogic.notifier).removed(next.reservation);
        ref.read(archivedReservationsLogic.notifier).added(next.reservation);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ReservationPatchFailed) toastCoreError(ref, next.error);
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
    _listenToLogics(context, ref);
    final succeed = ref.watch(activeReservationsLogic) as ReservationsSucceed;
    final reservations = succeed.reservations;
    return PullToRefresh(
      onRefresh: () => ref.read(activeReservationsLogic.notifier).refresh(),
      child: DataGrid<Reservation>(
        rows: reservations,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
        ],
        onBuildCell: (column, reservation) => _buildCell(context, ref, column, reservation),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
        onReorder: (oldIndex, newIndex) async {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(activeReservationsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Reservation reservation) {
    final isBlocked = reservation.blocked;
    final columnMap = <String, ThemedText>{
      _columnName: reservation.name.text.color(ref.scheme.content),
      _columnDescription: reservation.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Reservation reservation, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: reservation.name,
        items: [
          ReservationMenuItems.defineServices(context, ref, reservation),
          ReservationMenuItems.editReservation(context, ref, reservation),
          ReservationMenuItems.blockReservation(context, ref, reservation),
          ReservationMenuItems.archiveReservation(context, ref, reservation),
        ],
      );
}

// eof

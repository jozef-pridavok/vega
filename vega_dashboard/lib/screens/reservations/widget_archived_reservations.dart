import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class ArchivedReservationsWidget extends ConsumerStatefulWidget {
  ArchivedReservationsWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ArchivedReservationsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archivedReservationsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivedReservationsLogic);
    if (state is ReservationsSucceed)
      return const _GridWidget();
    else if (state is ReservationsFailed)
      return StateErrorWidget(archivedReservationsLogic,
          onReload: () => ref.read(archivedReservationsLogic.notifier).load());
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnDescription = "description";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(archivedReservationsLogic) as ReservationsSucceed;
    final reservations = succeed.reservations;
    return PullToRefresh(
      onRefresh: () => ref.read(archivedReservationsLogic.notifier).refresh(),
      child: DataGrid<Reservation>(
        rows: reservations,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
        ],
        onBuildCell: (column, reservation) => _buildCell(context, ref, column, reservation),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
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

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    TapUpDetails details,
  ) {
    final offset = details.globalPosition;
    showMenu(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      context: context,
      items: [
        PopupMenuItem(child: reservation.name.h3),
        //ReservationMenuItems.defineServices(context, ref, reservation),
        //ReservationMenuItems.editReservation(context, ref, reservation),
        //ReservationMenuItems.blockReservation(context, ref, reservation),
        //ReservationMenuItems.archiveReservation(context, ref, reservation),
      ],
    );
  }
}

// eof

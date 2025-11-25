import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/reservation.dart";
import "../../screens/reservations/screen_reservation_edit.dart";
import "../../states/providers.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../reservation_slots/screen_slots.dart";

extension ReservationRepositoryFilterLogic on ReservationRepositoryFilter {
  static final _map = {
    ReservationRepositoryFilter.active: activeReservationsLogic,
    ReservationRepositoryFilter.archived: archivedReservationsLogic,
  };

  StateNotifierProvider<ReservationsNotifier, ReservationsState> get logic => _map[this]!;
}

class ReservationsWidget extends ConsumerStatefulWidget {
  final ReservationRepositoryFilter filter;
  ReservationsWidget(this.filter, {super.key});

  @override
  createState() => _ReservationsWidgetState();
}

class _ReservationsWidgetState extends ConsumerState<ReservationsWidget> {
  ReservationRepositoryFilter get _filter => widget.filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(_filter.logic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_filter.logic);
    if (state is ReservationsSucceed)
      return _GridWidget(_filter);
    else if (state is ReservationsFailed)
      return StateErrorWidget(_filter.logic, onReload: () => ref.read(_filter.logic.notifier).refresh());
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final ReservationRepositoryFilter filter;

  const _GridWidget(this.filter);

  static const _columnOrder = "#";
  static const _columnName = "name";
  static const _columnDescription = "description";
  static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(filter.logic) as ReservationsSucceed;
    final reservations = succeed.reservations;
    return PullToRefresh(
      onRefresh: () => ref.read(filter.logic.notifier).refresh(),
      child: DataGrid<Reservation>(
        rows: reservations,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
        ],
        onBuildCell: (column, reservation) => _buildCell(context, ref, column, reservation),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
        /*
          onReorder: (oldIndex, newIndex) async {
            if (_reorderInProgress) return toastWarning(ref, LangKeys.toastReorderInProgressTitle.tr());
            _reorderInProgress = true;
            if (oldIndex < newIndex) newIndex -= 1;
            await ref.read(filter.logic.notifier).reorder(oldIndex, newIndex);
            _reorderInProgress = false;
          }
          */
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Reservation reservation) {
    final isBlocked = filter == ReservationRepositoryFilter.active && reservation.blocked;
    final columnMap = <String, ThemedText>{
      _columnOrder: reservation.rank.toString().text.color(ref.scheme.content),
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
    if (filter == ReservationRepositoryFilter.archived) return;
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
        if (filter == ReservationRepositoryFilter.active) ...{
          PopupMenuItem(child: reservation.name.h3),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.operationDefineServices.tr(),
              icon: AtomIcons.card,
              onAction: () {
                context.popPush(ReservationSlotsScreen(reservation));
              },
            ),
          ),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.operationEdit.tr(),
              icon: AtomIcons.edit,
              onAction: () {
                ref.read(reservationEditorLogic.notifier).edit(reservation);
                context.popPush(EditReservation());
              },
            ),
          ),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: reservation.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
              icon: reservation.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
              onAction: () async {
                context.pop();
                if (reservation.blocked) {
                  showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
                  ref.read(reservationPatchLogic.notifier).unblock(reservation);
                } else {
                  showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
                  ref.read(reservationPatchLogic.notifier).block(reservation);
                }
              },
            ),
          ),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.operationArchive.tr(),
              icon: AtomIcons.delete,
              onAction: () {
                context.pop();
                Future.delayed(fastRefreshDuration, () => _askToArchive(context, ref, reservation));
              },
            ),
          ),
        }
      ],
    );
  }

  Future<void> _askToArchive(BuildContext context, WidgetRef ref, Reservation reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [reservation.name]).text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.buttonArchive.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(reservationPatchLogic.notifier).archive(reservation);
    }
  }
}

// eof

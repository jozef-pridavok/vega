import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/reservation_slot_patch.dart";
import "../../states/reservation_slots.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class ActiveSlotsWidget extends ConsumerStatefulWidget {
  final Reservation reservation;
  ActiveSlotsWidget(this.reservation, {super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ActiveSlotsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeReservationsSlotLogic.notifier).load(widget.reservation.reservationId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeReservationsSlotLogic);
    if (state is ReservationSlotsSucceed)
      return _GridWidget(widget.reservation);
    else if (state is ReservationSlotsFailed)
      return StateErrorWidget(
        activeReservationsSlotLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.care : null,
        onReload: () => ref.read(activeReservationsSlotLogic.notifier).refresh(state.reservationId),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final Reservation reservation;
  const _GridWidget(this.reservation);

  static const _columnName = "name";
  static const _columnPrice = "price";
  static const _columnDuration = "duration";
  //static const _columnLocation = "location";

  void _listenToLogics(BuildContext context, WidgetRef ref) {
    ref.listen<ReservationSlotPatchState>(slotPatchLogic, (previous, next) async {
      bool closeDialog = next is ReservationSlotPatchFailed;
      if ([ReservationSlotPatchPhase.blocked, ReservationSlotPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(activeReservationsSlotLogic.notifier).updated(next.slot);
      }
      if ([ReservationSlotPatchPhase.archived].contains(next.phase)) {
        ref.read(activeReservationsSlotLogic.notifier).removed(next.slot);
        ref.read(archivedReservationsSlotLogic.notifier).added(next.slot);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ReservationSlotPatchFailed) toastCoreError(ref, next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeReservationsSlotLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeReservationsSlotLogic.notifier).load(reservation.reservationId, reload: true);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToLogics(context, ref);
    final succeed = ref.watch(activeReservationsSlotLogic) as ReservationSlotsSucceed;
    final reservationSlots = succeed.slots;
    return PullToRefresh(
      onRefresh: () => ref.read(activeReservationsSlotLogic.notifier).refresh(succeed.reservationId),
      child: DataGrid<ReservationSlot>(
        rows: reservationSlots,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnPrice, label: LangKeys.columnPrice.tr()),
          DataGridColumn(name: _columnDuration, label: LangKeys.columnDuration.tr()),
          //DataGridColumn(name: _columnLocation, label: LangKeys.columnLocation.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, reservation, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(activeReservationsSlotLogic.notifier).reorder(reservationSlots[oldIndex], oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ReservationSlot reservationSlot) {
    final isBlocked = reservationSlot.blocked;
    final price = reservationSlot.price;
    final currency = reservationSlot.currency;

    String? locationText = reservationSlot.locationId;
    /*
    if (reservationSlot.eligibleLocations != null) {
      locationText = (reservationSlot.eligibleLocations ?? [])
          .firstWhereOrNull((loc) => loc.value == reservationSlot.locationId)
          ?.label;
    }
    */
    //locationText ?? LangKeys.everywhere.tr();

    if (column == _columnName)
      return MoleculeChip(
        label: reservationSlot.name,
        backgroundColor: reservationSlot.color.toMaterial(),
        style: AtomStyles.labelText.copyWith(
          decoration: reservationSlot.blocked ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      );

    final columnMap = <String, ThemedText>{
      _columnPrice:
          (price != null && currency != null ? currency.formatSymbol(price) : "").text.color(ref.scheme.content),
      _columnDuration: "${reservationSlot.duration}min".text.color(ref.scheme.content),
      //_columnLocation: locationText.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked && column != _columnName ? cell.lineThrough : cell;
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ReservationSlot slot,
    Reservation reservation,
    TapUpDetails details,
  ) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: slot.name,
        items: [
          SlotMenuItems.scheduleDates(context, ref, slot),
          SlotMenuItems.edit(context, ref, slot, reservation),
          SlotMenuItems.block(context, ref, slot),
          SlotMenuItems.archive(context, ref, slot),
        ],
      );
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/reservation_slots.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class ArchivedSlotsWidget extends ConsumerStatefulWidget {
  final String reservationId;
  ArchivedSlotsWidget(this.reservationId, {super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ArchivedSlotsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archivedReservationsSlotLogic.notifier).load(widget.reservationId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivedReservationsSlotLogic);
    if (state is ReservationSlotsSucceed)
      return const _GridWidget();
    else if (state is ReservationSlotsFailed)
      return StateErrorWidget(
        archivedReservationsSlotLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.care : null,
        onReload: () => ref.read(archivedReservationsSlotLogic.notifier).load(state.reservationId),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnPrice = "price";
  static const _columnDuration = "duration";
  //static const _columnLocation = "location";

  Widget _buildSlotName(BuildContext context, ReservationSlot reservationSlot) {
    return MoleculeChip(
      label: reservationSlot.name,
      backgroundColor: !reservationSlot.blocked ? reservationSlot.color.toMaterial() : null,
      active: !reservationSlot.blocked,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(archivedReservationsSlotLogic) as ReservationSlotsSucceed;
    final reservationSlots = succeed.slots;
    return PullToRefresh(
      onRefresh: () => ref.read(archivedReservationsSlotLogic.notifier).refresh(succeed.reservationId),
      child: DataGrid<ReservationSlot>(
        rows: reservationSlots,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnPrice, label: LangKeys.columnPrice.tr()),
          DataGridColumn(name: _columnDuration, label: LangKeys.columnDuration.tr()),
          //DataGridColumn(name: _columnLocation, label: LangKeys.columnLocation.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
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

    final columnMap = <String, Widget>{
      _columnName: _buildSlotName(context, reservationSlot),
      _columnPrice:
          (price != null && currency != null ? currency.formatSymbol(price) : "").text.color(ref.scheme.content),
      _columnDuration: "${reservationSlot.duration} min".text.color(ref.scheme.content),
      //_columnLocation: locationText.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked && column != _columnName ? (cell as ThemedText).lineThrough : cell;
  }
}

// eof

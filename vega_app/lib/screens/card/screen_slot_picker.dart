import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:easy_rich_text/easy_rich_text.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../states/providers.dart";
import "../../states/reservation/reservations.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";

typedef ReservationSlotPickedCallback = void Function(Reservation reservation, ReservationSlot slot);

class SlotPickerScreen extends AppScreen {
  final String clientId;
  final String? filterReservationId;
  final String? selectedSlotId;
  final ReservationSlotPickedCallback onSlotPicked;

  const SlotPickerScreen(
    this.clientId, {
    this.filterReservationId,
    this.selectedSlotId,
    required this.onSlotPicked,
    super.key,
  });

  @override
  createState() => _PickerState();
}

class _PickerState extends AppScreenState<SlotPickerScreen> {
  String get _clientId => widget.clientId;
  String? get _selectedSlotId => widget.selectedSlotId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reservationsLogic(_clientId).notifier).load());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenReservationPicker.tr());

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(reservationsLogic(_clientId));
    if (state is ReservationsSucceed) {
      return _Reservations(
        clientId: _clientId,
        filterReservationId: widget.filterReservationId,
        selectedSlotId: _selectedSlotId,
        onSlotPicked: widget.onSlotPicked,
      );
    } else if (state is ReservationsFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          reservationsLogic(_clientId),
          onReload: () => ref.read(reservationsLogic(_clientId).notifier).reload(),
        ),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _Reservations extends ConsumerStatefulWidget {
  final String clientId;
  final String? filterReservationId;
  final String? selectedSlotId;
  final ReservationSlotPickedCallback onSlotPicked;

  const _Reservations({
    required this.clientId,
    this.filterReservationId,
    required this.selectedSlotId,
    required this.onSlotPicked,
  });

  @override
  createState() => _ReservationsState();
}

class _ReservationsState extends ConsumerState<_Reservations> with SingleTickerProviderStateMixin {
  String get _clientId => widget.clientId;
  String? get _filterReservationId => widget.filterReservationId;
  String? get _selectedSlotId => widget.selectedSlotId;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    final succeed = ref.read(reservationsLogic(_clientId)) as ReservationsSucceed;
    final reservations = succeed.filterReservations(_filterReservationId);
    _controller = TabController(
      length: reservations.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final succeed = ref.watch(reservationsLogic(_clientId)) as ReservationsSucceed;
    final tabs = <Tab>[];
    final pages = <Widget>[];
    final reservations = succeed.filterReservations(_filterReservationId);
    for (final reservation in reservations) {
      tabs.add(Tab(text: reservation.name));
      pages.add(_ReservationPage(
        clientId: _clientId,
        reservation: reservation,
        selectedSlotId: _selectedSlotId,
        onSlotPicked: widget.onSlotPicked,
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MoleculeItemSpace(),
          MoleculeTabs(controller: _controller, tabs: tabs),
          Expanded(child: TabBarView(physics: vegaScrollPhysic, controller: _controller, children: pages)),
        ],
      ),
    );
  }
}

class _ReservationPage extends ConsumerWidget {
  final String clientId;
  final String? selectedSlotId;
  final Reservation reservation;
  final ReservationSlotPickedCallback onSlotPicked;

  const _ReservationPage({
    required this.clientId,
    required this.reservation,
    required this.selectedSlotId,
    required this.onSlotPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(reservationsLogic(clientId).notifier).refresh(),
        child: ListView.builder(
          itemCount: reservation.reservationSlots.length,
          itemBuilder: (context, index) => _buildRow(
            context,
            ref,
            reservation,
            reservation.reservationSlots[index],
            index == reservation.reservationSlots.length - 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, Reservation reservation, ReservationSlot slot, bool isLast) {
    final lang = context.languageCode;
    final currency = slot.currency;
    final price = slot.price;
    final formattedPrice = currency != null && price != null ? currency.formatSymbol(price, lang) : null;
    final discount = slot.discount ?? reservation.discount;
    int? discountedPrice = price != null && discount != null ? (price * (1.0 - (discount / 100.0))).round() : null;
    final formattedDiscount = discount != null ? NumberFormat.percentPattern().format(discount / 100.0) : null;
    final formattedDiscountedPrice = discountedPrice != null ? currency!.formatSymbol(discountedPrice, lang) : null;
    final discountString = formattedDiscount != null && formattedDiscountedPrice != null
        ? LangKeys.labelDiscountWithCredit.tr(
            args: [
              formattedDiscount,
              formattedDiscountedPrice,
            ],
          )
        : null;
    final isSelected = selectedSlotId == slot.reservationSlotId;
    return Column(
      children: [
        MoleculeProduct(
          title: slot.name,
          //label: discountString,
          labelWidget: formattedDiscount != null && formattedDiscountedPrice != null
              ? EasyRichText(
                  discountString ?? "",
                  defaultStyle: AtomStyles.labelText.copyWith(color: ref.scheme.content50),
                  patternList: [
                    EasyRichTextPattern(
                      targetString: [
                        formattedDiscount,
                        formattedDiscountedPrice,
                      ],
                      hasSpecialCharacters: true,
                      style: AtomStyles.labelBoldText,
                    ),
                  ],
                )
              : null,
          content: slot.description,
          value: formattedPrice,
          action: isSelected ? LangKeys.actionSelected.tr() : LangKeys.actionSelect.tr(),
          onAction: () => onSlotPicked(reservation, slot),
          actionActive: isSelected,
        ),
        if (!isLast) ...[
          const MoleculeItemSpace(),
          const MoleculeItemSeparator(),
          const MoleculeItemSpace(),
        ],
      ],
    );
  }
}

// eof

import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/extensions/time_of_day.dart";
import "package:easy_rich_text/easy_rich_text.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:vega_app/screens/card/screen_slot_picker.dart";
import "package:vega_app/screens/screen_app.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/states/reservation/reservation_dates.dart";
import "package:vega_app/states/reservation/reservations.dart";
import "package:vega_app/widgets/status_error.dart";

import "../../states/reservation/user_reservation_editor.dart";
import "../../strings.dart";
import "../../widgets/coupon.dart";
import "widget_summary_reservation.dart";

class EditReservationScreen extends AppScreen {
  // clientId for new reservation, reservation for editing
  final String? clientId;
  final UserReservation? reservation;

  final String? cardId;
  final String? userCardId;
  final String? userCouponId;
  final Coupon? coupon;

  const EditReservationScreen({
    this.reservation,
    this.clientId,
    required this.cardId,
    required this.userCardId,
    this.userCouponId,
    this.coupon,
    super.key,
  }) : assert(clientId != null || reservation != null);

  @override
  createState() => _EditState();
}

class _EditState extends AppScreenState<EditReservationScreen> {
  late String clientId;

  UserReservation? get _reservation => widget.reservation;

  String? get _cardId => widget.cardId;
  String? get _userCardId => widget.userCardId;
  String? get _userCouponId => widget.userCouponId;
  Coupon? get _coupon => widget.coupon;

  @override
  void initState() {
    super.initState();
    assert(_coupon == null || (_coupon?.type == CouponType.reservation && _coupon?.reservation != null));
    clientId = widget.clientId ?? (_reservation!.clientId);
    if (_reservation == null) Future.microtask(() => ref.read(reservationsLogic(clientId).notifier).load());
    final reservation = _reservation ??
        UserReservation.createNew(
          widget.clientId!,
          reservationId: _coupon?.reservation?.reservationId,
          slotId: _coupon?.reservation?.slotId,
        );
    Future.microtask(() => ref.read(reservationEditorLogic.notifier).edit(reservation));
    final slotId = _coupon?.reservation?.slotId;
    if (slotId != null) Future.microtask(() => ref.read(reservationDatesLogic.notifier).load(slotId, IntMonth.now()));
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenNewReservation.tr(),
        cancel: true,
      );

  void _listenToReservationEditor() {
    ref.listen<UserReservationEditorState>(reservationEditorLogic, (previous, next) {
      if (next is UserReservationConfirmed || next is UserReservationCanceled) {
        ref.read(userReservationsLogic(clientId).notifier).refresh();
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(reservationEditorLogic.notifier).reset();
        ref.read(userCardLogic(_userCardId!).notifier).refreshOnBackground();
        context.pop();
      } else if (next is UserReservationFailed) {
        if (next.error == errorNotEnoughPoints) {
          toastError(LangKeys.errorNotEnoughCredit.tr());
        } else {
          toastError(LangKeys.operationFailed.tr());
        }
        delayedStateRefresh(() => ref.read(reservationEditorLogic.notifier).reedit());
      }
      if (next is UserReservationConfirmed) {
        if (_coupon != null && _userCardId != null) {
          ref.read(userCardLogic(_userCardId!).notifier).refresh();
        }
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToReservationEditor();

    final editor = ref.watch(reservationEditorLogic);
    final editing = cast<UserReservationEditing>(editor);

    //final lang = context.languageCode;
    final reservation = editing?.reservation;
    //final currency = reservation?.reservationSlotCurrency;
    //final price = reservation?.reservationSlotPrice;

    return PullToRefresh(
      onRefresh: () => ref.read(reservationsLogic(clientId).notifier).refresh(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_coupon != null) ...[
                CouponWidget(_coupon!),
                const MoleculeItemSpace(),
              ],
              if (_coupon == null) const SizedBox(height: 16),
              LangKeys.screenEditReservationDescription.tr().text,
              const MoleculeItemSpace(),
              _SlotWidget(
                clientId: clientId,
                filterReservationId: _coupon?.reservation?.reservationId,
                disablePicker: _coupon != null && _coupon?.reservation?.slotId != null,
              ),
              const MoleculeItemSpace(),
              _MonthWidget(editing),
              const MoleculeItemSpace(),
              const MoleculeItemSeparator(),
              const MoleculeItemSpace(),
              _TimeWidget(_coupon),
              const MoleculeItemSpace(),
              const _SummaryWidget(),
              const MoleculeItemSpace(),
              //if (currency != null && price != null) ...[
              //  currency.formatSymbol(price, lang).h3.color(ref.scheme.content).alignCenter,
              //  const MoleculeItemSpace(),
              //],
              _ConfirmReservationButton(
                cardId: _cardId,
                userCardId: _userCardId,
                userCouponId: _userCouponId,
                reservation: reservation,
              ),
              const MoleculeItemSpace(),
              /*
              if (hasDiscount) ...[
                const MoleculeItemSpace(),
                const MoleculeItemSeparator(),
                const MoleculeItemSpace(),
                const MoleculeItemSpace(),
                _PayReservationButton(_userCouponId),
                const MoleculeItemSpace(),
              ],
              */
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotWidget extends ConsumerWidget {
  final String clientId;
  final String? filterReservationId;
  final bool disablePicker;

  const _SlotWidget({required this.clientId, this.filterReservationId, this.disablePicker = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = cast<UserReservationEditing>(ref.watch(reservationEditorLogic));
    final reservations = cast<ReservationsSucceed>(ref.watch(reservationsLogic(clientId)));
    final slot =
        reservations?.slots.firstWhereOrNull((e) => e.reservationSlotId == editor?.reservation.reservationSlotId);
    return MoleculeInputStack(
      title: LangKeys.screenReservationServiceLabel.tr(),
      suffixIcon: disablePicker ? null : const VegaIcon(name: AtomIcons.chevronDown),
      over: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => disablePicker || editor == null ? null : _pickSlot(context, ref, editor),
        child: (slot?.name ?? LangKeys.hintReservationService.tr()).label,
      ),
      onTap: () => disablePicker || editor == null ? null : _pickSlot(context, ref, editor),
    );
  }

  void _pickSlot(BuildContext context, WidgetRef ref, UserReservationEditing? editor) {
    if (editor == null) return;
    context.push(SlotPickerScreen(
      clientId,
      filterReservationId: filterReservationId,
      selectedSlotId: editor.reservation.reservationSlotId,
      onSlotPicked: (reservation, slot) {
        ref.read(reservationEditorLogic.notifier).set(reservation: reservation, slot: slot);
        final month = editor.selectedDay?.toIntMonth() ?? IntMonth.now();
        ref.read(reservationDatesLogic.notifier).load(slot.reservationSlotId, month);
        context.pop();
      },
    ));
  }
}

class _MonthWidget extends ConsumerWidget {
  final UserReservationEditing? editing;

  String? get slotId => editing?.reservation.reservationSlotId;
  DateTime? get selectedDay => editing?.selectedDay;

  const _MonthWidget(this.editing);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (slotId?.isEmpty ?? true) return MoleculeMonth.empty();

    final dates = ref.watch(reservationDatesLogic);
    if (dates is ReservationDatesFailed) {
      return StatusErrorWidget(
        reservationDatesLogic,
        onReload: () => ref.read(reservationDatesLogic.notifier).load(
              slotId!,
              selectedDay?.toIntMonth() ?? IntMonth.now(),
            ),
      );
    } else if (dates is ReservationDatesLoading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          MoleculeMonth.empty(),
          const CenteredWaitIndicator(),
        ],
      );
    } else if (dates is! ReservationDatesSucceed) return MoleculeMonth.empty();

    return MoleculeMonth(
      focusedDay: dates.month.toDate(),
      enabledDayPredicate: (day) => dates.byDate(day).isNotEmpty, // || day.isToday,
      selectedDayPredicate: (day) => selectedDay != null && day.isSameDay(selectedDay!),
      onPageChanged: (focusedDay) =>
          ref.read(reservationDatesLogic.notifier).load(slotId!, IntMonth.fromDate(focusedDay)),
      onDaySelected: (day) {
        ref.read(reservationEditorLogic.notifier).selectDay(dates.dates, day);
      },
    );
  }
}

class _TimeWidget extends ConsumerWidget {
  final Coupon? coupon;

  const _TimeWidget(this.coupon);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = cast<UserReservationEditing>(ref.watch(reservationEditorLogic));
    final dates = ref.watch(reservationDatesLogic);

    if (editor == null || editor.reservation.reservationSlotId.isEmpty || dates is! ReservationDatesSucceed)
      return MoleculeTime.empty();

    final selectedDate = editor.selectedDay;
    final selectedTerm = editor.term;

    final times = selectedDate != null
        ? dates
            .byDate(selectedDate)
            .map((e) => TimeOfDay.fromDateTime(e.dateTimeFrom.toLocal()))
            .sorted((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute))
            .toList()
        : <TimeOfDay>[];

    final reservation = coupon?.reservation;
    if (reservation != null) {
      final from = reservation.from;
      final to = reservation.to;
      if (from != null) times.removeWhere((time) => time.toIntDayMinutes() < from);
      if (to != null) times.removeWhere((time) => time.toIntDayMinutes() > to);
    }

    return MoleculeTime(
      times: times,
      selectedPredicate: (time) =>
          selectedDate != null &&
          selectedTerm != null &&
          selectedTerm.dateTimeFrom.isSameDay(selectedDate) &&
          TimeOfDay.fromDateTime(selectedTerm.dateTimeFrom.toLocal()) == time,
      onTimeSelected: (time) => selectedDate != null
          ? ref.read(reservationEditorLogic.notifier).selectTerm(dates.byTerm(selectedDate, time))
          : null,
      emptyLabel: "",
    );
  }
}

class _SummaryWidget extends ConsumerWidget {
  const _SummaryWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = cast<UserReservationEditing>(ref.watch(reservationEditorLogic));
    if (editor == null) return const SizedBox();
    return UserReservationSummaryWidget(reservation: editor.reservation);
  }
}

class _ConfirmReservationButton extends ConsumerWidget {
  final String? cardId;
  final String? userCardId;
  final String? userCouponId;
  final UserReservation? reservation;

  const _ConfirmReservationButton({
    required this.cardId,
    required this.userCardId,
    required this.reservation,
    required this.userCouponId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = cast<UserReservationEditing>(ref.watch(reservationEditorLogic));
    return MoleculeActionButton(
      title: LangKeys.buttonMakeReservation.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: editor?.buttonState ?? MoleculeActionButtonState.idle,
      onPressed: editor != null && editor.term != null ? () => _reserve(context, ref) : null,
    );
  }

  void _reserve(BuildContext context, WidgetRef ref) {
    final hasDiscount = ((reservation?.reservationSlotDiscount ?? reservation?.reservationDiscount) ?? 0) > 0;
    if (!hasDiscount) {
      ref.read(reservationEditorLogic.notifier).confirm(userCouponId);
      return;
    }
    _confirmPayOption(context, ref);
  }

  void _confirmPayOption(BuildContext context, WidgetRef ref) {
    final lang = context.languageCode;

    final currency = reservation?.reservationSlotCurrency;
    final price = reservation?.reservationSlotPrice;
    final formattedPrice = currency != null && price != null ? currency.formatSymbol(price, lang) : null;
    final discount = reservation?.reservationSlotDiscount ?? reservation?.reservationDiscount;
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

    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenNewReservation.tr()),
          const MoleculeItemSpace(),
          EasyRichText(
            discountString ?? "",
            defaultStyle: AtomStyles.text.copyWith(color: ref.scheme.content50),
            patternList: [
              EasyRichTextPattern(
                targetString: [
                  formattedDiscount!,
                  formattedDiscountedPrice!,
                ],
                hasSpecialCharacters: true,
                style: AtomStyles.textBold,
              ),
            ],
          ),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: "${LangKeys.buttonCreditReservation.tr()} - $formattedDiscountedPrice",
                onTap: () {
                  context.pop();
                  ref.read(reservationEditorLogic.notifier).confirm(
                        userCouponId,
                        userCredit: true,
                        cardId: cardId,
                        userCardId: userCardId,
                      );
                },
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: "${LangKeys.buttonMakeReservation.tr()} - $formattedPrice",
                onTap: () {
                  context.pop();
                  ref.read(reservationEditorLogic.notifier).confirm(userCouponId);
                },
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: LangKeys.buttonClose.tr(),
                //color: ref.scheme.negative,
                onTap: () => context.pop(),
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }
}

// eof

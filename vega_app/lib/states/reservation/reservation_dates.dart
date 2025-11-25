import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/reservation/reservation_dates.dart";

@immutable
abstract class ReservationDatesState {
  final String slotId;
  final IntMonth month;
  const ReservationDatesState({required this.slotId, required this.month});
}

class ReservationDatesInitial extends ReservationDatesState {
  const ReservationDatesInitial({required super.slotId, required super.month});
}

class ReservationDatesLoading extends ReservationDatesState {
  const ReservationDatesLoading({required super.slotId, required super.month});
}

class ReservationDatesSucceed extends ReservationDatesState {
  final List<ReservationDate> dates;

  List<ReservationDate> byDate(DateTime date) => dates.where((d) => d.dateTimeFrom.toLocal().isSameDay(date)).toList();

  ReservationDate? byTerm(DateTime date, TimeOfDay term) => dates
      .where((d) => d.dateTimeFrom.toLocal().isSameDay(date))
      .firstWhereOrNull((d) => TimeOfDay.fromDateTime(d.dateTimeFrom.toLocal()) == term);

  const ReservationDatesSucceed({required super.slotId, required super.month, required this.dates});
}

class ReservationDatesFailed extends ReservationDatesState implements FailedState {
  @override
  final CoreError error;
  const ReservationDatesFailed(
    this.error, {
    required super.slotId,
    required super.month,
  });
}

class ReservationDatesNotifier extends StateNotifier<ReservationDatesState> with LoggerMixin {
  final ReservationDatesRepository reservationDatesRepository;

  ReservationDatesNotifier({required this.reservationDatesRepository})
      : super(ReservationDatesInitial(slotId: "", month: IntMonth.now()));

  Future<void> load(String slotId, IntMonth month) async {
    final currentState = cast<ReservationDatesSucceed>(state);

    if (currentState != null && currentState.slotId == slotId && currentState.month == month) {
      debug(() => errorAlreadyLoaded.toString());
      return;
    }

    if (slotId.isEmpty) return debug(() => "Slot is empty");

    if (state is ReservationDatesLoading) {
      return debug(() => errorAlreadyInProgress.toString());
    }

    try {
      state = ReservationDatesLoading(slotId: slotId, month: month);
      final dates = await reservationDatesRepository.readMonth(slotId, month);
      state = ReservationDatesSucceed(slotId: slotId, month: month, dates: dates);
    } on CoreError catch (e) {
      error(e.toString());
      state = ReservationDatesFailed(e, slotId: slotId, month: month);
    } catch (e) {
      error(e.toString());
      state = ReservationDatesFailed(errorUnexpectedException(e), slotId: slotId, month: month);
    }
  }
}

// eof

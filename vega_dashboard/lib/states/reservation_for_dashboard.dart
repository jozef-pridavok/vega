import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../extensions/reservation_for_dashboard.dart";
import "../repositories/reservation_date.dart";

enum ReservationForDashboardPhase {
  initial,
  confirming,
  confirmed,
  canceling,
  cancelled,
  completing,
  completed,
  forfeiting,
  forfeited,
}

class ReservationForDashboardState {
  final ReservationForDashboardPhase phase;
  final ReservationForDashboard reservation;
  ReservationForDashboardState(this.phase, this.reservation);

  factory ReservationForDashboardState.initial() =>
      ReservationForDashboardState(ReservationForDashboardPhase.initial, DataModel.emptyReservationForDashboard());

  factory ReservationForDashboardState.confirming(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.confirming, reservation);
  factory ReservationForDashboardState.confirmed(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.confirmed, reservation);

  factory ReservationForDashboardState.canceling(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.canceling, reservation);
  factory ReservationForDashboardState.cancelled(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.cancelled, reservation);

  factory ReservationForDashboardState.completing(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.completing, reservation);
  factory ReservationForDashboardState.completed(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.completed, reservation);

  factory ReservationForDashboardState.forfeiting(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.forfeiting, reservation);
  factory ReservationForDashboardState.forfeited(ReservationForDashboard reservation) =>
      ReservationForDashboardState(ReservationForDashboardPhase.forfeited, reservation);
}

class ReservationForDashboardFailed extends ReservationForDashboardState implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationForDashboardFailed(this.error, ReservationForDashboardPhase phase, ReservationForDashboard reservation)
      : super(phase, reservation);
}

class ReservationForDashboardNotifier extends StateNotifier<ReservationForDashboardState> with LoggerMixin {
  final ReservationDateRepository dates;

  ReservationForDashboardNotifier({
    required this.dates,
  }) : super(ReservationForDashboardState.initial());

  void reset() => state = ReservationForDashboardState.initial();

  Future<void> confirm(ReservationForDashboard reservation) async {
    final op = ReservationForDashboardPhase.confirming;
    try {
      state = ReservationForDashboardState.confirming(reservation);
      bool confirmed = await dates.confirm(reservation.toReservationDate());
      state = confirmed
          ? ReservationForDashboardState.confirmed(reservation)
          : ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    }
  }

  Future<void> cancel(ReservationForDashboard reservation) async {
    final op = ReservationForDashboardPhase.canceling;
    try {
      state = ReservationForDashboardState.canceling(reservation);
      bool cancelled = await dates.cancel(reservation.toReservationDate());
      state = cancelled
          ? ReservationForDashboardState.cancelled(reservation)
          : ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    }
  }

  Future<void> complete(ReservationForDashboard reservation) async {
    final op = ReservationForDashboardPhase.completing;
    try {
      state = ReservationForDashboardState.completing(reservation);
      bool completed = await dates.complete(reservation.toReservationDate());
      state = completed
          ? ReservationForDashboardState.completed(reservation)
          : ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    }
  }

  Future<void> forfeit(ReservationForDashboard reservation) async {
    final op = ReservationForDashboardPhase.forfeiting;
    try {
      state = ReservationForDashboardState.forfeiting(reservation);
      bool forfeited = await dates.forfeit(reservation.toReservationDate());
      state = forfeited
          ? ReservationForDashboardState.forfeited(reservation)
          : ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationForDashboardFailed(errorFailedToSaveData, op, reservation);
    }
  }
}

// eof

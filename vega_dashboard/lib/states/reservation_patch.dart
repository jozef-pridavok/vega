import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/reservation.dart";

enum ReservationPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
}

class ReservationPatchState {
  final ReservationPatchPhase phase;
  final Reservation reservation;
  ReservationPatchState(this.phase, this.reservation);

  factory ReservationPatchState.initial() =>
      ReservationPatchState(ReservationPatchPhase.initial, DataModel.emptyReservation());

  factory ReservationPatchState.blocking(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.blocking, reservation);
  factory ReservationPatchState.blocked(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.blocked, reservation);

  factory ReservationPatchState.unblocking(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.unblocking, reservation);
  factory ReservationPatchState.unblocked(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.unblocked, reservation);

  factory ReservationPatchState.archiving(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.archiving, reservation);
  factory ReservationPatchState.archived(Reservation reservation) =>
      ReservationPatchState(ReservationPatchPhase.archived, reservation);
}

extension ReservationPatchStateToActionButtonState on ReservationPatchState {
  static const stateMap = {
    ReservationPatchPhase.blocking: MoleculeActionButtonState.loading,
    ReservationPatchPhase.blocked: MoleculeActionButtonState.success,
    ReservationPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ReservationPatchPhase.unblocked: MoleculeActionButtonState.success,
    ReservationPatchPhase.archiving: MoleculeActionButtonState.loading,
    ReservationPatchPhase.archived: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ReservationPatchFailed extends ReservationPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationPatchFailed(this.error, ReservationPatchPhase phase, Reservation reservation) : super(phase, reservation);
}

class ReservationPatchNotifier extends StateNotifier<ReservationPatchState> with LoggerMixin {
  final ReservationRepository reservationRepository;

  ReservationPatchNotifier({
    required this.reservationRepository,
  }) : super(ReservationPatchState.initial());

  void reset() => state = ReservationPatchState.initial();

  Future<void> block(Reservation reservation) async {
    final op = ReservationPatchPhase.blocking;
    try {
      state = ReservationPatchState.blocking(reservation);
      bool blocked = await reservationRepository.block(reservation);
      state = blocked
          ? ReservationPatchState.blocked(reservation.copyWith(blocked: true))
          : ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    }
  }

  Future<void> unblock(Reservation reservation) async {
    final op = ReservationPatchPhase.unblocking;
    try {
      state = ReservationPatchState.unblocking(reservation);
      bool unblocked = await reservationRepository.unblock(reservation);
      state = unblocked
          ? ReservationPatchState.unblocked(reservation.copyWith(blocked: false))
          : ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    }
  }

  Future<void> archive(Reservation reservation) async {
    final op = ReservationPatchPhase.archiving;
    try {
      state = ReservationPatchState.archiving(reservation);
      bool archived = await reservationRepository.archive(reservation);
      state = archived
          ? ReservationPatchState.archived(reservation)
          : ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationPatchFailed(errorFailedToSaveData, op, reservation);
    }
  }
}

// eof

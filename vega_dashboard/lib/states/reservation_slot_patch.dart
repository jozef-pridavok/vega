import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/reservation_slot.dart";

enum ReservationSlotPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  failed,
}

extension ReservationSlotPatchPhaseBool on ReservationSlotPatchPhase {
  bool get isInProgress =>
      this == ReservationSlotPatchPhase.blocking ||
      this == ReservationSlotPatchPhase.unblocking ||
      this == ReservationSlotPatchPhase.archiving;

  bool get isSuccessful =>
      this == ReservationSlotPatchPhase.blocked ||
      this == ReservationSlotPatchPhase.unblocked ||
      this == ReservationSlotPatchPhase.archived;
}

class ReservationSlotPatchState {
  final ReservationSlotPatchPhase phase;
  final ReservationSlot slot;
  ReservationSlotPatchState(this.phase, this.slot);

  factory ReservationSlotPatchState.initial() =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.initial, DataModel.emptyReservationSlot());

  factory ReservationSlotPatchState.blocking(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.blocking, reservationSlot);
  factory ReservationSlotPatchState.blocked(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.blocked, reservationSlot);

  factory ReservationSlotPatchState.unblocking(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.unblocking, reservationSlot);
  factory ReservationSlotPatchState.unblocked(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.unblocked, reservationSlot);

  factory ReservationSlotPatchState.archiving(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.archiving, reservationSlot);
  factory ReservationSlotPatchState.archived(ReservationSlot reservationSlot) =>
      ReservationSlotPatchState(ReservationSlotPatchPhase.archived, reservationSlot);
}

extension ReservationSlotPatchStateToActionButtonState on ReservationSlotPatchState {
  static const stateMap = {
    ReservationSlotPatchPhase.blocking: MoleculeActionButtonState.loading,
    ReservationSlotPatchPhase.blocked: MoleculeActionButtonState.success,
    ReservationSlotPatchPhase.unblocking: MoleculeActionButtonState.loading,
    ReservationSlotPatchPhase.unblocked: MoleculeActionButtonState.success,
    ReservationSlotPatchPhase.archiving: MoleculeActionButtonState.loading,
    ReservationSlotPatchPhase.archived: MoleculeActionButtonState.success,
    ReservationSlotPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class ReservationSlotPatchFailed extends ReservationSlotPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationSlotPatchFailed(this.error, ReservationSlot reservationSlot)
      : super(ReservationSlotPatchPhase.failed, reservationSlot);

  factory ReservationSlotPatchFailed.from(CoreError error, ReservationSlotPatchState state) =>
      ReservationSlotPatchFailed(error, state.slot);
}

class ReservationSlotPatchNotifier extends StateNotifier<ReservationSlotPatchState> with LoggerMixin {
  final ReservationSlotRepository reservationSlotRepository;

  ReservationSlotPatchNotifier({
    required this.reservationSlotRepository,
  }) : super(ReservationSlotPatchState.initial());

  void reset() => state = ReservationSlotPatchState.initial();

  Future<void> block(ReservationSlot reservationSlot) async {
    try {
      state = ReservationSlotPatchState.blocking(reservationSlot);
      bool stopped = await reservationSlotRepository.block(reservationSlot);
      state = stopped
          ? ReservationSlotPatchState.blocked(reservationSlot)
          : ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    }
  }

  Future<void> unblock(ReservationSlot reservationSlot) async {
    try {
      state = ReservationSlotPatchState.unblocking(reservationSlot);
      bool stopped = await reservationSlotRepository.unblock(reservationSlot);
      state = stopped
          ? ReservationSlotPatchState.unblocked(reservationSlot)
          : ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    }
  }

  Future<void> archive(ReservationSlot reservationSlot) async {
    try {
      state = ReservationSlotPatchState.archiving(reservationSlot);
      bool archived = await reservationSlotRepository.archive(reservationSlot);
      state = archived
          ? ReservationSlotPatchState.archived(reservationSlot)
          : ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationSlotPatchFailed(errorFailedToSaveData, reservationSlot);
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/reservation_date.dart";

@immutable
abstract class ReservationDateEditorState {}

extension ReservationDateEditorStateToActionButtonState on ReservationDateEditorState {
  static const stateMap = {
    ReservationDateEditorSaving: MoleculeActionButtonState.loading,
    ReservationDateEditorSucceed: MoleculeActionButtonState.success,
    ReservationDateEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ReservationDateEditorInitial extends ReservationDateEditorState {}

class ReservationDateEditorLoaded extends ReservationDateEditorState {
  final List<ReservationSlot> slots;
  ReservationDateEditorLoaded({required this.slots});
}

class ReservationDateEditorSucceed extends ReservationDateEditorLoaded {
  ReservationDateEditorSucceed({required super.slots});
}

class ReservationDateEditorSaving extends ReservationDateEditorLoaded {
  ReservationDateEditorSaving({required super.slots});
}

class ReservationDateEditorFailed extends ReservationDateEditorLoaded implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationDateEditorFailed(this.error, {required super.slots});
}

class ReservationDateEditorNotifier extends StateNotifier<ReservationDateEditorState> with StateMixin {
  final ReservationDateRepository dateRepository;

  ReservationDateEditorNotifier({required this.dateRepository}) : super(ReservationDateEditorInitial());

  void init(List<ReservationSlot> slots) => state = ReservationDateEditorLoaded(slots: slots);

  void reset() {
    final currentState = expect<ReservationDateEditorLoaded>(state);
    if (currentState == null) return;
    state = ReservationDateEditorLoaded(slots: currentState.slots);
  }

  Future<void> createMany({
    required String reservationSlotId,
    required List<bool> days,
    required DateTime dateFrom,
    required DateTime dateTo,
    required TimeOfDay timeFrom,
    required TimeOfDay timeTo,
    int? duration,
    int? pause,
  }) async {
    final currentState = expect<ReservationDateEditorLoaded>(state);
    if (currentState == null) return;

    final slots = currentState.slots;
    final reservationId = slots.firstWhere((slot) => slot.reservationSlotId == reservationSlotId).reservationId;
    state = ReservationDateEditorSaving(slots: slots);
    try {
      final ok = await dateRepository.createMany(
        reservationId: reservationId,
        reservationSlotId: reservationSlotId,
        days: days,
        dateFrom: dateFrom,
        dateTo: dateTo,
        timeFrom: timeFrom,
        timeTo: timeTo,
        duration: duration,
        pause: pause,
      );
      state = ok
          ? ReservationDateEditorSucceed(slots: slots)
          : ReservationDateEditorFailed(errorFailedToSaveData, slots: slots);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDateEditorFailed(err, slots: slots);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDateEditorFailed(errorFailedToSaveDataEx(ex: ex), slots: slots);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDateEditorFailed(errorFailedToSaveData, slots: slots);
    }
  }

  Future<void> removeMany({
    required String reservationSlotId,
    required List<bool> days,
    required DateTime dateFrom,
    required DateTime dateTo,
    required TimeOfDay timeFrom,
    required TimeOfDay timeTo,
    required bool removeReservedDates,
  }) async {
    final currentState = expect<ReservationDateEditorLoaded>(state);
    if (currentState == null) return;

    final reservationSlots = currentState.slots;
    state = ReservationDateEditorSaving(slots: reservationSlots);
    try {
      final _ = await dateRepository.deleteMany(
        reservationSlotId: reservationSlotId,
        days: days,
        dateFrom: dateFrom,
        dateTo: dateTo,
        timeFrom: timeFrom,
        timeTo: timeTo,
        removeReservedDates: removeReservedDates,
      );
      state = ReservationDateEditorSucceed(slots: reservationSlots);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDateEditorFailed(err, slots: reservationSlots);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDateEditorFailed(errorFailedToSaveDataEx(ex: ex), slots: reservationSlots);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDateEditorFailed(errorFailedToSaveData, slots: reservationSlots);
    }
  }
}

// eof

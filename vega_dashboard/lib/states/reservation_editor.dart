import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/reservation.dart";

@immutable
abstract class ReservationEditorState {}

extension ReservationEditorStateToActionButtonState on ReservationEditorState {
  static const stateMap = {
    ReservationEditorSaving: MoleculeActionButtonState.loading,
    ReservationEditorSucceed: MoleculeActionButtonState.success,
    ReservationEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ReservationEditorInitial extends ReservationEditorState {}

class ReservationEditorEditing extends ReservationEditorState {
  final Reservation reservation;
  final bool isNew;
  ReservationEditorEditing({required this.reservation, this.isNew = false});
}

class ReservationEditorCreated extends ReservationEditorEditing {
  ReservationEditorCreated({required super.reservation, super.isNew = true});
}

class ReservationEditorSaving extends ReservationEditorEditing {
  ReservationEditorSaving({required super.reservation, required super.isNew});
}

class ReservationEditorSucceed extends ReservationEditorSaving {
  ReservationEditorSucceed({required super.reservation, super.isNew = false});
}

class ReservationEditorFailed extends ReservationEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationEditorFailed(this.error, {required super.reservation, required super.isNew});
}

class ReservationEditorNotifier extends StateNotifier<ReservationEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final ReservationRepository reservationRepository;

  ReservationEditorNotifier({
    required this.deviceRepository,
    required this.reservationRepository,
  }) : super(ReservationEditorInitial());

  void reset() => state = ReservationEditorInitial();

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final reservation = DataModel.createReservation(client);
    state = ReservationEditorCreated(reservation: reservation);
  }

  void edit(Reservation reservation) {
    state = ReservationEditorEditing(reservation: reservation);
  }

  void set({
    String? name,
    LoyaltyMode? loyaltyMode,
    String? programId,
    String? description,
    int? discount,
  }) {
    final currentState = expect<ReservationEditorEditing>(state);
    if (currentState == null) return;
    var updatedMeta = currentState.reservation.meta;
    if (discount != null) (updatedMeta ??= {})["discount"] = discount;
    final reservation = currentState.reservation.copyWith(
      name: name ?? currentState.reservation.name,
      loyaltyMode: loyaltyMode ?? currentState.reservation.loyaltyMode,
      programId: programId ?? currentState.reservation.programId,
      description: description ?? currentState.reservation.description,
      meta: updatedMeta,
    );
    if (programId == null) reservation.programId = null;
    state = ReservationEditorEditing(reservation: reservation, isNew: currentState.isNew);
  }

  Future<void> save() async {
    final currentState = expect<ReservationEditorEditing>(state);
    if (currentState == null) return;

    final reservation = currentState.reservation;
    state = ReservationEditorSaving(reservation: reservation, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await reservationRepository.create(reservation)
          : await reservationRepository.update(reservation);
      state = ok
          ? ReservationEditorSucceed(reservation: reservation)
          : ReservationEditorFailed(errorFailedToSaveData, reservation: reservation, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationEditorFailed(err, reservation: reservation, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state =
          ReservationEditorFailed(errorFailedToSaveDataEx(ex: ex), reservation: reservation, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationEditorFailed(errorFailedToSaveData, reservation: reservation, isNew: currentState.isNew);
    }
  }

  void reedit() {
    final (saving) = expect<ReservationEditorSaving>(state);
    if (saving == null) return;
    state = ReservationEditorEditing(
      reservation: saving.reservation,
      isNew: saving.isNew,
    );
  }
}

// eof

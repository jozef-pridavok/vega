import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/reservation_slot.dart";

@immutable
abstract class ReservationSlotEditorState {}

extension ReservationSlotEditorStateToActionButtonState on ReservationSlotEditorState {
  static const stateMap = {
    ReservationSlotEditorSaving: MoleculeActionButtonState.loading,
    ReservationSlotEditorSaved: MoleculeActionButtonState.success,
    ReservationSlotEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ReservationSlotEditorInitial extends ReservationSlotEditorState {}

class ReservationSlotEditorEditing extends ReservationSlotEditorState {
  final ReservationSlot slot;
  final bool isNew;
  ReservationSlotEditorEditing(this.slot, {this.isNew = false});
}

class ReservationSlotEditorSaving extends ReservationSlotEditorEditing {
  ReservationSlotEditorSaving(super.slot, {required super.isNew});
}

class ReservationSlotEditorSaved extends ReservationSlotEditorSaving {
  ReservationSlotEditorSaved(super.slot) : super(isNew: false);
}

class ReservationSlotEditorFailed extends ReservationSlotEditorSaving implements FailedState {
  @override
  final CoreError error;

  @override
  ReservationSlotEditorFailed(this.error, super.slot, {required super.isNew});
}

class ReservationSlotEditorNotifier extends StateNotifier<ReservationSlotEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final ReservationSlotRepository reservationSlotRepository;

  ReservationSlotEditorNotifier({
    required this.deviceRepository,
    required this.reservationSlotRepository,
  }) : super(ReservationSlotEditorInitial());

  void reset() => state = ReservationSlotEditorInitial();

  void create(Reservation reservation) {
    final slot = DataModel.createReservationSlot(reservation);
    state = ReservationSlotEditorEditing(slot, isNew: true);
  }

  void edit(ReservationSlot reservationSlot) {
    state = ReservationSlotEditorEditing(reservationSlot, isNew: false);
  }

  void set({
    String? name,
    int? price,
    Currency? currency,
    int? duration,
    String? locationId,
    Color? color,
    String? description,
    int? discount,
  }) {
    final editing = expect<ReservationSlotEditorEditing>(state);
    if (editing == null) return;
    var updatedMeta = editing.slot.meta;
    if (discount != null) (updatedMeta ??= {})["discount"] = discount;
    final slot = editing.slot.copyWith(
      name: name ?? editing.slot.name,
      price: price ?? editing.slot.price,
      currency: currency ?? editing.slot.currency,
      duration: duration ?? editing.slot.duration,
      locationId: locationId ?? editing.slot.locationId,
      color: color ?? editing.slot.color,
      description: description ?? editing.slot.description,
      meta: updatedMeta,
    );
    state = ReservationSlotEditorEditing(slot, isNew: editing.isNew);
  }

  Future<void> save() async {
    final editing = expect<ReservationSlotEditorEditing>(state);
    if (editing == null) return;

    final slot = editing.slot;
    state = ReservationSlotEditorSaving(slot, isNew: editing.isNew);

    try {
      final ok =
          editing.isNew ? await reservationSlotRepository.create(slot) : await reservationSlotRepository.update(slot);
      state = ok
          ? ReservationSlotEditorSaved(slot)
          : ReservationSlotEditorFailed(errorFailedToSaveData, slot, isNew: editing.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationSlotEditorFailed(err, slot, isNew: editing.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationSlotEditorFailed(errorFailedToSaveDataEx(ex: ex), slot, isNew: editing.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationSlotEditorFailed(errorFailedToSaveData, slot, isNew: editing.isNew);
    }
  }

  void reedit() {
    final (saving) = expect<ReservationSlotEditorSaving>(state);
    if (saving == null) return;
    state = ReservationSlotEditorEditing(saving.slot, isNew: saving.isNew);
  }
}

// eof

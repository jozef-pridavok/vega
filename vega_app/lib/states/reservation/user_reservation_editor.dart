import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/repositories/reservation/user_reservations.dart";

@immutable
abstract class UserReservationEditorState {}

extension UserReservationEditorStateToActionButtonState on UserReservationEditorState {
  static const stateMap = {
    UserReservationEditorSaving: MoleculeActionButtonState.loading,
    UserReservationConfirmed: MoleculeActionButtonState.success,
    UserReservationCanceled: MoleculeActionButtonState.success,
    UserReservationFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class UserReservationEditorInitial extends UserReservationEditorState {}

class UserReservationEditing extends UserReservationEditorState {
  final UserReservation reservation;
  final ReservationDate? term;
  final DateTime? selectedDay;
  UserReservationEditing({required this.reservation, required this.term, required this.selectedDay});

  factory UserReservationEditing.from(
    UserReservationEditing state, {
    UserReservation? reservation,
    ReservationDate? term,
    DateTime? selectedDay,
    bool resetSelectedTerm = false,
  }) =>
      UserReservationEditing(
          reservation: reservation ?? state.reservation,
          term: resetSelectedTerm ? null : term ?? state.term,
          selectedDay: selectedDay ?? state.selectedDay);
}

class UserReservationEditorSaving extends UserReservationEditing {
  UserReservationEditorSaving({required super.reservation, required super.term, required super.selectedDay});

  factory UserReservationEditorSaving.from(UserReservationEditing state) =>
      UserReservationEditorSaving(reservation: state.reservation, term: state.term, selectedDay: state.selectedDay);
}

class UserReservationConfirmed extends UserReservationEditorState {
  final ReservationDate term;
  UserReservationConfirmed({required this.term});
}

class UserReservationCanceled extends UserReservationEditorState {
  final String reservationDateId;
  UserReservationCanceled({required this.reservationDateId});
}

class UserReservationFailed extends UserReservationEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  UserReservationFailed(this.error, {required super.reservation, required super.term, required super.selectedDay});

  factory UserReservationFailed.from(CoreError error, UserReservationEditing state) =>
      UserReservationFailed(error, reservation: state.reservation, term: state.term, selectedDay: state.selectedDay);
}

class UserReservationEditorNotifier extends StateNotifier<UserReservationEditorState> with StateMixin {
  final UserReservationsRepository remoteRepository;

  UserReservationEditorNotifier({required this.remoteRepository}) : super(UserReservationEditorInitial());

  void reset() => state = UserReservationEditorInitial();

  void reedit() {
    final failed = expect<UserReservationFailed>(state);
    if (failed == null) return;
    state = UserReservationEditing.from(
      failed,
      reservation: failed.reservation,
      term: failed.term,
      selectedDay: failed.selectedDay,
    );
  }

  void edit(UserReservation reservation) =>
      state = UserReservationEditing(reservation: reservation, term: null, selectedDay: null);

  void set({Reservation? reservation, ReservationSlot? slot, ReservationDate? date}) {
    final editing = expect<UserReservationEditing>(state);
    if (editing == null) return;
    final userReservation = editing.reservation.copyWith(
      reservation: reservation,
      reservationSlot: slot,
      reservationDate: date,
    );
    state = UserReservationEditing.from(editing, reservation: userReservation);
  }

  void selectDay(List<ReservationDate> dates, DateTime day) {
    final editing = expect<UserReservationEditing>(state);
    if (editing == null) return;
    state = UserReservationEditing.from(editing, resetSelectedTerm: true, selectedDay: day);
  }

  void selectTerm(ReservationDate? term) {
    final editing = expect<UserReservationEditing>(state);
    if (editing == null) return;
    final reservation = editing.reservation.copyWith(reservationDate: term);
    state = UserReservationEditing.from(editing, reservation: reservation, term: term);
  }

  Future<void> confirm(String? userCouponId, {bool userCredit = false, String? cardId, String? userCardId}) async {
    final editing = expect<UserReservationEditing>(state);
    if (editing == null) return;
    final term = editing.term;
    if (term == null) return debug(() => errorBrokenLogic.toString());
    state = UserReservationEditorSaving.from(editing);
    try {
      final ok = await remoteRepository.confirm(
        term.reservationDateId,
        userCouponId: userCouponId,
        useCredit: userCredit,
        cardId: cardId,
        userCardId: userCardId,
      );
      state = ok ? UserReservationConfirmed(term: term) : UserReservationFailed.from(errorFailedToSaveData, editing);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = UserReservationFailed.from(err, editing);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = UserReservationFailed.from(errorFailedToSaveDataEx(ex: ex), editing);
    } catch (e) {
      verbose(() => e.toString());
      state = UserReservationFailed.from(errorFailedToSaveData, editing);
    }
  }

  Future<void> cancel() async {
    final editing = expect<UserReservationEditing>(state);
    if (editing == null) return;
    final reservationDateId = editing.reservation.reservationDateId;
    state = UserReservationEditorSaving.from(editing);
    try {
      final ok = await remoteRepository.cancel(reservationDateId);
      state = ok
          ? UserReservationCanceled(reservationDateId: reservationDateId)
          : UserReservationFailed.from(errorFailedToSaveData, editing);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = UserReservationFailed.from(err, editing);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = UserReservationFailed.from(errorFailedToSaveDataEx(ex: ex), editing);
    } catch (e) {
      verbose(() => e.toString());
      state = UserReservationFailed.from(errorFailedToSaveData, editing);
    }
  }
}

// eof

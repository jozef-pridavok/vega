import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/reservation_date.dart";

import "../repositories/reservation_date.dart";

enum ReservationDateOperation { confirm, cancel, book, delete, swap }

@immutable
abstract class ReservationDatesState {}

class ReservationDatesInitial extends ReservationDatesState {}

class ReservationDatesLoading extends ReservationDatesState {
  final String reservationId;

  ReservationDatesLoading(this.reservationId);
}

class ReservationDatesLoaded extends ReservationDatesState {
  final bool newData;
  final String reservationId;
  final List<ReservationDate> dates;

  ReservationDatesLoaded(this.reservationId, this.dates, {this.newData = true});

  List<ReservationDate> forSlot(ReservationSlot slot) =>
      dates.where((date) => date.reservationSlotId == slot.reservationSlotId).toList();
}

class ReservationDatesOperationInProgress extends ReservationDatesLoaded {
  final ReservationDateOperation operation;

  ReservationDatesOperationInProgress(this.operation, super.reservationId, super.dates);
}

class ReservationDatesOperationSucceed extends ReservationDatesOperationInProgress {
  ReservationDatesOperationSucceed(super.operation, super.reservationId, super.dates);
}

class ReservationDatesOperationFailed extends ReservationDatesOperationInProgress implements FailedState {
  @override
  final CoreError error;

  ReservationDatesOperationFailed(this.error, super.operation, super.reservationId, super.dates);
}

class ReservationDatesFailed extends ReservationDatesState implements FailedState {
  final String reservationId;
  @override
  final CoreError error;
  @override
  ReservationDatesFailed(this.error, this.reservationId);
}

class ReservationDatesNotifier extends StateNotifier<ReservationDatesState> with StateMixin {
  final ReservationDateRepository dateRepository;

  ReservationDatesNotifier({required this.dateRepository}) : super(ReservationDatesInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ReservationDatesInitial();
    return _refreshKey;
  }

  Future<void> load(String reservationId, DateTime dateOfWeek) async {
    state = ReservationDatesLoading(reservationId);
    try {
      final reservationDates = await dateRepository.readAll(reservationId: reservationId, dateOfWeek: dateOfWeek);
      state = ReservationDatesLoaded(reservationId, reservationDates);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ReservationDatesFailed(err, reservationId);
    } on Exception catch (ex) {
      state = ReservationDatesFailed(errorFailedToSaveDataEx(ex: ex), reservationId);
    } catch (e) {
      warning(e.toString());
      state = ReservationDatesFailed(errorFailedToSaveData, reservationId);
    }
  }

  void afterOperation() {
    final loaded = expect<ReservationDatesOperationInProgress>(state);
    if (loaded == null) return;
    state = ReservationDatesLoaded(loaded.reservationId, loaded.dates, newData: false);
  }

  Future<void> confirm(ReservationDate reservationDate) async {
    final loaded = expect<ReservationDatesLoaded>(state);
    if (loaded == null) return;
    final op = ReservationDateOperation.confirm;
    final reservationId = loaded.reservationId;
    var dates = loaded.dates;
    try {
      state = ReservationDatesOperationInProgress(op, reservationId, dates);
      final ok = await dateRepository.confirm(reservationDate);
      if (ok) {
        dates = dates.map((date) {
          if (date.reservationDateId == reservationDate.reservationDateId) {
            return date.copyWith(status: ReservationDateStatus.confirmed);
          }
          return date;
        }).toList();
        state = ReservationDatesOperationSucceed(op, reservationId, dates);
      } else {
        state = ReservationDatesOperationFailed(errorFailedToSaveData, op, reservationId, dates);
      }
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDatesOperationFailed(err, op, reservationId, dates);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: ex), op, reservationId, dates);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: Exception(e)), op, reservationId, dates);
    }
  }

  Future<void> cancel(ReservationDate reservationDate) async {
    final loaded = expect<ReservationDatesLoaded>(state);
    if (loaded == null) return;
    final op = ReservationDateOperation.cancel;
    final reservationId = loaded.reservationId;
    var dates = loaded.dates;
    try {
      state = ReservationDatesOperationInProgress(op, reservationId, dates);
      final ok = await dateRepository.cancel(reservationDate);
      if (ok) {
        dates = dates.map((date) {
          if (date.reservationDateId == reservationDate.reservationDateId) {
            return date.copyWith(status: ReservationDateStatus.available);
          }
          return date;
        }).toList();
        state = ReservationDatesOperationSucceed(op, reservationId, dates);
      } else {
        state = ReservationDatesOperationFailed(errorFailedToSaveData, op, reservationId, dates);
      }
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDatesOperationFailed(err, op, reservationId, dates);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: ex), op, reservationId, dates);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: Exception(e)), op, reservationId, dates);
    }
  }

  Future<void> book(ReservationDate reservationDate, String userId) async {
    final loaded = expect<ReservationDatesLoaded>(state);
    if (loaded == null) return;
    final op = ReservationDateOperation.book;
    final reservationId = loaded.reservationId;
    var dates = loaded.dates;
    try {
      state = ReservationDatesOperationInProgress(op, reservationId, dates);
      final ok = await dateRepository.book(reservationDate, userId);
      if (ok) {
        dates = dates.map((date) {
          if (date.reservationDateId == reservationDate.reservationDateId) {
            return date.copyWith(
              status: ReservationDateStatus.confirmed,
              reservedByUserId: userId,
            );
          }
          return date;
        }).toList();
        state = ReservationDatesOperationSucceed(op, reservationId, dates);
      } else {
        state = ReservationDatesOperationFailed(errorFailedToSaveData, op, reservationId, dates);
      }
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDatesOperationFailed(err, op, reservationId, dates);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: ex), op, reservationId, dates);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: Exception(e)), op, reservationId, dates);
    }
  }

  Future<void> delete(ReservationDate reservationDate) async {
    final loaded = expect<ReservationDatesLoaded>(state);
    if (loaded == null) return;
    final op = ReservationDateOperation.delete;
    final reservationId = loaded.reservationId;
    var dates = loaded.dates;
    try {
      state = ReservationDatesOperationInProgress(op, reservationId, dates);
      final ok = await dateRepository.delete(reservationDate);
      if (ok) {
        dates = dates.where((date) => date.reservationDateId != reservationDate.reservationDateId).toList();
        state = ReservationDatesOperationSucceed(op, reservationId, dates);
      } else {
        state = ReservationDatesOperationFailed(errorFailedToSaveData, op, reservationId, dates);
      }
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDatesOperationFailed(err, op, reservationId, dates);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: ex), op, reservationId, dates);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: Exception(e)), op, reservationId, dates);
    }
  }

  Future<void> swap(ReservationDate date1, ReservationDate date2) async {
    final loaded = expect<ReservationDatesLoaded>(state);
    if (loaded == null) return;
    final op = ReservationDateOperation.swap;
    final reservationId = loaded.reservationId;
    var dates = loaded.dates;
    try {
      state = ReservationDatesOperationInProgress(op, reservationId, dates);
      final ok = await dateRepository.swapDates(date1: date1, date2: date2);
      if (ok) {
        dates = dates.map((date) {
          if (date.reservationDateId == date1.reservationDateId) {
            return date.copyWith(dateTimeFrom: date2.dateTimeFrom, dateTimeTo: date2.dateTimeTo);
          }
          if (date.reservationDateId == date2.reservationDateId) {
            return date.copyWith(dateTimeFrom: date1.dateTimeFrom, dateTimeTo: date1.dateTimeTo);
          }
          return date;
        }).toList();
        state = ReservationDatesOperationSucceed(op, reservationId, dates);
      } else {
        state = ReservationDatesOperationFailed(errorFailedToSaveData, op, reservationId, dates);
      }
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ReservationDatesOperationFailed(err, op, reservationId, dates);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: ex), op, reservationId, dates);
    } catch (e) {
      verbose(() => e.toString());
      state = ReservationDatesOperationFailed(errorFailedToSaveDataEx(ex: Exception(e)), op, reservationId, dates);
    }
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/reservation.dart";

@immutable
abstract class ReservationsState {}

class ReservationsInitial extends ReservationsState {}

class ReservationsLoading extends ReservationsState {}

class ReservationsSucceed extends ReservationsState {
  final List<Reservation> reservations;
  ReservationsSucceed({required this.reservations});
}

class ReservationsRefreshing extends ReservationsSucceed {
  ReservationsRefreshing({required super.reservations});
}

class ReservationsFailed extends ReservationsState implements FailedState {
  @override
  final CoreError error;
  @override
  ReservationsFailed(this.error);
}

class ReservationsNotifier extends StateNotifier<ReservationsState> with StateMixin {
  final ReservationRepositoryFilter filter;
  final ReservationRepository reservationRepository;

  ReservationsNotifier(
    this.filter, {
    required this.reservationRepository,
  }) : super(ReservationsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ReservationsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false, bool resetToSucceedState = false}) async {
    if (!reload && cast<ReservationsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    if (resetToSucceedState) {
      final currentState = cast<ReservationsSucceed>(state)!;
      state = ReservationsSucceed(reservations: currentState.reservations);
      return;
    }
    try {
      if (state is! ReservationsRefreshing) state = ReservationsLoading();
      final reservations = await reservationRepository.readAll(filter: filter);
      state = ReservationsSucceed(reservations: reservations);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ReservationsFailed(err);
    } on Exception catch (ex) {
      state = ReservationsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ReservationsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<ReservationsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ReservationsRefreshing(reservations: succeed.reservations);
    await load(reload: true);
  }

  bool added(Reservation reservation) {
    return next(state, [ReservationsSucceed], () {
      final reservations = cast<ReservationsSucceed>(state)!.reservations;
      final index = reservations.indexWhere((r) => r.reservationId == reservation.reservationId);
      if (index != -1) return false;
      reservations.insert(0, reservation);
      state = ReservationsSucceed(reservations: reservations);
      return true;
    });
  }

  bool updated(Reservation reservation) {
    return next(state, [ReservationsSucceed], () {
      final reservations = cast<ReservationsSucceed>(state)!.reservations;
      final index = reservations.indexWhere((r) => r.reservationId == reservation.reservationId);
      if (index == -1) return false;
      reservations.replaceRange(index, index + 1, [reservation]);
      state = ReservationsSucceed(reservations: reservations);
      return true;
    });
  }

  bool removed(Reservation reservation) {
    return next(state, [ReservationsSucceed], () {
      final reservations = cast<ReservationsSucceed>(state)!.reservations;
      final index = reservations.indexWhere((r) => r.reservationId == reservation.reservationId);
      if (index == -1) return false;
      reservations.removeAt(index);
      state = ReservationsSucceed(reservations: reservations);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<ReservationsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentReservations = succeed.reservations;
      final removedReservation = currentReservations.removeAt(oldIndex);
      currentReservations.insert(newIndex, removedReservation);
      final newReservations = currentReservations
          .map((reservation) => reservation.copyWith(rank: currentReservations.indexOf(reservation)))
          .toList();
      final reordered = await reservationRepository.reorder(newReservations);
      state =
          reordered ? ReservationsSucceed(reservations: newReservations) : ReservationsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ReservationsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ReservationsFailed(errorFailedToSaveData);
    }
  }
}

// eof

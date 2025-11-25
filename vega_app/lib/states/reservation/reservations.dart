import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/reservation/reservations.dart";

@immutable
abstract class ReservationsState {}

class ReservationsInitial extends ReservationsState {}

class ReservationsLoading extends ReservationsState {}

class ReservationsSucceed extends ReservationsState {
  final List<Reservation> reservations;
  final List<ReservationSlot> slots;

  ReservationsSucceed({required this.reservations}) : slots = reservations.expand((r) => r.reservationSlots).toList();

  List<Reservation> filterReservations(String? filterReservationId) {
    if (filterReservationId == null) return reservations;
    return reservations.where((r) => r.reservationId == filterReservationId).toList();
  }
}

class ReservationsRefreshing extends ReservationsSucceed {
  ReservationsRefreshing({required super.reservations});
}

class ReservationsFailed extends ReservationsState implements FailedState {
  @override
  final CoreError error;
  ReservationsFailed(this.error);
}

class ReservationsNotifier extends StateNotifier<ReservationsState> with LoggerMixin {
  final String clientId;
  final ReservationsRepository reservationsRepository;

  ReservationsNotifier(this.clientId, {required this.reservationsRepository}) : super(ReservationsInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<ReservationsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ReservationsRefreshing) state = ReservationsLoading();
      final reservations = await reservationsRepository.readAll(clientId);
      state = ReservationsSucceed(reservations: reservations);
    } on CoreError catch (e) {
      error(e.toString());
      state = ReservationsFailed(e);
    } catch (e) {
      error(e.toString());
      state = ReservationsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! ReservationsSucceed) return;
    final reservations = cast<ReservationsSucceed>(state)!.reservations;
    state = ReservationsRefreshing(reservations: reservations);
    await _load(reload: true);
  }
}

// eof

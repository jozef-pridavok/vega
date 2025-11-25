import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/reservation/user_reservations.dart";

@immutable
abstract class UserReservationsState {}

class UserReservationsInitial extends UserReservationsState {}

class UserReservationsLoading extends UserReservationsState {}

class UserReservationsSucceed extends UserReservationsState {
  final List<UserReservation> reservations;

  UserReservationsSucceed({required this.reservations});
}

class UserReservationsRefreshing extends UserReservationsSucceed {
  UserReservationsRefreshing({required super.reservations});
}

class UserReservationsFailed extends UserReservationsState implements FailedState {
  @override
  final CoreError error;
  UserReservationsFailed(this.error);
}

class UserReservationsNotifier extends StateNotifier<UserReservationsState> with LoggerMixin {
  final String clientId;
  final UserReservationsRepository userReservationsRepository;

  UserReservationsNotifier(this.clientId, {required this.userReservationsRepository})
      : super(UserReservationsInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<UserReservationsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! UserReservationsRefreshing) state = UserReservationsLoading();
      final reservations = await userReservationsRepository.readActive(clientId);
      state = UserReservationsSucceed(reservations: reservations);
    } on CoreError catch (e) {
      error(e.toString());
      state = UserReservationsFailed(e);
    } catch (e) {
      error(e.toString());
      state = UserReservationsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! UserReservationsSucceed) return;
    final reservations = cast<UserReservationsSucceed>(state)!.reservations;
    state = UserReservationsRefreshing(reservations: reservations);
    await _load(reload: true);
  }
}

// eof

import "package:core_flutter/core_dart.dart";

enum ReservationRepositoryFilter {
  active,
  archived,
}

abstract class ReservationRepository {
  Future<List<Reservation>> readAll({ReservationRepositoryFilter filter});
  //Future<List<ActiveReservation>> readActive({int? limit});

  Future<bool> create(Reservation reservation);
  Future<bool> update(Reservation reservation);

  Future<bool> reorder(List<Reservation> reservations);

  Future<bool> archive(Reservation reservation);
  Future<bool> block(Reservation reservation);
  Future<bool> unblock(Reservation reservation);
}

// eof

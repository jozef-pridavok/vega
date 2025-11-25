import "package:core_flutter/core_dart.dart";

abstract class ReservationsRepository {
  Future<List<Reservation>> readAll(String clientId);
}

// eof

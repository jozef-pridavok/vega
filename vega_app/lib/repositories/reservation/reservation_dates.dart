import "package:core_flutter/core_dart.dart";

abstract class ReservationDatesRepository {
  Future<List<ReservationDate>> readMonth(String slotId, IntMonth month);
}

// eof

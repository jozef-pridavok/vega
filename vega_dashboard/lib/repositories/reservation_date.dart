import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";

abstract class ReservationDateRepository {
  Future<List<ReservationDate>> readAll({required String reservationId, required DateTime dateOfWeek});

  Future<bool> createMany({
    required String reservationId,
    required String reservationSlotId,
    required List<bool> days,
    required DateTime dateFrom,
    required DateTime dateTo,
    required TimeOfDay timeFrom,
    required TimeOfDay timeTo,
    int? duration,
    int? pause,
  });

  Future<int> deleteMany({
    required String reservationSlotId,
    required List<bool> days,
    required DateTime dateFrom,
    required DateTime dateTo,
    required TimeOfDay timeFrom,
    required TimeOfDay timeTo,
    required bool removeReservedDates,
  });

  Future<bool> confirm(ReservationDate term);
  Future<bool> cancel(ReservationDate term);
  Future<bool> book(ReservationDate term, String userId);
  Future<bool> delete(ReservationDate term);

  Future<bool> complete(ReservationDate term);
  Future<bool> forfeit(ReservationDate term);

  Future<bool> swapDates({
    required ReservationDate date1,
    required ReservationDate date2,
  });
}

// eof

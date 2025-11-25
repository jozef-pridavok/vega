import "package:core_flutter/core_dart.dart";

extension ReservationForDashboardToReservationDate on ReservationForDashboard {
  ReservationDate toReservationDate() => ReservationDate(
        reservationDateId: reservationDateId,
        reservationId: reservationId,
        reservationSlotId: reservationSlotId,
        status: ReservationDateStatus.available,
        dateTimeFrom: dateTimeFrom,
        dateTimeTo: dateTimeTo,
        reservedByUserId: userId,
      );
}

// eof

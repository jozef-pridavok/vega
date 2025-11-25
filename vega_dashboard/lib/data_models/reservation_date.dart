import "package:core_flutter/core_dart.dart";

extension ReservationDateCopy on ReservationDate {
  ReservationDate copyWith({
    DateTime? dateTimeFrom,
    DateTime? dateTimeTo,
    ReservationDateStatus? status,
    String? reservedByUserId,
    JsonObject? meta,
  }) {
    return ReservationDate(
      reservationDateId: reservationDateId,
      clientId: clientId,
      reservationId: reservationId,
      reservationSlotId: reservationSlotId,
      reservedByUserId: reservedByUserId ?? this.reservedByUserId,
      status: status ?? this.status,
      dateTimeFrom: dateTimeFrom ?? this.dateTimeFrom,
      dateTimeTo: dateTimeTo ?? this.dateTimeTo,
      meta: meta ?? this.meta,
      userNick: userNick,
    );
  }
}

// eof

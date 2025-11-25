import "package:core_dart/core_dart.dart";

enum CouponReservationKeys {
  reservationId,
  slotId,
  from,
  to,
  days,
}

class CouponReservation {
  String? reservationId;
  String? slotId;
  IntDayMinutes? from;
  IntDayMinutes? to;
  List<Day> days;

  CouponReservation({
    this.reservationId,
    this.slotId,
    this.from,
    this.to,
    this.days = const [],
  });

  static const camel = {
    CouponReservationKeys.reservationId: "reservationId",
    CouponReservationKeys.slotId: "slotId",
    CouponReservationKeys.from: "from",
    CouponReservationKeys.to: "to",
    CouponReservationKeys.days: "days",
  };

  static CouponReservation fromMap(Map<String, dynamic> map) {
    final mapper = CouponReservation.camel;
    return CouponReservation(
      reservationId: map[mapper[CouponReservationKeys.reservationId]] as String?,
      slotId: map[mapper[CouponReservationKeys.slotId]] as String?,
      from: tryParseIntDayMinutes(map[mapper[CouponReservationKeys.from]]),
      to: tryParseIntDayMinutes(map[mapper[CouponReservationKeys.to]]),
      days: (map[mapper[CouponReservationKeys.days]] as List<dynamic>?)?.map((e) => DayCode.fromCode(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final mapper = CouponReservation.camel;
    return {
      if (reservationId != null) mapper[CouponReservationKeys.reservationId]!: reservationId,
      if (slotId != null) mapper[CouponReservationKeys.slotId]!: slotId,
      if (from != null) mapper[CouponReservationKeys.from]!: from!.value,
      if (to != null) mapper[CouponReservationKeys.to]!: to!.value,
      if (days.isNotEmpty) mapper[CouponReservationKeys.days]!: days.map((e) => e.code).toList(),
    };
  }
}


// eof

import "package:core_dart/core_dart.dart";

enum ReservationForDashboardKeys {
  reservationId,
  reservationSlotId,
  reservationDateId,
  reservationName,
  slotName,
  dateTimeFrom,
  dateTimeTo,
  userId,
  userNick,
  color,
}

class ReservationForDashboard {
  String reservationId;
  String reservationSlotId;
  String reservationDateId;
  String reservationName;
  String slotName;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  String userId;
  String? userNick;
  Color color;

  ReservationForDashboard({
    required this.reservationId,
    required this.reservationSlotId,
    required this.reservationDateId,
    required this.reservationName,
    required this.slotName,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    required this.userId,
    this.userNick,
    required this.color,
  });

  static const camel = {
    ReservationForDashboardKeys.reservationId: "reservationId",
    ReservationForDashboardKeys.reservationSlotId: "reservationSlotId",
    ReservationForDashboardKeys.reservationDateId: "reservationDateId",
    ReservationForDashboardKeys.reservationName: "reservationName",
    ReservationForDashboardKeys.slotName: "slotName",
    ReservationForDashboardKeys.dateTimeFrom: "dateTimeFrom",
    ReservationForDashboardKeys.dateTimeTo: "dateTimeTo",
    ReservationForDashboardKeys.userId: "userId",
    ReservationForDashboardKeys.userNick: "userNick",
    ReservationForDashboardKeys.color: "color",
  };

  static const snake = {
    ReservationForDashboardKeys.reservationId: "reservation_id",
    ReservationForDashboardKeys.reservationSlotId: "reservation_slot_id",
    ReservationForDashboardKeys.reservationDateId: "reservation_date_id",
    ReservationForDashboardKeys.reservationName: "reservation_name",
    ReservationForDashboardKeys.slotName: "slot_name",
    ReservationForDashboardKeys.dateTimeFrom: "date_time_from",
    ReservationForDashboardKeys.dateTimeTo: "date_time_to",
    ReservationForDashboardKeys.userId: "user_id",
    ReservationForDashboardKeys.userNick: "user_nick",
    ReservationForDashboardKeys.color: "color",
  };

  static ReservationForDashboard fromMap(
    Map<String, dynamic> map,
    Convention convention,
  ) {
    final mapper = convention == Convention.camel ? ReservationForDashboard.camel : ReservationForDashboard.snake;
    return ReservationForDashboard(
      reservationId: map[mapper[ReservationForDashboardKeys.reservationId]] as String,
      reservationSlotId: map[mapper[ReservationForDashboardKeys.reservationSlotId]] as String,
      reservationDateId: map[mapper[ReservationForDashboardKeys.reservationDateId]] as String,
      reservationName: map[mapper[ReservationForDashboardKeys.reservationName]] as String,
      slotName: map[mapper[ReservationForDashboardKeys.slotName]] as String,
      dateTimeFrom: tryParseDateTime(map[mapper[ReservationForDashboardKeys.dateTimeFrom]])!,
      dateTimeTo: tryParseDateTime(map[mapper[ReservationForDashboardKeys.dateTimeTo]])!,
      userId: map[mapper[ReservationForDashboardKeys.userId]] as String,
      userNick: map[mapper[ReservationForDashboardKeys.userNick]] as String?,
      color: Color.fromHexOrNull(map[mapper[ReservationForDashboardKeys.color]] as String?) ?? Palette.white,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ReservationForDashboard.camel : ReservationForDashboard.snake;
    return {
      mapper[ReservationForDashboardKeys.reservationId]!: reservationId,
      mapper[ReservationForDashboardKeys.reservationSlotId]!: reservationSlotId,
      mapper[ReservationForDashboardKeys.reservationDateId]!: reservationDateId,
      mapper[ReservationForDashboardKeys.reservationName]!: reservationName,
      mapper[ReservationForDashboardKeys.slotName]!: slotName,
      mapper[ReservationForDashboardKeys.dateTimeFrom]!: dateTimeFrom.toIso8601String(),
      mapper[ReservationForDashboardKeys.dateTimeTo]!: dateTimeTo.toIso8601String(),
      mapper[ReservationForDashboardKeys.userId]!: userId,
      if (userNick != null) mapper[ReservationForDashboardKeys.userNick]!: userNick,
      mapper[ReservationForDashboardKeys.color]!: color.toHex(),
    };
  }
}


// eof

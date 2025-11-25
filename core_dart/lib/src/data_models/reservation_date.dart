import "../enums/reservation_date_status.dart";
import "../lang.dart";

enum ReservationDateKeys {
  reservationDateId,
  clientId,
  reservationId,
  reservationSlotId,
  reservedByUserId,
  status,
  dateTimeFrom,
  dateTimeTo,
  meta,
  userNick,
}

class ReservationDate {
  String reservationDateId;
  String? clientId;
  String reservationId;
  String reservationSlotId;
  String? reservedByUserId;
  ReservationDateStatus status;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  JsonObject? meta;
  //
  String? userNick;

  ReservationDate({
    required this.reservationDateId,
    this.clientId,
    required this.reservationId,
    required this.reservationSlotId,
    this.reservedByUserId,
    required this.status,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    this.meta,
    //
    this.userNick,
  });

  static const camel = {
    ReservationDateKeys.reservationDateId: "reservationDateId",
    ReservationDateKeys.clientId: "clientId",
    ReservationDateKeys.reservationId: "reservationId",
    ReservationDateKeys.reservationSlotId: "reservationSlotId",
    ReservationDateKeys.reservedByUserId: "reservedByUserId",
    ReservationDateKeys.status: "status",
    ReservationDateKeys.dateTimeFrom: "dateTimeFrom",
    ReservationDateKeys.dateTimeTo: "dateTimeTo",
    ReservationDateKeys.meta: "meta",
    ReservationDateKeys.userNick: "userNick",
  };

  static const snake = {
    ReservationDateKeys.reservationDateId: "reservation_date_id",
    ReservationDateKeys.clientId: "client_id",
    ReservationDateKeys.reservationId: "reservation_id",
    ReservationDateKeys.reservationSlotId: "reservation_slot_id",
    ReservationDateKeys.reservedByUserId: "reserved_by_user_id",
    ReservationDateKeys.status: "status",
    ReservationDateKeys.dateTimeFrom: "date_time_from",
    ReservationDateKeys.dateTimeTo: "date_time_to",
    ReservationDateKeys.meta: "meta",
    ReservationDateKeys.userNick: "user_nick",
  };

  static ReservationDate fromMap(Map<String, dynamic> map, Map<ReservationDateKeys, String> mapper) => ReservationDate(
        reservationDateId: map[mapper[ReservationDateKeys.reservationDateId]] as String,
        clientId: map[mapper[ReservationDateKeys.clientId]] as String?,
        reservationId: map[mapper[ReservationDateKeys.reservationId]] as String,
        reservationSlotId: map[mapper[ReservationDateKeys.reservationSlotId]] as String,
        reservedByUserId: map[mapper[ReservationDateKeys.reservedByUserId]] as String?,
        status: ReservationDateStatusCode.fromCode(map[mapper[ReservationDateKeys.status]] as int),
        dateTimeFrom: tryParseDateTime(map[mapper[ReservationDateKeys.dateTimeFrom]])!,
        dateTimeTo: tryParseDateTime(map[mapper[ReservationDateKeys.dateTimeTo]])!,
        meta: map[mapper[ReservationDateKeys.meta]] as JsonObject?,
        userNick: map[mapper[ReservationDateKeys.userNick]] as String?,
      );

  Map<String, dynamic> toMap(Map<ReservationDateKeys, String> mapper) => {
        mapper[ReservationDateKeys.reservationDateId]!: reservationDateId,
        if (clientId != null) mapper[ReservationDateKeys.clientId]!: clientId,
        mapper[ReservationDateKeys.reservationId]!: reservationId,
        mapper[ReservationDateKeys.reservationSlotId]!: reservationSlotId,
        if (reservedByUserId != null) mapper[ReservationDateKeys.reservedByUserId]!: reservedByUserId,
        mapper[ReservationDateKeys.status]!: status.code,
        mapper[ReservationDateKeys.dateTimeFrom]!: dateTimeFrom.toIso8601String(),
        mapper[ReservationDateKeys.dateTimeTo]!: dateTimeTo.toIso8601String(),
        if (meta != null) mapper[ReservationDateKeys.meta]!: meta,
        if (userNick != null) mapper[ReservationDateKeys.userNick]!: userNick,
      };
}


// eof

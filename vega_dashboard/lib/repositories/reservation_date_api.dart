import "dart:io";

import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";

import "reservation_date.dart";

class ApiReservationDateRepository with LoggerMixin implements ReservationDateRepository {
  @override
  Future<List<ReservationDate>> readAll({required String reservationId, required DateTime dateOfWeek}) async {
    final res = await ApiClient().get("/v1/dashboard/reservation_date/$reservationId/${dateOfWeek.toIso8601String()}");
    final json = await res.handleStatusCodeWithJson();
    final reservationDates = (json?["reservationDates"] as JsonArray?)?.map(
      (e) => ReservationDate.fromMap(e, ReservationDate.camel),
    );
    return reservationDates?.toList() ?? [];
  }

  @override
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
  }) async {
    final int offset = DateTime.now().timeZoneOffset.inHours;
    final res = await ApiClient().post(
      "/v1/dashboard/reservation_date/multiple",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationId]!: reservationId,
        ReservationDate.camel[ReservationDateKeys.reservationSlotId]!: reservationSlotId,
        "dateFrom": dateFrom.toIso8601String(),
        "dateTo": dateTo.toIso8601String(),
        "days": days,
        "timeFromHour": timeFrom.hour + offset * -1,
        "timeFromMinute": timeFrom.minute,
        "timeToHour": timeTo.hour + offset * -1,
        "timeToMinute": timeTo.minute,
        "duration": duration,
        "pause": pause,
      },
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return ((json?["affected"] as int?) ?? 0) > 0;
  }

  @override
  Future<int> deleteMany({
    required String reservationSlotId,
    required List<bool> days,
    required DateTime dateFrom,
    required DateTime dateTo,
    required TimeOfDay timeFrom,
    required TimeOfDay timeTo,
    required bool removeReservedDates,
  }) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/multiple",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationSlotId]!: reservationSlotId,
        "dateFrom": dateFrom.toIso8601String(),
        "dateTo": dateTo.toIso8601String(),
        "days": days,
        "timeFromHour": timeFrom.hour,
        "timeFromMinute": timeFrom.minute,
        "timeToHour": timeTo.hour,
        "timeToMinute": timeTo.minute,
        "removeReservedDates": removeReservedDates,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) ?? 0;
  }

  @override
  Future<bool> confirm(ReservationDate term) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/confirm",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationDateId]!: term.reservationDateId,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> cancel(ReservationDate term) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/cancel",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationDateId]!: term.reservationDateId,
        ReservationDate.camel[ReservationDateKeys.reservedByUserId]!: term.reservedByUserId
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> complete(ReservationDate term) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/complete",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationDateId]!: term.reservationDateId,
        ReservationDate.camel[ReservationDateKeys.reservedByUserId]!: term.reservedByUserId
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> forfeit(ReservationDate term) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/forfeit",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationDateId]!: term.reservationDateId,
        ReservationDate.camel[ReservationDateKeys.reservedByUserId]!: term.reservedByUserId
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> book(ReservationDate term, String userId) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/book",
      data: {
        ReservationDate.camel[ReservationDateKeys.reservationDateId]!: term.reservationDateId,
        ReservationDate.camel[ReservationDateKeys.reservedByUserId]!: userId,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> delete(ReservationDate term) async {
    final res = await ApiClient().delete("/v1/dashboard/reservation_date/${term.reservationDateId}");
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> swapDates({
    required ReservationDate date1,
    required ReservationDate date2,
  }) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_date/swap",
      data: {
        "date1": date1.reservationDateId,
        "date2": date2.reservationDateId,
      },
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 2;
  }
}

// eof

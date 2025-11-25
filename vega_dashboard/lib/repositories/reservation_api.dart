import "dart:io";

import "package:core_flutter/core_dart.dart";

import "reservation.dart";

extension _ReservationRepositoryFilterCode on ReservationRepositoryFilter {
  static final _codeMap = {
    ReservationRepositoryFilter.active: 1,
    ReservationRepositoryFilter.archived: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiReservationRepository with LoggerMixin implements ReservationRepository {
  @override
  Future<List<Reservation>> readAll({ReservationRepositoryFilter filter = ReservationRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/reservation/", params: {"filter": filter.code});
    final json = await res.handleStatusCodeWithJson();
    return (json?["reservations"] as JsonArray?)
            ?.map((e) => Reservation.fromMap(e, Reservation.camel, reservationSlotsMap: e))
            .toList() ??
        [];
  }

  /*
  @override
  Future<List<ActiveReservation>> readActive({int? limit}) async {
    final res = await ApiClient().get("/v1/dashboard/reservation/confirmation", params: {"limit": limit});
    final json = await res.handleStatusCodeWithJson();
    return (json?["activeReservations"] as JsonArray?)
            ?.map((e) => ActiveReservation.fromMap(e, Convention.camel))
            .toList() ??
        [];
  }
  */

  @override
  Future<bool> create(Reservation reservation) async {
    final res = await ApiClient().post(
      "/v1/dashboard/reservation/${reservation.reservationId}",
      data: reservation.toMap(Reservation.camel),
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Reservation reservation) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation/${reservation.reservationId}",
      data: reservation.toMap(Reservation.camel),
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> reorder(List<Reservation> reservations) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation/reorder",
      data: {"reorder": reservations.map((e) => e.reservationId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == reservations.length;
  }

  Future<bool> _patch(Reservation reservation, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/reservation/${reservation.reservationId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> block(Reservation reservation) => _patch(reservation, {"blocked": true});

  @override
  Future<bool> unblock(Reservation reservation) => _patch(reservation, {"blocked": false});

  @override
  Future<bool> archive(Reservation reservation) => _patch(reservation, {"archived": true});
}

// eof

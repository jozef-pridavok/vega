import "dart:io";

import "package:core_flutter/core_dart.dart";

import "reservations.dart";

class ApiReservationsRepository implements ReservationsRepository {
  ApiReservationsRepository();

  @override
  Future<List<Reservation>> readAll(String clientId) async {
    final res = await ApiClient().get("/v1/reservation/client/$clientId");

    switch (res.statusCode) {
      case -1:
        return Future.error(errorConnectionTimeout);
      case HttpStatus.noContent:
        return [];
      // cache is not supported by server
      //case HttpStatus.alreadyReported:
      //  return null;
      case HttpStatus.ok:
        break;
      default:
        return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));
    }

    final json = res.json!;
    final reservations = json["reservations"] as JsonArray;
    return reservations.map((e) => Reservation.fromMap(e, Reservation.camel, reservationSlotsMap: e)).toList();
  }
}

// eof

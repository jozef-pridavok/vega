import "dart:io";

import "package:core_flutter/core_dart.dart";

import "reservation_dates.dart";

class ApiReservationDatesRepository implements ReservationDatesRepository {
  ApiReservationDatesRepository();

  @override
  Future<List<ReservationDate>> readMonth(String slotId, IntMonth month) async {
    final res = await ApiClient().get("/v1/reservation/slot/$slotId/${month.value}");

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
    final dates = json["dates"] as JsonArray;
    return dates.map((e) => ReservationDate.fromMap(e, ReservationDate.camel)).toList();
  }
}

// eof

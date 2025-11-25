import "dart:io";

import "package:core_flutter/core_dart.dart";

import "user_reservations.dart";

class ApiUserReservationsRepository implements UserReservationsRepository {
  ApiUserReservationsRepository();

  @override
  Future<List<UserReservation>> readActive(String clientId) async {
    final res = await ApiClient().get("/v1/reservation/active/$clientId");

    final json = (await res.handleStatusCodeWithJson());

    // cached - return null
    if (json == null) return [];

    if (json.isEmpty) return [];

    final reservations = json["reservations"] as JsonArray;
    return reservations.map((e) => UserReservation.fromMap(e, UserReservation.camel)).toList();

    /*
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
    return reservations.map((e) => UserReservation.fromMap(e, UserReservation.camel)).toList();
    */
  }

  Future<bool> _patch(String reservationDateId, Map<String, dynamic> data) async {
    final path = "/v1/reservation/$reservationDateId";
    final res = await ApiClient().patch(path, data: data);

    final statusCode = res.statusCode;

    if (statusCode == -1) return Future.error(errorConnectionTimeout);

    if (statusCode != HttpStatus.accepted)
      return Future.error(CoreError(code: res.appCode, message: res.message ?? res.toString(), innerException: res));

    return (res.json!["affected"] as int) == 1;
  }

  @override
  Future<bool> confirm(
    String reservationDateId, {
    String? userCouponId,
    bool useCredit = false,
    String? cardId,
    String? userCardId,
  }) =>
      _patch(reservationDateId, {
        "confirm": true,
        if (useCredit) "useCredit": true,
        if (useCredit) "cardId": cardId,
        if (useCredit) "userCardId": userCardId,
        if (userCouponId != null) "userCouponId": userCouponId,
      });

  @override
  Future<bool> cancel(String reservationDateId) => _patch(reservationDateId, {"confirm": false});
}

// eof

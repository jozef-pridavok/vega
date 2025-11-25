import "package:core_flutter/core_dart.dart";

abstract class UserReservationsRepository {
  Future<List<UserReservation>> readActive(String clientId);
  Future<bool> confirm(
    String reservationDateId, {
    String? userCouponId,
    bool useCredit,
    String? cardId,
    String? userCardId,
  });
  Future<bool> cancel(String reservationDateId);
}

// eof

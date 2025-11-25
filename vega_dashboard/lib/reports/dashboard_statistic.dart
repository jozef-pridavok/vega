import "package:core_flutter/core_dart.dart";

abstract class DashboardStatistic {
  static const reportId = "808b5f34-8395-4141-8dd3-500a9cd70268";

  static const totalUsers = "totalUsers";
  static const totalCards = "totalCards";
  static const newUsers = "newUsers";
  static const activeCards = "activeCards";
  static const newCards = "newCards";
  static const unconfirmedReservations = "unconfirmedReservations";
  static const confirmedReservations = "confirmedReservations";
  static const completedReservations = "completedReservations";
  static const forfeitedReservations = "forfeitedReservations";

  static DateTime? firstDate;

  static ClientReportSet report() {
    firstDate = DateTimeExtensions.startOfThisWeek.subtract(Duration(days: 21));
    final params = {"from": firstDate!.toIntDate().value, "days": 28};
    return ClientReportSet([
      (ClientReportType.totalUsers, totalUsers, null),
      (ClientReportType.newUsers, newUsers, params),
      (ClientReportType.totalCards, totalCards, null),
      (ClientReportType.activeCards, activeCards, params),
      (ClientReportType.newCards, newCards, params),
      (
        ClientReportType.reservationDates,
        unconfirmedReservations,
        {
          ...params,
          ...{"status": ReservationDateStatus.available.code},
        }
      ),
      (
        ClientReportType.reservationDates,
        confirmedReservations,
        {
          ...params,
          ...{"status": ReservationDateStatus.confirmed.code},
        }
      ),
      (
        ClientReportType.reservationDates,
        completedReservations,
        {
          ...params,
          ...{"status": ReservationDateStatus.completed.code},
        }
      ),
      (
        ClientReportType.reservationDates,
        forfeitedReservations,
        {
          ...params,
          ...{"status": ReservationDateStatus.forfeited.code},
        }
      ),
    ]);
  }
}

// eof

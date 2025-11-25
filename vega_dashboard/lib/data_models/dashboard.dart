import "package:core_flutter/core_dart.dart";

class Dashboard {
  final IntDate? license;
  final List<Card> cards;
  final List<Program> programs;
  final List<Coupon> coupons;

  final List<ReservationForDashboard> reservationsForConfirmation;
  final List<ReservationForDashboard> reservationsForFinalization;

  final List<OrderForDashboard> ordersForAcceptance;
  final List<OrderForDashboard> ordersForFinalization;

  Dashboard({
    this.license,
    required this.cards,
    required this.programs,
    required this.coupons,
    required this.reservationsForConfirmation,
    required this.reservationsForFinalization,
    required this.ordersForAcceptance,
    required this.ordersForFinalization,
  });

  factory Dashboard.empty() => Dashboard(
        cards: [],
        programs: [],
        coupons: [],
        reservationsForConfirmation: [],
        reservationsForFinalization: [],
        ordersForAcceptance: [],
        ordersForFinalization: [],
      );
}

// eof

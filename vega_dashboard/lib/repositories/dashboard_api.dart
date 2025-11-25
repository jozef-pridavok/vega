import "dart:async";

import "package:core_flutter/core_dart.dart";

import "../data_models/dashboard.dart";
import "dashboard.dart";

class ApiDashboardRepository with LoggerMixin implements DashboardRepository {
  @override
  Future<Dashboard> read() async {
    final res = await ApiClient().get("/v1/dashboard/");

    final json = await res.handleStatusCodeWithJson();

    final license = IntDate.parseInt(json?["license"] as int?);
    final cards = (json?["cards"] as JsonArray?)?.map((e) => Card.fromMap(e, Convention.camel)).toList() ?? [];
    final programs = (json?["programs"] as JsonArray?)?.map((e) => Program.fromMap(e, Convention.camel)).toList() ?? [];
    final coupons = (json?["coupons"] as JsonArray?)?.map((e) => Coupon.fromMap(e, Convention.camel)).toList() ?? [];

    final reservationsForConfirmation = (json?["reservationsForConfirmation"] as JsonArray?)
            ?.map((e) => ReservationForDashboard.fromMap(e, Convention.camel))
            .toList() ??
        [];
    final reservationsForFinalization = (json?["reservationsForFinalization"] as JsonArray?)
            ?.map((e) => ReservationForDashboard.fromMap(e, Convention.camel))
            .toList() ??
        [];

    final ordersForAcceptance = (json?["ordersForAcceptance"] as JsonArray?)
            ?.map((e) => OrderForDashboard.fromMap(e, Convention.camel))
            .toList() ??
        [];

    final ordersForFinalization = (json?["ordersForFinalization"] as JsonArray?)
            ?.map((e) => OrderForDashboard.fromMap(e, Convention.camel))
            .toList() ??
        [];

    return Dashboard(
      license: license,
      cards: cards,
      programs: programs,
      coupons: coupons,
      reservationsForConfirmation: reservationsForConfirmation,
      reservationsForFinalization: reservationsForFinalization,
      ordersForAcceptance: ordersForAcceptance,
      ordersForFinalization: ordersForFinalization,
    );
  }

  @override
  Future<ClientReportSetData> clientReport(ClientReportSet set) async {
    final res = await ApiClient().post("/v1/dashboard/client_report", data: set.toJson());
    final json = await res.handleStatusCodeWithJson();
    return ClientReportSetData.fromJson(json ?? {});
  }
}

// eof

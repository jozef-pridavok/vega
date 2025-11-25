import "package:core_dart/core_dart.dart";

import "../../cache.dart";
import "../../data_access_objects/dashboard/dashboard_analytics.dart";
import "../../data_models/session.dart";
import "client_report.dart";

extension ClientReportTypeExec on ClientReportType {
  Future<(String, dynamic)> exec(String clientId, DashboardAnalyticsDAO analytics, JsonObject params) async {
    if (isNotValidParams(params)) return throw "Invalid params! Available params: ($paramsDefinition)";
    switch (this) {
      case ClientReportType.totalUsers:
        return ("count", await analytics.countTotalUsers(clientId));
      case ClientReportType.newUsers:
        return (
          "array",
          await analytics.countNewUsers(clientId, getParam<IntDate>(params, "from"), getParam<int>(params, "days"))
        );
      case ClientReportType.totalCards:
        return ("count", await analytics.countTotalCards(clientId));
      case ClientReportType.activeCards:
        return (
          "array",
          await analytics.countActiveCards(clientId, getParam<IntDate>(params, "from"), getParam<int>(params, "days"))
        );
      case ClientReportType.newCards:
        return (
          "array",
          await analytics.countNewCards(clientId, getParam<IntDate>(params, "from"), getParam<int>(params, "days"))
        );
      case ClientReportType.reservationDates:
        return (
          "array",
          await analytics.countReservationDates(
            clientId,
            ReservationDateStatusCode.fromCodeOrNull(getParam<int>(params, "status"))!,
            getParam<IntDate>(params, "from"),
            getParam<int>(params, "days"),
          )
        );
      default:
        throw "Invalid report type: $this";
    }
  }
}

extension ClientReports on ClientReportHandler {
  Duration toTheEndOfThisDay(Session session) {
    final userTimeZoneOffset = session.timeZoneOffset; // Posun používateľa v sekundách
    final serverTimeZoneOffset = DateTime.now().timeZoneOffset.inSeconds; // Posun servera v sekundách

    // Rozdiel medzi časovou zónou používateľa a servera
    final offsetDifference = Duration(seconds: userTimeZoneOffset - serverTimeZoneOffset);

    // Aktuálny čas na serveri
    final serverNow = DateTime.now();

    // Úprava času na čas používateľa
    final userNow = serverNow.add(offsetDifference);

    // Konečný čas na konci dňa z pohľadu používateľa (23:59:59)
    final endOfThisDay = DateTime(userNow.year, userNow.month, userNow.day, 23, 59, 59);

    // Rozdiel medzi aktuálnym časom používateľa a koncom dňa
    final toEndOfThisDay = endOfThisDay.difference(userNow);

    return toEndOfThisDay;
  }

  Future<JsonObject> getReport(
    ClientReportType type,
    Session session,
    DashboardAnalyticsDAO analytics,
    String clientId,
    JsonObject params,
  ) async {
    final tag = params["_tag"];
    try {
      final key = CacheKeys.clientReportType(clientId, type, reportParams: params);
      final cached = await Cache().getJson(api.redis, key);
      if (cached != null) {
        if (tag != null) cached["_tag"] = tag;
        return cached;
      } else {
        final expiration = toTheEndOfThisDay(session);
        final (column, data) = await type.exec(clientId, analytics, params);
        final res = <String, dynamic>{
          //"_type": type.name,
          column: data,
        };
        await Cache().putJson(api.redis, key, res, expiration: expiration);
        if (api.config.isDev || api.config.isQa)
          res.addAll({
            "_expiration": expiration.inMinutes,
          });
        if (tag != null) res["_tag"] = tag;
        return res;
      }
    } catch (ex) {
      return {
        "_type": type.name,
        if (tag != null) "_tag": tag,
        "_error": ex.toString(),
      };
    }
  }
}

//

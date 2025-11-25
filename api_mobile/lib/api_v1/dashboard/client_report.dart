import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/dashboard_analytics.dart";
import "../../extensions/request_body.dart";
import "../session.dart";
import "client_reports.dart";

class ClientReportHandler extends ApiServerHandler {
  ClientReportHandler(super.api);

/*
enum ClientReport {
  totalClients,
  newClients, // from|now - days
  totalCards,
  activeCards, // for activityPeriod
  newActiveCards, // for activityPeriod
  activeCardsForPeriod, // from|now - days - nedáva zmysel, možno v prepočtoch za platbu
  transactionsInWeek,
  reservationsReportInWeek, // total + ReservationDateStatus
}

*/

  // { "reports": [ {"report":"", "id": "", "from":"", "to":""},... ]}

  Future<Response> _report(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        final clientId = session.clientId;
        if (clientId == null) return api.forbidden(errorNoClientId);

        final body = cast<JsonObject>(await request.body.asJson);
        if (body == null) return api.badRequest(errorInvalidParameterType("body", "JsonObject"));

        final jsonReports = (cast<List<dynamic>>(body["reports"]))?.cast<JsonObject>();
        if (jsonReports == null) return api.badRequest(errorInvalidParameterType("reports", "List"));

        if (jsonReports.isEmpty) return api.badRequest(errorInvalidParameterType("reports", "Empty"));

        final analytics = DashboardAnalyticsDAO(context);
        final output = <JsonObject>[];

        for (final jsonReport in jsonReports) {
          final type = ClientReportType.values.firstWhereOrNull((e) => e.name == jsonReport["_type"]);
          if (type == null) continue;
          output.add(await getReport(type, session, analytics, clientId, jsonReport));
        }

        return api.json({"reports": output});
      });

  // /v1/dashboard/client_report
  Router get router {
    final router = Router();

    router.post("/", _report);
    //router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

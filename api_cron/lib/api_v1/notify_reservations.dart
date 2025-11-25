import "dart:convert";

import "package:api_cron/strings.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:mailer/mailer.dart";
import "package:mailer/smtp_server.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../implementations/api_shelf.dart";
import "../implementations/configuration_yaml.dart";
import "../utils/storage.dart";
import "../utils/template_generator.dart";
import "cron_handler.dart";
import "data_access_objects/notify_reservations.dart";

class NotifyReservationsHandler extends CronHandler<NotifyReservationsInterval> {
  NotifyReservationsHandler(ApiServer2 api) : super("NotifyReservations", api);

  Future<(bool, JsonObject)> _sendEmail({
    required String token,
    required String userEmail,
    required String reservationDateId,
    required String userLanguage,
    required String clientName,
    required String clientLogo,
    String? location,
  }) async {
    final subject = "$clientName: ${api.tr(userLanguage, LangKeys.htmlNotifyReservationTitle.tr())}";

    final html = await TemplateGenerator(api).notifyReservations(
      token: token,
      userEmail: userEmail,
      userLanguage: userLanguage,
      clientName: clientName,
      clientLogo: clientLogo,
      location: location,
    );

    final config = api.config as CronApiConfig;

    final smtpServer = SmtpServer(
      config.smtpHost,
      username: config.smtpUsername,
      password: config.smtpPassword,
      port: config.smtpPort,
      ssl: config.smtpUseSsl,
    );

    final message = Message()
      ..from = Address(config.smtpFrom)
      ..recipients = [userEmail]
      ..subject = subject
      ..html = html;

    try {
      api.log.verbose("Sending email to $userEmail");
      final sendReport = await send(message, smtpServer);
      api.log.verbose("   Result: sent ${sendReport.connectionOpened}");
      return (
        true,
        {
          "reservationDateId": reservationDateId,
          "connectionOpened": sendReport.connectionOpened.toUtc().toIso8601String(),
          "messageSendingStart": sendReport.messageSendingStart.toUtc().toIso8601String(),
          "messageSendingEnd": sendReport.messageSendingEnd.toUtc().toIso8601String(),
        },
      );
    } on MailerException catch (e) {
      api.log.verbose("   Result: error ${e.message}");
      return (
        false,
        {
          "reservationDateId": reservationDateId,
          "problems": e.problems.map((p) => {"code": p.code, "msg": p.msg}).toList(),
        },
      );
    } catch (e) {
      api.log.error("Unspecified error ocurred while sending email for reservationDateId: $reservationDateId.\n$e");
      return Future.error(e);
    }
  }

  @override
  Future<JsonObject> process(ApiServerContext context, NotifyReservationsInterval param) async {
    final notifyReservationsDAO = NotifyReservationsDAO(param, context);
    final json = await notifyReservationsDAO.notify();
    final total = json["total"] as int;
    if (total == 0) return json;
    final toSend = json["notify"] as List<JsonObject>;
    final emailSent = await Future.wait<(bool, JsonObject)>(toSend.map((result) async {
      final reservationDateId = result["reservationDateId"];
      final userId = result["userId"];
      final token = result["token"];
      log.verbose("Notified reservation date id $reservationDateId for user $userId, token $token");
      if (token == null) return (false, {"reservationDateId": reservationDateId, "error": "No token"});
      return await _sendEmail(
        token: token,
        reservationDateId: reservationDateId,
        userEmail: result["userEmail"],
        userLanguage: result["userLanguage"],
        clientName: result["clientName"],
        clientLogo: storageUrl(
              api.config as CronApiConfig,
              result["clientLogo"],
              StorageObject.client,
              timeStamp: tryParseDateTime(result["clientUpdatedAt"]),
            ) ??
            "",
        location: formatAddress(result["locationAddressLine1"], result["locationAddressLine2"], result["locationCity"],
            zip: result["locationZip"]),
      );
    }).toList());
    emailSent.map((sent) {
      final reservationDateId = sent.$2["reservationDateId"];
      print(toSend);
      final record = toSend.firstWhere((r) => r["reservationDateId"] == reservationDateId);
      record["sent"] = sent.$1;
      record["result"] = sent.$2
        // Don't include reservationDateId in the result, it is already in the json
        ..removeWhere((key, value) => key == "reservationDateId");
    }).toList();
    await recordLastRun(json);
    return json;
  }

  Future<Response> _notify(Request req) async => withRequestLog((context) async {
        log.logRequest(context, req.toLogRequest());
        final json = await process(context, NotifyReservationsInterval.day2);
        log.verbose(json, jsonEncode);
        return api.json(json);
      });

  // /v1/user/notify_reservations/notify
  Router get router {
    final router = Router();

    router.get("/notify", _notify);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

import "package:collection/collection.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/dashboard/reservation_date.dart";
import "../../data_access_objects/user.dart";
import "../../data_models/session.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../strings.dart";
import "../../utils/send_message.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class ReservationDateHandler extends ApiServerHandler {
  ReservationDateHandler(super.api);

  Future<void> _sendMessage(
    Request request,
    ApiServerContext context,
    Session session,
    ActionType action,
    String termId, {
    String? reservedByUserId,
  }) async {
    final reservationDateDAO = ReservationDateDAO(session, context);
    final data = await reservationDateDAO.userReservationDataForMessage(termId: termId);
    if (data == null) return;
    final userId = reservedByUserId ?? data.reservedByUserId;
    if (userId == null) return;

    final user = await UserDAO(session, context).selectById(userId);
    final userLanguage = user?.language ?? "en";

    final clientLogo = api.storageUrl(data.clientLogo, StorageObject.client);
    final reservationName = data.reservationName;
    final slotName = data.reservationSlotName;
    final name = "$reservationName - $slotName";

    var body = api.tr(userLanguage, LangKeys.messageReservationChanged.tr(), args: [name]);
    if (action == ActionType.reservationClosed) {
      body = api.tr(userLanguage, LangKeys.messageReservationCanceled.tr(), args: [name]);
    } else if (action == ActionType.reservationAccepted) {
      body = api.tr(userLanguage, LangKeys.messageReservationConfirmed.tr(), args: [name]);
    }

    await sendMessageToUser(api, session,
        messageTypes: [MessageType.pushNotification, MessageType.inApp],
        userId: userId,
        subject: name,
        body: body,
        payload: {
          "action": action.code.toString(),
          "clientId": session.clientId,
          "clientName": data.clientName,
          "clientLogo": clientLogo,
          "clientLogoBh": data.clientLogoBh,
          "clientColor": data.clientColor,
          "reservationSlotId": data.reservationSlotId,
          "reservationSlotName": slotName,
          "reservationId": data.reservationId,
          "reservationName": reservationName,
          "reservationDateId": termId,
          "dateTimeFrom": data.dateTimeFrom.toIso8601String(),
          "dateTimeTo": data.dateTimeTo.toIso8601String(),
        });
  }

  /// Returns list of reservation_dates for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Path parameter: reservationId
  ///   reservationId: ID of the reservation for which list of reservation_dates will be returned.
  /// Path parameter: dateOfWeek
  ///   dateOfWeek: ISO 8601 date of the week for which list of reservation_dates will be returned.
  /// Query parameters: search, filter, limit.
  ///   limit: number of records to return. Skip to return all reservation_dates.
  Future<Response> _list(Request request, String reservationId, String dateOfWeek) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final limit = int.tryParse(query["limit"] ?? "");

        final reservationDateDAO = ReservationDateDAO(session, context);
        final reservationDates = await reservationDateDAO.selectWeek(
            reservationId: reservationId, dateOfWeek: DateTime.parse(dateOfWeek), limit: limit);

        final dataObject = reservationDates.map((e) => e.toMap(ReservationDate.camel)).toList();
        return api.json({
          "length": dataObject.length,
          "reservationDates": dataObject,
        });
      });

  /// Creates new reservation_date(s).
  /// Required roles: pos or admin
  /// Response status codes: 201, 400, 401, 403, 500
  /// Required body parameters: reservationId, reservationSlotId, dateTimeFrom, dateTimeTo, days,
  /// timeFromHour, timeToHour, timeFromMinute, timeToMinute, duration, pause
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _createMultiple(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final List<ReservationDate> newReservationDates = [];
        final days = (body["days"] as List<dynamic>).cast<bool>();
        var dateFrom = DateTime.parse(body["dateFrom"] as String);
        final dateTo = DateTime.parse(body["dateTo"] as String);
        final duration = body["duration"] as int;
        final pause = body["pause"] as int;
        final timeFromMinute = body["timeFromMinute"] as int;
        final timeFromHour = body["timeFromHour"] as int;
        final timeToMinute = body["timeToMinute"] as int;
        final timeToHour = body["timeToHour"] as int;
        while (dateFrom.isBefore(dateTo) || dateFrom.isAtSameMomentAs(dateTo)) {
          if (days[dateFrom.weekday - 1]) {
            var cTimeFrom = DateTime.utc(dateFrom.year, dateFrom.month, dateFrom.day, timeFromHour, timeFromMinute);
            var cTimeTo = cTimeFrom.add(Duration(minutes: duration));
            final cDayTo = DateTime.utc(dateFrom.year, dateFrom.month, dateFrom.day, timeToHour, timeToMinute);
            while (cTimeTo.isBefore(cDayTo) || cTimeTo.isAtSameMomentAs(cDayTo)) {
              final reservationDate = ReservationDate(
                reservationDateId: uuid(),
                clientId: session.clientId,
                reservationId: body["reservationId"] as String,
                reservationSlotId: body["reservationSlotId"] as String,
                status: ReservationDateStatus.available,
                dateTimeFrom: cTimeFrom,
                dateTimeTo: cTimeTo,
              );
              newReservationDates.add(reservationDate);
              cTimeFrom = cTimeFrom.add(Duration(minutes: duration + pause));
              cTimeTo = cTimeFrom.add(Duration(minutes: duration));
            }
          }
          dateFrom = dateFrom.add(Duration(days: 1));
        }

        final reservationDateDAO = ReservationDateDAO(session, context);
        final inserted = await reservationDateDAO.insertMany(newReservationDates);
        return api.created({"affected": inserted});
      });

  /// Delete reservation_date(s).
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Required body parameters: reservationId, reservationSlotId, dateFrom, dateto, days,
  /// timeFromHour, timeToHour, timeFromMinute, timeToMinute, removeReservedDates
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _deleteMultiple(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final days =
            (body["days"] as List<dynamic>).cast<bool>().mapIndexed((i, day) => day ? i + 1 : null).nonNulls.toList();
        final bodyDateFrom = DateTime.parse(body["dateFrom"] as String);
        final bodyDateTo = DateTime.parse(body["dateTo"] as String);
        final dateTimeFrom = DateTime(bodyDateFrom.year, bodyDateFrom.month, bodyDateFrom.day,
            body["timeFromHour"] as int, body["timeFromMinute"] as int);
        final dateTimeTo = DateTime(
            bodyDateTo.year, bodyDateTo.month, bodyDateTo.day, body["timeToHour"] as int, body["timeToMinute"] as int);
        final reservationDateDAO = ReservationDateDAO(session, context);
        final updated = await reservationDateDAO.deleteMany(
          reservationSlotId: body["reservationSlotId"] as String,
          days: days,
          dateTimeFrom: dateTimeFrom,
          dateTimeTo: dateTimeTo,
          removeReservedDates: body["removeReservedDates"] as bool,
        );

        return api.json({"affected": updated});
      });

  /// Confirm reservation_date -> change it's status to confirmed.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Required body parameters: reservationDateId
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _confirm(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final reservationDateId = body["reservationDateId"] as String;
        final reservationDateDAO = ReservationDateDAO(session, context);
        final (updated, userId) = await reservationDateDAO.confirm(reservationDateId: reservationDateId);

        if (userId != null) {
          await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        }

        await _sendMessage(request, context, session, ActionType.reservationAccepted, reservationDateId);

        return api.json({"affected": updated});
      });

  Future<Response> _complete(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final reservationDateId = body["reservationDateId"] as String;
        final reservationDateDAO = ReservationDateDAO(session, context);
        final updated = await reservationDateDAO.complete(reservationDateId: reservationDateId);

        return api.json({"affected": updated});
      });

  Future<Response> _forfeit(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final reservationDateId = body["reservationDateId"] as String;
        final reservationDateDAO = ReservationDateDAO(session, context);
        final updated = await reservationDateDAO.forfeit(reservationDateId: reservationDateId);

        return api.json({"affected": updated});
      });

  Future<Response> _addUserToDate(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final reservationDateId = body["reservationDateId"] as String?;
        if (reservationDateId == null)
          return api.badRequest(errorInvalidParameterType("reservationDateId", "not null"));
        final reservedByUserId = body["reservedByUserId"] as String?;
        if (reservedByUserId == null) return api.badRequest(errorInvalidParameterType("reservedByUserId", "not null"));

        final reservationDateDAO = ReservationDateDAO(session, context);

        final updated = await reservationDateDAO.addUserToDate(reservationDateId, reservedByUserId);
        if (updated == 1)
          await _sendMessage(request, context, session, ActionType.reservationAccepted, reservationDateId,
              reservedByUserId: reservedByUserId);

        return api.json({"affected": updated});
      });

  Future<Response> _cancel(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final reservationDateId = body["reservationDateId"] as String?;
        if (reservationDateId == null)
          return api.badRequest(errorInvalidParameterType("reservationDateId", "not null"));
        final reservedByUserId = body["reservedByUserId"] as String?;
        if (reservedByUserId == null) return api.badRequest(errorInvalidParameterType("reservedByUserId", "not null"));

        final reservationDateDAO = ReservationDateDAO(session, context);

        final updated = await reservationDateDAO.cancel(reservationDateId);
        if (updated == 1)
          await _sendMessage(request, context, session, ActionType.reservationClosed, reservationDateId,
              reservedByUserId: reservedByUserId);

        return api.json({"affected": updated});
      });

  Future<Response> _swapDates(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final dateId1 = body["date1"] as String;
        final dateId2 = body["date2"] as String;
        final reservationDateDAO = ReservationDateDAO(session, context);
        final updated = await reservationDateDAO.swapDates(dateId1, dateId2);

        return api.json({"affected": updated});
      });

  /// Set one reservation_date as deleted.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Path parameter: reservationDateId
  ///   reservationDateId: ID of the reservation_date to be deleted.
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _deleteDate(Request request, String reservationDateId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final reservationDateDAO = ReservationDateDAO(session, context);
        final (deleted, userId) = await reservationDateDAO.delete(reservationDateId: reservationDateId);

        if (deleted == 1 && userId != null)
          await _sendMessage(request, context, session, ActionType.reservationClosed, reservationDateId,
              reservedByUserId: userId);

        return api.json({"affected": deleted});
      });

  // /v1/dashboard/reservation_date
  Router get router {
    final router = Router();

    router.get("/<reservationId|$idRegExp>/<dateOfWeek>", _list);

    router.post("/multiple", _createMultiple);
    router.put("/multiple", _deleteMultiple);

    router.put("/confirm", _confirm);
    router.put("/cancel", _cancel);
    router.put("/book", _addUserToDate);
    router.put("/complete", _complete);
    router.put("/forfeit", _forfeit);
    router.put("/swap", _swapDates);

    router.delete("/<reservationDateId|$idRegExp>", _deleteDate);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

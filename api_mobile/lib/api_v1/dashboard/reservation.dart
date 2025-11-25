import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/reservation.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";
import "../session.dart";

class ReservationHandler extends ApiServerHandler {
  ReservationHandler(super.api);

  /// Returns list of reservations for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Parameters: search, filter, limit.
  ///   filter: 1 - active, 2 - archived
  ///   limit: number of records to return. Skip to return all reservations.
  ///   search: optional - search string for reservation name / description.
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final search = query["search"];
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");

        final reservationDAO = ReservationDAO(session, context);
        final reservations = await reservationDAO.list(filter: filter, limit: limit, search: search);

        final dataObject = reservations.map((e) => e.toMap(Reservation.camel)).toList();
        return api.json({
          "length": dataObject.length,
          "reservations": dataObject,
        });
      });

  /// Returns list of active reservations for current day along with details for main dashboard screen for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Parameters: limit.
  ///   limit: number of records to return. Skip to return all reservations.
  Future<Response> _listForConfirmation(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final limit = int.tryParse(query["limit"] ?? "") ?? 20;

        final reservationDAO = ReservationDAO(session, context);
        final reservationsForConfirmation = await reservationDAO.listForConfirmation(limit: limit);

        final dataObject = reservationsForConfirmation.map((e) => e.toMap(Convention.camel)).toList();
        return api.json({
          "length": dataObject.length,
          "activeReservations": dataObject,
        });
      });

  /// Creates new reservation.
  /// Required roles: pos or admin
  /// Response status codes: 201, 400, 401, 403, 500
  /// Required body parameters: loyaltyMode, name, rank
  /// Optional body parameters: programId, description, image, image_bh, meta, blocked
  /// Notes:
  ///   reservation_id is determined by the path parameter (use uuid v4).
  ///   client_id is determined by the session.
  Future<Response> _create(Request request, String reservationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final jsonReservationIdKey = Reservation.camel[ReservationKeys.reservationId]!;
        final jsonClientIdKey = Reservation.camel[ReservationKeys.clientId]!;

        final reservation = Reservation.fromMap(
            body
              ..addAll({
                jsonReservationIdKey: reservationId,
                jsonClientIdKey: session.clientId,
              }),
            Reservation.camel);
        final inserted = await ReservationDAO(session, context).insert(reservation);

        return api.created({"affected": inserted});
      });

  /// Update existing reservation.
  /// Required roles: pos or admin
  /// Response status codes: 202, 403, 500
  /// Required body parameters: loyaltyMode, name, rank
  /// Optional body parameters: programId, description, image, image_bh, meta
  /// Notes:
  ///   reservation_id is determined by the path parameter (use uuid v4).
  ///   client_id is determined by the session.
  Future<Response> _update(Request request, String reservationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final jsonReservationIdKey = Reservation.camel[ReservationKeys.reservationId]!;
        final jsonClientIdKey = Reservation.camel[ReservationKeys.clientId]!;
        final reservation = Reservation.fromMap(
            body
              ..addAll({
                jsonReservationIdKey: reservationId,
                jsonClientIdKey: session.clientId,
              }),
            Reservation.camel);
        final updated = await ReservationDAO(session, context).update(reservation);

        return api.accepted({"affected": updated});
      });

  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 500
  /// Notes:
  ///  reservation_id is determined by the path parameter.
  ///  client_id is determined by the session.
  Future<Response> _patch(Request request, String reservationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (blocked == null && archived == null)
          return api.badRequest(errorBrokenLogicEx("blocked or archived must not be null"));
        final patched = await ReservationDAO(session, context).patch(
          reservationId,
          blocked: blocked,
          archived: archived,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple reservations.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reservations": [ {"reservation_id": "reservation1", "rank": 1}, ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject?;
        final reservations = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (reservations?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ReservationDAO(session, context).reorder(reservations!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/reservation
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.get("/confirmation", _listForConfirmation);
    router.post("/<reservationId|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<reservationId|$idRegExp>", _update);
    router.patch("/<reservationId|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

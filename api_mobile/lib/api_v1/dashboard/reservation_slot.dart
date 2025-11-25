import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/reservation_slot.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../check_role.dart";
import "../session.dart";

class ReservationSlotHandler extends ApiServerHandler {
  ReservationSlotHandler(super.api);

  /// Returns list of reservation_slots for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Path parameter: reservationId
  ///   reservationId: ID of the reservation for which list of reservation_slots will be returned.
  /// Query parameters: search, filter, limit.
  ///   filter: 1 - active, 2 - archived
  ///   limit: number of records to return. Skip to return all reservation_slots.
  ///   search: optional - search string for reservation_slot name / description.
  Future<Response> _list(Request request, String reservationId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final search = query["search"];
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");

        final slots = await ReservationSlotDAO(session, context).list(
          reservationId: reservationId,
          filter: filter,
          limit: limit,
          search: search,
        );
        if (slots.isEmpty) return api.noContent();
        return api.json({
          "length": slots.length,
          "reservationSlots": slots.map((e) => e.toMap(ReservationSlot.camel)).toList(),
        });
      });

  /// Creates new reservation_slot.
  /// Required roles: pos or admin
  /// Response status codes: 201, 400, 401, 403, 500
  /// Required body parameters: reservationId, name, rank
  /// Optional body parameters: locationId, description, image, image_bh, price, duration, meta
  /// Notes:
  ///   reservation_slot_id is determined by the path parameter (use uuid v4).
  ///   client_id is determined by the session.
  Future<Response> _create(Request request, String reservationSlotId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final jsonReservationSlotIdKey = ReservationSlot.camel[ReservationSlotKeys.reservationSlotId]!;
        final jsonClientIdKey = ReservationSlot.camel[ReservationSlotKeys.clientId]!;

        final reservationSlot = ReservationSlot.fromMap(
            body
              ..addAll({
                jsonReservationSlotIdKey: reservationSlotId,
                jsonClientIdKey: session.clientId,
              }),
            ReservationSlot.camel);
        final inserted = await ReservationSlotDAO(session, context).insert(reservationSlot);

        return api.created({"affected": inserted});
      });

  /// Update existing reservation_slot.
  /// Required roles: pos or admin
  /// Response status codes: 202, 403, 500
  /// Required body parameters: reservationId, name, rank
  /// Optional body parameters: locationId, description, image, image_bh, price, duration, meta
  /// Notes:
  ///   reservation_slot_id is determined by the path parameter (use uuid v4).
  ///   client_id is determined by the session.
  Future<Response> _update(Request request, String reservationSlotId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final jsonReservationSlotIdKey = ReservationSlot.camel[ReservationSlotKeys.reservationSlotId]!;
        final jsonClientIdKey = ReservationSlot.camel[ReservationSlotKeys.clientId]!;
        final reservationSlot = ReservationSlot.fromMap(
            body
              ..addAll({
                jsonReservationSlotIdKey: reservationSlotId,
                jsonClientIdKey: session.clientId,
              }),
            ReservationSlot.camel);
        final updated = await ReservationSlotDAO(session, context).update(reservationSlot);

        return api.accepted({"affected": updated});
      });

  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  reservation_slot_id is determined by the path parameter.
  ///  client_id is determined by the session.
  Future<Response> _patch(Request request, String reservationSlotId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (blocked == null && archived == null)
          return api.badRequest(errorBrokenLogicEx("blocked or archived must not be null"));
        final patched = await ReservationSlotDAO(session, context).patch(
          reservationSlotId,
          blocked: blocked,
          archived: archived,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple reservation_slots.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reservation_slots": [ {"reservation_slot_id": "reservation_slot1", "rank": 1}, ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final slots = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (slots?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ReservationSlotDAO(session, context).reorder(slots!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/reservation_slot
  Router get router {
    final router = Router();

    router.get("/<reservationId|$idRegExp>", _list);
    router.post("/<reservationSlotId|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<reservationSlotId|$idRegExp>", _update);
    router.patch("/<reservationSlotId|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

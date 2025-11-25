import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/mobile/reservation_date.dart";
import "../../data_access_objects/reservation.dart";
import "../../data_access_objects/send_message.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf2.dart";
import "../session.dart";

class ReservationHandler extends ApiServerHandler {
  final MobileApi _api;
  ReservationHandler(this._api) : super(_api);

  Future<Response> _listCurrent(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final reservations = await ReservationDAO(session, context).active();
        if (reservations.isEmpty) return _api.noContent();
        return _api.json({
          "length": reservations.length,
          "reservations": reservations.map((e) => e.toMap(UserReservation.camel)).toList(),
        });
      });

  Future<Response> _listActive(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final reservations = await ReservationDAO(session, context).active(clientId: clientId);
        if (reservations.isEmpty) return _api.noContent();
        return _api.json({
          "length": reservations.length,
          "reservations": reservations.map((e) => e.toMap(UserReservation.camel)).toList(),
        });
      });

  Future<Response> _listClient(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final reservations = await ReservationDAO(session, context).listClient(clientId);
        if (reservations.isEmpty) return _api.noContent();
        return _api.json({
          "length": reservations.length,
          "reservations": reservations.map((e) => e.toMap(Reservation.camel)).toList(),
        });
      });

  Future<Response> _listSlot(Request request, String slotId, String dateOfMonth) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final month = IntMonth.parseString(dateOfMonth);
        if (month == null) return _api.badRequest(errorBrokenLogicEx("dateOfMonth"));
        final dates = await ReservationDateDAO(session, context).selectMonth(
          dateOfMonth: month.toDate(),
          reservationSlotId: slotId,
        );
        if (dates.isEmpty) return _api.noContent();
        return _api.json({
          "length": dates.length,
          "dates": dates.map((e) => e.toMap(ReservationDate.camel)).toList(),
        });
      });

  Future<Response> _patch(Request request, String dateId) async => withRequestLog((context) async {
        try {
          final installationId = request.context["iid"] as String;
          final session = await _api.getSession(installationId);

          final body = await request.body.asJson;
          final confirm = tryParseBool(body["confirm"]);
          if (confirm == null) return _api.badRequest(errorBrokenLogicEx("confirm"));

          final userCouponId = body["userCouponId"] as String?;
          final useCredit = tryParseBool(body["useCredit"]) ?? false;

          String? cardId;
          String? userCardId;
          if (useCredit) {
            cardId = body["cardId"] as String?;
            userCardId = body["userCardId"] as String?;
            if (cardId == null || userCardId == null)
              return _api.badRequest(errorBrokenLogicEx("cardId or userCardId"));
          }

          final (patched, redeemed, credited) = await ReservationDateDAO(session, context).patchReservation(
            dateId,
            confirm: confirm,
            userCouponId: userCouponId,
            useCredit: useCredit,
            cardId: cardId,
            userCardId: userCardId,
          );

          if (confirm && patched > 0 && userCouponId != null) {
            if (redeemed != 0) {
              await SendMessage(context)
                  .sendUserCouponMessage(request, session, userCouponId, ActionType.userCouponRedeemed);
              await Cache().clear(_api.redis, CacheKeys.userUserCards(session.userId));
              await Cache().clearAll(_api.redis, CacheKeys.userUserCard(session.userId, userCardId ?? "*"));
            } else {
              // TODO: loyalty - count loyalty points to userCardId
            }
          }

          if (useCredit) {
            if (!credited) {
              return _api.forbidden(errorNotEnoughPoints);
            }
            await Cache().clear(_api.redis, CacheKeys.userUserCards(session.userId));
            await Cache().clearAll(_api.redis, CacheKeys.userUserCard(session.userId, userCardId ?? "*"));
          }

          // TODO: message - send message to client 'Your reservation has been confirmed'
          //    confirm ? 'Your reservation has been confirmed' : 'Your reservation has been canceled'

          return _api.accepted({"affected": patched});
        } on CoreError catch (err) {
          log.error(err.toString());
          return _api.internalError(err);
        } catch (ex, st) {
          log.error(ex.toString());
          log.error(st.toString());
          return _api.internalError(errorUnexpectedException(ex));
        }
      });

  // /v1/reservation
  Router get router {
    final router = Router();
    // TODO: remove later
    router.get("/current", _listCurrent);
    router.get("/active/<clientId|${_api.idRegExp}>", _listActive);
    router.get("/client/<clientId|${_api.idRegExp}>", _listClient);
    router.get("/slot/<slotId|${_api.idRegExp}>/<dateOfMonth|[0-9]{6}>", _listSlot);
    router.patch("/<dateId|${_api.idRegExp}>", _patch);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

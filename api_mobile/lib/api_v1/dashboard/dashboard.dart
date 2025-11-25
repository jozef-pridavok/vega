import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/client.dart";
import "../../data_access_objects/dashboard/dashboard.dart";
import "../../data_access_objects/dashboard/reservation.dart";
import "../../data_access_objects/order.dart";
import "../session.dart";

class DashboardHandler extends ApiServerHandler {
  DashboardHandler(super.api);

  Future<Response> _detail(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        final clientId = session.clientId;

        final hasAdminRole = session.userRoles.contains(UserRole.admin);
        final hasFinanceRole = session.userRoles.contains(UserRole.finance);
        final hasPosRole = session.userRoles.contains(UserRole.pos);
        final hasReservationRole = session.userRoles.contains(UserRole.reservation);
        final hasOrderRole = session.userRoles.contains(UserRole.order);

        final isPartner = session.userType == UserType.partner;
        final isNotPartner = session.userType != UserType.partner;

        if (clientId == null && !isPartner) return api.forbidden(errorNoClientId);

        IntDate? license;
        List<Card> cards = [];
        List<Program> programs = [];
        List<Coupon> coupons = [];
        List<ReservationForDashboard> reservationsForConfirmation = [];
        List<ReservationForDashboard> reservationsForFinalization = [];
        List<OrderForDashboard> ordersForAcceptance = [];
        List<OrderForDashboard> ordersForFinalization = [];

        if (isNotPartner && (hasAdminRole || hasFinanceRole)) {
          final clientDAO = ClientDAO(session, context);
          license = await clientDAO.getClientLicense(clientId!);
        }

        final dao = DashboardDAO(session, context);

        if (hasAdminRole || hasPosRole) {
          programs = await dao.selectClientPrograms();
          coupons = await dao.selectClientCoupons();
          cards = await dao.selectClientCards();
        }

        if (hasAdminRole || hasReservationRole) {
          final reservationDAO = ReservationDAO(session, context);
          reservationsForConfirmation = await reservationDAO.listForConfirmation(limit: 20);
          reservationsForFinalization = await reservationDAO.listForFinalization(limit: 20);
        }

        if (hasAdminRole || hasOrderRole) {
          final orderDAO = OrderDAO(session, context);
          ordersForAcceptance = await orderDAO.listForAcceptance(limit: 10);
          ordersForFinalization = await orderDAO.listForFinalization(limit: 10);
        }

        return api.json({
          if (license != null) "license": license.value,
          if (cards.isNotEmpty) "cards": cards.map((e) => e.toMap(Convention.camel)).toList(),
          if (programs.isNotEmpty) "programs": programs.map((e) => e.toMap(Convention.camel)).toList(),
          if (coupons.isNotEmpty) "coupons": coupons.map((e) => e.toMap(Convention.camel)).toList(),
          if (reservationsForConfirmation.isNotEmpty)
            "reservationsForConfirmation": reservationsForConfirmation.map((e) => e.toMap(Convention.camel)).toList(),
          if (reservationsForFinalization.isNotEmpty)
            "reservationsForFinalization": reservationsForFinalization.map((e) => e.toMap(Convention.camel)).toList(),
          if (ordersForAcceptance.isNotEmpty)
            "ordersForAcceptance": ordersForAcceptance.map((e) => e.toMap(Convention.camel)).toList(),
          if (ordersForFinalization.isNotEmpty)
            "ordersForFinalization": ordersForFinalization.map((e) => e.toMap(Convention.camel)).toList(),
        });
      });

  // /v1/dashboard/
  Router get router {
    final router = Router();

    router.get("/", _detail);
    //router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

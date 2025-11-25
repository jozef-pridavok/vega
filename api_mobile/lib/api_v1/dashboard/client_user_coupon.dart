import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/user_coupon.dart";
import "../check_role.dart";
import "../session.dart";

class ClientUserCouponHandler extends ApiServerHandler {
  ClientUserCouponHandler(super.api);

  /// Returns list of user coupons. Url parameters:
  /// - filter: filter by user coupon name, user coupon description or user nick name (optional)
  /// - period: number of days to consider a user coupon activity (optional, default: 7)
  ///     positive number: active user coupons (activity in the last period days)
  ///     zero: all coupons
  /// - type: filter by coupon type (optional)
  /// - couponId: filter by coupon id (optional)
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final query = request.url.queryParameters;
        final filter = query["filter"];
        final period = tryParseInt(query["period"]);
        final type = tryParseInt(query["type"]);
        final couponId = query["couponId"];
        final userCoupons = await UserCouponDAO(session, context)
            .selectUserCoupons(session.clientId!, period: period, filter: filter, type: type, couponId: couponId);
        final json = {
          "length": userCoupons.length,
          "userCoupons": userCoupons.map((userCoupon) => userCoupon.toMap(Convention.camel)).toList(),
        };
        return api.json(json);
      });

  // /v1/dashboard/client_user_coupon
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

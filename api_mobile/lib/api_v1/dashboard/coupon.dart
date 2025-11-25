import "dart:convert";
import "dart:io";

import "package:core_dart/core_algorithm.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/check_role.dart";
import "../../cache.dart";
import "../../data_access_objects/dashboard/coupon.dart";
import "../../data_access_objects/dashboard/user_coupon.dart";
import "../../data_access_objects/send_message.dart";
import "../../data_access_objects/user.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../implementations/configuration_yaml.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../session.dart";

class CouponHandler extends ApiServerHandler {
  CouponHandler(super.api);

  /// Checks if QR code represents user identity. If so, returns userId, otherwise null.
  String? _isUserIdentity(CodeType type, String number) {
    if (type != CodeType.qr) return null;
    final qrBuilder = QrBuilder(
        (api.config as MobileApiConfig).secretQrCodeKey, "a", (api.config as MobileApiConfig).secretQrCodeEnv);
    return qrBuilder.parseUserIdentity(number);
  }

  /// Checks if QR code represents user coupon. If so, returns userCouponId, otherwise null.
  String? _isUserCoupon(CodeType type, String number) {
    if (type != CodeType.qr) return null;
    final qrBuilder = QrBuilder(
        (api.config as MobileApiConfig).secretQrCodeKey, "a", (api.config as MobileApiConfig).secretQrCodeEnv);
    return qrBuilder.parseUserCouponIdentity(number);
  }

  /// Returns list of coupons for user.
  /// Parameters: search, filter, limit.
  ///   search: search string for coupon name.
  ///   filter: 1 - active, 2 - inactive, other - specified date range. Range is specified as big int YYYYMMDDYYYYMMDD. Default is 1.
  ///   limit: number of records to return. Skip to return all coupons.
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final search = query["search"];
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");

        final coupons = await CouponDAO(session, context).list(search, filter, limit);
        if (coupons.isEmpty) return api.noContent();
        final json = coupons.map((coupon) {
          coupon.clientLogo = api.storageUrl(coupon.clientLogo, StorageObject.client);
          coupon.image = api.storageUrl(coupon.image, StorageObject.coupon, timeStamp: coupon.updatedAt);
          return coupon.toMap(Convention.camel);
        }).toList();
        return api.json({"length": json.length, "coupons": json});
      });

  /// Creates new coupon.
  /// Required roles: admin
  /// Response status codes: 201, 400, 401, 403, 500
  /// Required body parameters: type, name, rank, valid_from
  /// Optional body parameters: location_id, description, code, codes, image, image_bh,
  /// color, countries, valid_to, meta
  /// Notes:
  ///  coupon_id is determined by the path parameter (use uuid v4).
  ///  client_id is determined by the session.
  Future<Response> _createOrUpdate(Request request, String couponId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? couponImage;
        String? couponImageBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          print(mediaType);
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (couponImage != null) log.warning("Coupon image already set");
            couponImage = "coupon_$couponId.${mediaType.subtype}";
            final filePath = api.storagePath(couponImage!, StorageObject.coupon);
            log.debug("Saving coupon image to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            couponImageBh = await getImageBhFromFile(filePath) ?? "";
          }
        }

        final contentType = request.headers["Content-Type"];
        var mediaType = MediaType.parse(contentType ?? "");
        if (mediaType.type == "application" && mediaType.subtype == "json") {
          body = (await request.body.asJson) as JsonObject;
        } else {
          if (request.isMultipart) {
            await for (final part in request.parts) {
              await processPart(part);
            }
          }
        }

        body[Coupon.camel[CouponKeys.image]!] = null;
        body[Coupon.camel[CouponKeys.imageBh]!] = null;

        if (couponImage != null) body[Coupon.camel[CouponKeys.image]!] = couponImage;
        if (couponImageBh != null) body[Coupon.camel[CouponKeys.imageBh]!] = couponImageBh;

        final dao = CouponDAO(session, context);
        final coupon = Coupon.fromMap(body, Convention.camel);
        final affected = create ? await dao.insert(coupon) : await dao.update(coupon);

        if (affected == 1) {
          await Cache().clear(api.redis, CacheKeys.coupon(couponId));
          await Cache().clearAll(api.redis, CacheKeys.coupons);
        }

        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String couponId) => _createOrUpdate(request, couponId, true);

  Future<Response> _update(Request request, String couponId) => _createOrUpdate(request, couponId, false);

  Future<Response> _patch(Request request, String couponId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final start = tryParseBool(body["start"]);
        final finish = tryParseBool(body["finish"]);
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (start == null && finish == null && blocked == null && archived == null)
          return api.badRequest(errorBrokenLogicEx("start, finish, blocked or archived"));
        final patched = await CouponDAO(session, context).patch(
          couponId,
          start: start,
          finish: finish,
          blocked: blocked,
          archived: archived,
        );
        if (patched == 1) {
          await Cache().clear(api.redis, CacheKeys.coupon(couponId));
          await Cache().clearAll(api.redis, CacheKeys.coupons);
        }
        return api.accepted({"affected": patched});
      });

  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final coupons = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (coupons?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await CouponDAO(session, context).reorder(coupons!);
        return api.accepted({"affected": reordered});
      });

  /// Issues a coupon to the user.
  /// Required roles: pos or admin
  /// Response status codes: 200, 204, 400, 401, 403, 404, 500
  Future<Response> _issue(Request request, String couponId, String type, String value) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final codeType = CodeTypeCode.fromCodeOrNull(tryParseInt(type));
        if (codeType == null) return api.badRequest(errorInvalidParameterRange("codeType", "Enum"));

        final userDAO = UserDAO(session, context);
        final userCouponDAO = UserCouponDAO(session, context);

        String? userId = _isUserIdentity(codeType, value);
        if (userId == null) {
          final user = await userDAO.selectByUserCardNumber(value);
          userId = user?.userId;
          if (userId == null) return api.notFound(errorObjectNotFound);
        }

        final (inserted, userCouponId) = await userCouponDAO.issue(couponId, userId);

        await SendMessage(context).sendUserCouponMessage(request, session, userCouponId, ActionType.userCouponCreated);
        await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        await Cache().clearAll(api.redis, CacheKeys.userUserCard(userId, "*"));

        return api.json({
          "affected": inserted
          //"userCoupon": userCoupon?.toMap(Convention.camel),
        });
      });

  /// User wants to redeem a coupon.
  /// Required roles: pos or admin.
  /// Response status codes: 200, 400, 401, 403, 404, 500
  Future<Response> _redeem(Request request, String type, String value) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        final hasPosRole = session.userRoles.contains(UserRole.pos);
        final hasAdminRole = session.userRoles.contains(UserRole.admin);
        final allowedRoles = hasPosRole || hasAdminRole;
        if (!allowedRoles) return api.forbidden(errorUserRoleMissing);

        final codeType = CodeTypeCode.fromCodeOrNull(tryParseInt(type));
        if (codeType == null) return api.badRequest(errorInvalidParameterRange("codeType", "Enum"));

        final userCouponDAO = UserCouponDAO(session, context);

        String? userCouponId = _isUserCoupon(codeType, value);
        if (userCouponId == null) return api.notFound(errorObjectNotFound);

        final updated = await userCouponDAO.redeem(userCouponId, session.userId);
        if (updated == 1)
          await SendMessage(context)
              .sendUserCouponMessage(request, session, userCouponId, ActionType.userCouponRedeemed);

        final userCoupon = await userCouponDAO.select(userCouponId);
        if (userCoupon != null) {
          //await _sendMessage(session, ActionType.userCouponRedeemed, userCoupon);
          await Cache().clear(api.redis, CacheKeys.userUserCards(userCoupon.userId));
          // Don't know which card to clear, so clear all
          await Cache().clearAll(api.redis, CacheKeys.userUserCard(userCoupon.userId, "*"));
        }

        if (updated != 1) return api.internalError(errorBrokenLogicEx("User coupon not redeemed"));

        return api.json({"affected": updated});
      });

  Router get router {
    final router = Router();

    router.post("/issue/<id|$idRegExp>/<type|[0-9]{1,3}>/<value|.{1,2048}>", _issue);
    router.put("/redeem/<type|[0-9]{1,3}>/<value|.{1,2048}>", _redeem);

    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.get("/", _list);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

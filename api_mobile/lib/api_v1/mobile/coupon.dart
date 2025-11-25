import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../cache.dart";
import "../../data_access_objects/mobile/coupon.dart";
import "../../data_access_objects/send_message.dart";
import "../../implementations/api_shelf2.dart";
import "../../utils/storage.dart";

class CouponHandler extends ApiServerHandler {
  final MobileApi _api;
  CouponHandler(this._api) : super(_api);

  Future<Response> _detail(Request request, String couponId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.coupon(couponId);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final coupon = await CouponDAO(session, context).select(couponId);
          if (coupon == null) return _api.noContent();

          json = coupon.toMap(Convention.camel);
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, "coupon": json});
      });

  Future<Response> _newest(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final country = CountryCode.fromCodeOrNull(query["country"]) ?? session.country;
        if (country == null) return _api.badRequest(errorInvalidParameterType("country", "Country"));

        final cacheKey = CacheKeys.newestCoupons(country);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final coupons = await CouponDAO(session, context).selectNewest(country);
          if (coupons == null) return _api.noContent();
          json = {
            "length": coupons.length,
            "coupons": coupons.map((e) => e.toMap(Convention.camel)).toList(),
          };
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _nearest(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final lon = tryParseDouble(query["lon"]);
        final lat = tryParseDouble(query["lat"]);
        if (lon == null || lat == null) return _api.badRequest(errorInvalidParameterType("lon / lat", "double"));

        final cacheKey = CacheKeys.nearestCoupons(lon, lat);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final coupons = await CouponDAO(session, context).selectNearest(lon, lat);
          if (coupons == null) return _api.noContent();
          json = {
            "length": coupons.length,
            "coupons": coupons.map((e) => e.toMap(Convention.camel)).toList(),
          };
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _category(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final categoryCode = tryParseInt(query["category"]);
        if (categoryCode == null) return _api.badRequest(errorInvalidParameterType("category", "int"));
        final category = ClientCategoryCode.fromCodeOrNull(categoryCode);
        if (category == null) return _api.badRequest(errorInvalidParameterType("category", "ClientCategory"));
        final country = CountryCode.fromCodeOrNull(query["country"]) ?? session.country;
        if (country == null) return _api.badRequest(errorInvalidParameterType("country", "Country"));

        final cacheKey = CacheKeys.couponsInCategory(country, category);
        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final coupons =
              await CouponDAO(session, context).selectFromCategory(country: country, categoryCode: categoryCode);
          json = {
            "length": coupons.length,
            "coupons": coupons.map((e) => e.toMap(Convention.camel)).toList(),
          };

          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _take(Request request, String couponId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final (takeResult, cardId, userCardId, userCouponId) = await CouponDAO(session, context).take(couponId);

        if (takeResult != CouponTakeResult.ok) {
          if (takeResult == CouponTakeResult.userAlreadyHasCoupon) return _api.notAllowed(errorMoreObjectsFound);
          if (takeResult == CouponTakeResult.userIssueLimitReached) return _api.notAllowed(errorMoreObjectsFound);
          if (takeResult == CouponTakeResult.couponNotFound) return _api.notFound(errorObjectNotFound);
          return _api.forbidden(errorBrokenLogicEx("Take result code: ${takeResult.code} (${takeResult.name})"));
        }

        if (userCouponId == null) return _api.notAllowed(errorObjectNotFound);

        await SendMessage(context).sendUserCouponMessage(request, session, userCouponId, ActionType.userCouponCreated);
        await Cache().clear(_api.redis, CacheKeys.userUserCards(session.userId));
        await Cache().clearAll(_api.redis, CacheKeys.userUserCard(session.userId, "*"));

        return _api.accepted({
          "cardId": cardId,
          "userCardId": userCardId,
          "userCouponId": userCouponId,
        });
      });

  /// Returns list of "Coupon" entities (except "meta" property). Url parameters:
  /// - country: country code (required)
  /// - limit: integer - limit of number of entities in response (optional)
  /// - lon: double - gps coord (optiquired with parameter "lat")
  /// - lat: double - gps coord (optiquired with parameter "lon")
  /// - category: int - must be value from "ClientCategory" enum (optional)
  ///
  /// Http status codes: 200, 400, 500
  Future<Response> _listTop(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final country = CountryCode.fromCodeOrNull(query["country"]);
        if (country == null) return _api.badRequest(errorInvalidParameterType("country", "value from country enum"));
        final limit = int.tryParse(query["limit"] ?? "") ?? 10;
        final lon = num.tryParse(query["lon"] ?? "");
        final lat = num.tryParse(query["lat"] ?? "");

        if (!((lon == null && lat == null) || (lon != null && lat != null)))
          return api
              .badRequest(errorInvalidParameterType("lon / lat", "lon / lat can be either both null or not null"));

        final clientCategory = ClientCategoryCode.fromCodeOrNull(int.tryParse(query["category"] ?? ""));

        final couponDAO = CouponDAO(session, context);
        final coupons = await couponDAO.list(null, 1, limit,
            country: country,
            clientCategory: clientCategory,
            lon: lon,
            lat: lat,
            couponTypes: [CouponType.universal.code, CouponType.array.code]);

        final dataObject = coupons.map((e) {
          e.meta = null;
          e.clientLogo = _api.storageUrl(e.clientLogo, StorageObject.client);
          return e.toMap(Convention.camel);
        }).toList();

        return _api.json({
          "length": dataObject.length,
          "coupons": dataObject,
        });
      });

  // /v1/coupon
  Router get router {
    final router = Router();

    router.get("/newest", _newest);
    router.get("/nearest", _nearest);
    router.get("/category", _category);

    router.post("/take/<couponId|${_api.idRegExp}>", _take);

    router.get("/top", _listTop);

    router.get("/<couponId|${_api.idRegExp}>", _detail);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

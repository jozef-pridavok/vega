import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/mobile/card.dart";
import "../session.dart";

class CardHandler extends ApiServerHandler {
  CardHandler(super.api);

  /// Returns list of cards. Url parameters:
  /// - cache: timestamp of cached data (optional)
  /// - noCache: if true, ignores cache (optional)
  /// - country: country code (optional)
  ///
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final query = request.url.queryParameters;
        final country = query["country"];

        final cacheKey = CacheKeys.coupons;
        var (isCached, timestamp) = await Cache().isCached(api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return api.cached();

        JsonObject? json = await Cache().getJson(api.redis, cacheKey);
        if (json == null) {
          final cards = await CardDAO(context).list(country: country);
          if (cards.isEmpty) return api.noContent();
          json = {
            "length": cards.length,
            "coupons": cards.map((e) => e.toMap(Convention.camel)).toList(),
          };
          timestamp = await Cache().putJson(api.redis, cacheKey, json);
        }

        return api.json({"cache": timestamp, ...json});
      });

  /// Returns top cards for user (country based on session). Url parameters:
  /// - limit: number of cards to return (optional)
  ///
  Future<Response> _top(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        final query = request.url.queryParameters;
        final limit = int.tryParse(query["limit"] ?? "");
        final country = session.country;

        final cards = await CardDAO(context).top(country: country, limit: limit);
        if (cards.isEmpty) return api.noContent();

        final json = {
          "length": cards.length,
          "cards": cards.map((e) => e.toMap(Convention.camel)).toList(),
        };
        return api.json(json);
      });

  /// Search for cards specified by term. Country is based on session.
  /// Url parameters:
  /// - term: search term (required)
  /// - limit: number of cards to return (optional)
  Future<Response> _search(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        final query = request.url.queryParameters;
        final limit = int.tryParse(query["limit"] ?? "");
        final country = session.country;
        final term = query["term"];
        final otherCountries = tryParseBool(query["otherCountries"]) ?? false;

        if (term == null) return api.badRequest(errorMissingParameter("term"));

        final cards = await CardDAO(context).search(
          term: term,
          country: country,
          limit: limit,
          otherCountries: otherCountries,
        );
        if (cards.isEmpty) return api.noContent();

        final json = {
          "length": cards.length,
          "cards": cards.map((e) => e.toMap(Convention.camel)).toList(),
        };
        return api.json(json);
      });

  // /v1/card
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.get("/top", _top);
    router.get("/search", _search);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

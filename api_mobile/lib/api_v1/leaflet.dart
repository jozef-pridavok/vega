import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../data_access_objects/leaflet_detail.dart";
import "../data_access_objects/leaflet_overview.dart";
import "../implementations/api_shelf2.dart";
import "./session.dart";

class LeafletHandler extends ApiServerHandler {
  final MobileApi _api;
  LeafletHandler(this._api) : super(_api);

  /// Returns list of 'LeafletDetail' entities. Url parameters:
  /// - cache: timestamp of cached data (optional)
  /// - noCache: if true, ignores cache (optional)
  ///
  /// Http status codes: 200, 208, 400, 500
  Future<Response> _listLeaflets(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;
        final cached = int.tryParse(query["cache"] ?? "");
        final noCache = tryParseBool(query["noCache"]) ?? false;

        final (json, isCached) = await LeafletDetailDAO(session, context).select(clientId, cached, noCache);

        if (isCached) return _api.cached();
        return _api.json(json!);
      });

  /// Returns list of 'LeafletOverview' entities. Url parameters:
  /// - cache: timestamp of cached data (optional)
  /// - noCache: if true, ignores cache (optional)
  /// - country: country code (required)
  /// - limit: integer - limit of number of entities in response (optional)
  ///
  /// Http status codes: 200, 208, 400, 500
  Future<Response> _newest(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final query = request.url.queryParameters;
        final cached = int.tryParse(query["cache"] ?? "");
        final noCache = tryParseBool(query["noCache"]) ?? false;
        final country = CountryCode.fromCodeOrNull(query["country"]);
        final limit = int.tryParse(query["limit"] ?? "") ?? 25;
        if (country == null) return _api.badRequest(errorInvalidParameterType("country", "value from country enum"));

        final (json, isCached) = await LeafletOverviewDAO(session, context).newest(country, limit, cached, noCache);
        if (isCached) return _api.cached();

        return _api.json(json!);
      });

  // /v1/leaflet
  Router get router {
    final router = Router();

    router.get("/newest", _newest);
    router.get("/<clientId|${_api.idRegExp}>", _listLeaflets);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

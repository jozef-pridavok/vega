import "package:api_mobile/api_v1/session.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../cache.dart";
import "../data_access_objects/mobile/client_location.dart";
import "../implementations/api_shelf2.dart";
import "../implementations/api_shelf_v1.dart";

class ClientLocationHandler {
  final ApiServer _api;
  ClientLocationHandler(this._api);

  Future<Response> _list(Request request, String clientId) async {
    try {
      final query = request.url.queryParameters;

      final cacheKey = CacheKeys.locations(clientId);
      var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
      if (isCached) return _api.cached();

      JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
      if (json == null) {
        final sql = """
            SELECT client_id, location_id, type, rank, name, address_line_1, address_line_2, city, zip, state, country, 
                  phone, email, website, opening_hours, opening_hours_exceptions, latitude, longitude
            FROM locations
            WHERE client_id = @client_id AND deleted_at IS NULL
            ORDER BY rank
          """
            .removeEmptyLines();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        _api.log.verbose(sql);
        _api.log.verbose(sqlParams.toString());

        final rows = await _api.select(sql, params: sqlParams);
        final locations = rows.map((row) => Location.fromMap(row, Location.snake)).cast<Location>();

        json = {
          "length": locations.length,
          "locations": locations.map((e) => e.toMap(Location.camel)).toList(),
        };

        timestamp = await Cache().putJson(_api.redis, cacheKey, json);
      }

      return _api.json({"cache": timestamp, ...json});
    } catch (ex, st) {
      _api.log.error(ex.toString(), st);
      return _api.internalError(errorUnexpectedException(ex));
    }
  }

  // /v1/client_location
  Router get router {
    final router = Router();
    router.get("/<clientId|${_api.idRegExp}>", _list);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

class ClientLocationHandler2 extends ApiServerHandler {
  //ClientLocationHandler2(super.api);

  final MobileApi _api;
  ClientLocationHandler2(this._api) : super(_api);

  Future<Response> _list(Request req, String clientId) async => withRequestLog((context) async {
        log.logRequest(context, req.toLogRequest());
        final installationId = req.context["iid"] as String;
        //final session = await (api as MobileApi).getSession(installationId);
        final session = await _api.getSession(installationId);
        log.debug("session.userId: ${session.userId}");
        final locations = await ClientLocationDAO(context).select(clientId);
        final json = {
          "length": locations.length,
          "locations": locations.map((e) => e.toMap(Location.camel)).toList(),
        };
        return api.json(json);
      });

  // /v1/client_location
  Router get router {
    final router = Router();

    router.get("/<clientId|$idRegExp>", _list);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}


// eof

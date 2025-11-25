import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../cache.dart";
import "../implementations/api_shelf2.dart";

class LocationHandler extends ApiServerHandler {
  final MobileApi _api;
  LocationHandler(this._api) : super(_api);

  Future<Response> _detail(Request request, String locationId) async => withRequestLog((context) async {
        final query = request.url.queryParameters;

        final sql = """
          SELECT client_id, location_id, type, rank, name, address_line_1, address_line_2, city, zip, state, country, 
                 phone, email, website, opening_hours, opening_hours_exceptions, latitude, longitude
          FROM locations
          WHERE location_id = @location_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"location_id": locationId};

        final cacheKey = CacheKeys.location(locationId);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          log.verbose(sql);
          log.verbose(sqlParams.toString());

          final rows = await _api.select(sql, params: sqlParams);
          if (rows.isEmpty) return _api.noContent();
          final location = Location.fromMap(rows.first, Location.snake);
          json = location.toMap(Location.camel);
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, "coupon": json});
      });

  // /v1/location
  Router get router {
    final router = Router();
    router.get("/<locationId|${_api.idRegExp}>", _detail);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

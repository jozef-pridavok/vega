import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/client_rating.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../data_access_objects/mobile/client.dart" as client_mobile;
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf2.dart";
import "../session.dart";

class ClientHandler extends ApiServerHandler {
  final MobileApi _api;
  ClientHandler(this._api) : super(_api);

  Future<Response> _detail(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.clientForUserType(clientId, session.userType ?? UserType.customer);
        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final clients = await client_mobile.ClientDAO(context).list(
            userType: session.userType,
            clientId: clientId,
          );
          if (clients.isEmpty) return _api.noContent();
          final client = clients.first;

          json = {
            "client": client.toMap(Client.camel),
          };

          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _rating(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = await request.body.asJson;
        final userId = session.userId;
        final clientId = body["clientId"] as String;

        final rating = tryParseInt(body["rating"]);
        if (rating == null || rating < 0 || rating > 5)
          return _api.badRequest(errorInvalidParameterType("Invalid rating", "value between 0 and 5"));
        final dao = ClientRatingDAO(context);
        await dao.upsert(
          userId: userId,
          clientId: clientId,
          rating: body["rating"] as int,
          language: session.language!,
          comment: body["comment"] as String?,
        );

        final currentClientRating = await dao.getClientRating(clientId: clientId);

        int? updated;
        if (currentClientRating != null) {
          updated = await ClientDAO(session, context).updateClientRating(userId, currentClientRating);

          final cacheKey = CacheKeys.client(clientId);
          await Cache().clearAll(_api.redis, cacheKey);
        }

        return _api.accepted({"affected": updated ?? 0});
      });

  Future<Response> _listRatings(Request request) async => withRequestLog((context) async {
        final query = request.url.queryParameters;
        final clientId = query["clientId"];
        final limit = tryParseInt(query["limit"]);
        final lang = query["lang"];
        if (clientId == null) return _api.badRequest(errorMissingParameter("clientId"));

        final dao = ClientRatingDAO(context);
        final ratings = await dao.list(
          clientId: clientId,
          language: lang,
          limit: limit,
        );

        return _api.json({
          "ratings": ratings,
        });
      });

  // /v1/client
  Router get router {
    final router = Router();
    router.get("/detail/<clientId|${_api.idRegExp}>", _detail);
    router.post("/rating", _rating);
    router.get("/ratings", _listRatings);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

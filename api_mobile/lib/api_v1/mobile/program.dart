import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/emit_card.dart";
import "../../data_access_objects/mobile/program.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf2.dart";
import "../session.dart";

class ProgramHandler extends ApiServerHandler {
  final MobileApi _api;
  ProgramHandler(this._api) : super(_api);

  Future<Response> _detail(Request request, String programId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.program(programId);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final program = await ProgramDAO(session, context).getDetail(programId: programId);
          if (program == null) return _api.noContent();

          json = {
            "detail": program.toMap(Convention.camel),
          };
          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _applyTag(Request request, String tagId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final dao = ProgramDAO(session, context);

        final (String? programId, String? clientId, int? points) = await dao.selectProgramTag(tagId);
        if (programId == null || clientId == null || points == null) return _api.notAllowed(errorObjectNotFound);

        final body = (await request.body.asJson) as JsonObject?;
        String? cardId = body?["cardId"] as String?;
        String? userCardId = body?["userCardId"] as String?;

        if (cardId == null && userCardId != null)
          return _api.badRequest(errorInvalidParameterType("cardId, userCardId ", "both or none"));
        if (cardId != null && userCardId == null)
          return _api.badRequest(errorInvalidParameterType("cardId, userCardId ", "both or none"));

        if (cardId == null || userCardId == null) {
          final userCards = await dao.selectUserCards(programId);
          if (userCards.isEmpty) {
            final emitCard = EmitCardDAO(context);
            final cardId = await emitCard.getDefaultCard(clientId);
            // Client has no default card
            if (cardId == null) {
              log.error("_applyTag: Client has no default card! TagId: $tagId");
              return _api.internalError(errorBrokenLogicEx("Client has no default card!"));
            }
          } else if (userCards.length > 1) {
            log.error("_applyTag: User has more than one card! TagId: $tagId");
            return _api.accepted({"userCards": userCards.map((userCard) => userCard.$2).toList()});
          }

          final userCard = userCards.first;
          cardId = userCard.$1;
          userCardId = userCard.$2;
        }

        final applied = await dao.applyTag(
          clientId: clientId,
          programId: programId,
          tagId: tagId,
          cardId: cardId,
          userCardId: userCardId,
          points: points,
        );
        if (applied == 0) return _api.internalError(errorBrokenLogicEx("Tag not applied!"));

        final userId = session.userId;

        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
        await Cache().clear(_api.redis, CacheKeys.userUserCard(userId, userCardId));

        return _api.created({"userCardId": userCardId});
      });

  // /v1/program
  Router get router {
    final router = Router();

    router.get("/detail/<programId|${_api.idRegExp}>", _detail);
    router.post("/tag/<tagId|${_api.idRegExp}>", _applyTag);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

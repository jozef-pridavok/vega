import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/card.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf2.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class CardHandler extends ApiServerHandler {
  CardHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        log.logRequest(context, request.toLogRequest());
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final search = query["search"];
        final limit = int.tryParse(query["limit"] ?? "");
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;

        final cards = await CardDAO(session, context).list(limit: limit, search: search, filter: filter);
        final json = cards.map((card) {
          card.logo = api.storageUrl(card.logo, StorageObject.card, timeStamp: card.updatedAt);
          return card.toMap(Convention.camel);
        }).toList();
        return api.json({
          "length": json.length,
          "cards": json,
        });
      });

  /// Creates new card or updates existing card.
  /// Required roles: pos or admin
  /// Response status codes: 201, 202, 400, 401, 403, 500
  Future<Response> _createOrUpdate(Request request, String cardId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? cardLogo;
        String? cardLogoBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (cardLogo != null) log.warning("Card image already set");
            cardLogo = "card_$cardId.${mediaType.subtype}";
            final filePath = api.storagePath(cardLogo!, StorageObject.card);
            log.debug("Saving card logo to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            cardLogoBh = await getImageBhFromFile(filePath) ?? "";
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

        body[Card.camel[CardKeys.logo]!] = null;
        body[Card.camel[CardKeys.logoBh]!] = null;

        if (cardLogo != null) body[Card.camel[CardKeys.logo]!] = cardLogo;
        if (cardLogoBh != null) body[Card.camel[CardKeys.logoBh]!] = cardLogoBh;

        final dao = CardDAO(session, context);
        final card = Card.fromMap(body, Convention.camel);
        final affected = create ? await dao.insert(card) : await dao.update(card);

        if (affected > 0) {
          final affectedUsers = await Cache().members(api.redis, CacheKeys.cardUsers(cardId));
          await Future.wait(affectedUsers.map((userId) => Cache().clear(api.redis, CacheKeys.userUserCards(userId))));
        }

        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String cardId) => _createOrUpdate(request, cardId, true);

  Future<Response> _update(Request request, String cardId) => _createOrUpdate(request, cardId, false);

  /// Updates - block or archive/unarchive client card.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  Future<Response> _patch(Request request, String cardId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (blocked == null && archived == null) return api.badRequest(errorBrokenLogicEx("blocked or archived"));
        final patched = await CardDAO(session, context).patch(
          cardId,
          blocked: blocked,
          archived: archived,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple cards.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reorder": [ "card1", "card5", "card2", "card6", ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final cards = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (cards?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));

        final reordered = await CardDAO(session, context).reorder(cards!);

        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/card
  Router get router {
    final router = Router();

    router.get("/", _list);

    router.put("/reorder", _reorder);

    router.post("/<id|$idRegExp>", _create);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

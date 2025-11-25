import "package:core_dart/core_algorithm.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/card.dart";
import "../../data_access_objects/mobile/user_card.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf2.dart";
import "../session.dart";
import "receipts/receipt.dart";

class UserCardHandler extends ApiServerHandler {
  final MobileApi _api;
  UserCardHandler(this._api) : super(_api);

  Future<Response> _detail(Request request, String userCardId, {ProcessResult? processResult}) async =>
      withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.userUserCard(userId, userCardId);

        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final userCard = await UserCardDAO(session, context).select(userCardId);
          if (userCard == null) return _api.noContent();

          json = {
            "detail": userCard.toMap(Convention.camel),
            if (processResult?.points != null) "points": processResult?.points,
            if (processResult?.receipt != null) "receipt": processResult?.receipt?.toMap(Convention.camel),
          };

          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final query = request.url.queryParameters;

        final cacheKey = CacheKeys.userUserCards(userId);
        var (isCached, timestamp) = await Cache().isCached(_api.redis, cacheKey, tryParseInt(query["cache"]));
        if (isCached) return _api.cached();

        JsonObject? json = await Cache().getJson(_api.redis, cacheKey);
        if (json == null) {
          final userCards = await UserCardDAO(session, context).selectAll();
          if (userCards == null) return _api.noContent();
          if (userCards.isEmpty) return _api.noContent();

          json = {
            "length": userCards.length,
            "userCards": userCards.map((e) => e.toMap(Convention.camel)).toList(),
          };

          timestamp = await Cache().putJson(_api.redis, cacheKey, json);
        }

        return _api.json({"cache": timestamp, ...json});
      });

  Future<Response> _create(Request request, String userCardId) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final body = (await request.body.asJson) as JsonObject;
        final cardId = body["cardId"] as String?;
        body[UserCard.camel[UserCardKeys.cardId]!] = (cardId?.isNotEmpty ?? false) ? cardId : null;
        body[UserCard.camel[UserCardKeys.userId]!] = userId;
        body[UserCard.camel[UserCardKeys.userCardId]!] = userCardId;
        final userCard = UserCard.fromMap(body, Convention.camel);

        final userCardDAO = UserCardDAO(session, context);
        final inserted = await userCardDAO.insert(userCard);
        if (inserted != 1) return _api.internalError(errorBrokenLogicEx("User card not created"));

        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));

        return _api.created({"affected": inserted});
      });

  Future<Response> _createByClient(Request request, String clientId) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final userCardDAO = UserCardDAO(session, context);

        final userCardId = await userCardDAO.issue(clientId, null, meta: {"userAdded": true});
        if (userCardId == null) return _api.internalError(errorBrokenLogicEx("User card not created"));

        final userCard = await userCardDAO.select(userCardId);
        if (userCard == null) return _api.internalError(errorBrokenLogicEx("User card not found"));

        final cardId = userCard.cardId;
        if (cardId == null) return _api.internalError(errorBrokenLogicEx("User card has no card"));

        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
        await Cache().addMember(_api.redis, CacheKeys.cardUsers(cardId), userId);

        return _api.created(userCard.toMap(Convention.camel));
      });

  Future<Response> _createByCard(Request request, String cardId) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final card = await CardDAO(session, context).selectById(cardId);
        if (card == null) return _api.notFound(errorObjectNotFound);

        if (card.clientId == null) return _api.badRequest(errorBrokenLogicEx("Card has no client"));

        final userCardDAO = UserCardDAO(session, context);
        final userCardId = await userCardDAO.issue(card.clientId!, cardId, meta: {"userAdded": true});
        if (userCardId == null) return _api.internalError(errorBrokenLogicEx("User card not created"));

        final userCard = await userCardDAO.select(userCardId);
        if (userCard == null) return _api.internalError(errorBrokenLogicEx("User card not found"));

        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
        await Cache().addMember(_api.redis, CacheKeys.cardUsers(cardId), userId);

        return _api.created(userCard.toMap(Convention.camel));
      });

  Future<Response> _update(Request request, String userCardId) async => withRequestLog((context) async {
        final userId = request.context["uid"] as String;
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final body = (await request.body.asJson) as JsonObject;

        final userCardDAO = UserCardDAO(session, context);
        final updated = await userCardDAO.update(
          userCardId,
          userId,
          codeType: body["codeType"] is int ? body["codeType"] as int : null,
          number: body["number"] as String?,
          name: body["name"] as String?,
          notes: body["notes"] as String?,
          color: body["color"] as String?,
        );
        if (updated != 1) return _api.internalError(errorBrokenLogicEx("User card not updated"));

        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
        await Cache().clear(_api.redis, CacheKeys.userUserCard(userId, userCardId));

        return _api.accepted({"affected": updated});
      });

  Future<Response> _delete(Request request, String userCardId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final userId = request.context["uid"] as String;

        final userCardDAO = UserCardDAO(session, context);
        final deleted = await userCardDAO.delete(userCardId);

        if (deleted > 0) {
          //await SqlCache().clear(_api.redis, "user:$userId:userCards");
          //await SqlCache().clear(_api.redis, "user:$userId:detail:$userCardId");
          await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
          await Cache().clear(_api.redis, CacheKeys.userUserCard(userId, userCardId));
          await Cache().removeMember(_api.redis, CacheKeys.cardUsers(userCardId), userId);
        }

        return _api.accepted({"affected": deleted});
      });

  // Create a new user card based on a receipt. Receipt is posted into body and after that analyzed.
  // A new user card is created if the receipt is valid  and client.meta->>@provider->autoNewUserCard is set to true.
  // Url parameters:
  // - receipt: Receipt to be processed (qr code)
  // Body:
  // - Receipt body (payload)
  Future<Response> _createByReceipt(Request request, String receipt) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final userId = request.context["uid"] as String;

        final cryptex = SimpleCipher(_api.config.secretReceiptKey);

        //
        //_api.log.verbose("Receipt: ${cryptex.encrypt('O-221DF8D7344847E59DF8D73448A7E555')}");
        //_api.log.verbose("Receipt: ${cryptex.encrypt('debug://receipt?skEkasaSk=12345&id=2&price=19.99')}");
        //_api.log.verbose("Receipt: ${cryptex.encrypt('https://ekuatia.set.gov.py/consultas/qr?nVersion=150&Id=01800160967099006002467022023040812610764875&dFeEmiDE=323032332d30342d30385431333a30303a3434&dRucRec=80124528&dTotGralOpe=296962.00000000&dTotIVA=19113.39740261&cItems=24&DigestValue=72414a4d77764274574639436a4b7166784c785676754f525642503732325263693545524b496a766941513d&IdCSC=0001&cHashQR=44c9551f83fa3bb1a201176c2ded03d61d8d47ed9dfe403a9a6e443cad80e86a')}");
        final decodedReceipt = cryptex.decrypt(receipt);
        final implementation = ReceiptHandler.determine(_api, session, context, decodedReceipt);
        if (implementation == null) return _api.notFound(errorReceiptImplementationNotFound);

        final body = await request.body.asString;
        final processResult = await implementation.process(decodedReceipt, body);
        if (processResult == null) return _api.notFound(errorReceiptInvalid);
        final userCardId = processResult.userCardId;
        if (userCardId == null) return _api.notFound(errorReceiptInvalid);

        //await SqlCache().clear(_api.redis, "user:$userId:userCards");
        await Cache().clear(_api.redis, CacheKeys.userUserCards(userId));
        // If receipt added to existing user card, clear the detail cache
        await Cache().clear(_api.redis, CacheKeys.userUserCard(userId, userCardId));
        await Cache().addMember(_api.redis, CacheKeys.cardUsers(processResult.cardId), userId);

        return _detail(request, userCardId, processResult: processResult);
      });

  // /v1/user_card
  Router get router {
    final router = Router();

    router.get("/detail/<userCardId|${_api.idRegExp}>", _detail);

    //router.post("/front/<userCardId|[a-zA-Z0-9]{10}>", (req, id) => _setPhoto(req, id, true));
    //router.post("/back/<userCardId|[a-zA-Z0-9]{10}>", (req, id) => _setPhoto(req, id, false));

    router.post("/receipt/<receipt>", _createByReceipt);
    router.post("/by_client/<clientId|${_api.idRegExp}>", _createByClient);
    router.post("/by_card/<cardId|${_api.idRegExp}>", _createByCard);
    router.post("/<userCardId|${_api.idRegExp}>", _create);
    router.put("/<userCardId|${_api.idRegExp}>", _update);
    router.delete("/<userCardId|${_api.idRegExp}>", _delete);

    router.get("/", _list);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

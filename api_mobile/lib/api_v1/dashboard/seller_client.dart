import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/seller_client.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class SellerClientHandler extends ApiServerHandler {
  SellerClientHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final userId = request.context["uid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final country = query["country"];
        final like = query["like"] ?? "";
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final blocked = tryParseBool(query["blocked"]);

        final clients = await SellerClientDAO(session, context).readAll(
          sellerId: userId,
          like: like,
          country: country,
          filter: filter,
          blocked: blocked,
        );
        if (clients.isEmpty) return api.noContent();

        final json = clients.map((client) {
          client.logo = api.storageUrl(client.logo, StorageObject.client, timeStamp: client.updatedAt);
          return client.toMap(Client.camel);
        }).toList();
        return api.json({"length": clients.length, "clients": json});
      });

  Future<Response> _createOrUpdate(Request request, String clientId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final userId = request.context["uid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? clientLogoImage;
        String? clientLogoImageBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (clientLogoImage != null) log.warning("Client logo already set");
            clientLogoImage = "logo_$clientId.${mediaType.subtype}";
            final filePath = api.storagePath(clientLogoImage!, StorageObject.client);
            log.debug("Saving client logo to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            clientLogoImageBh = await getImageBhFromFile(filePath) ?? "";
          }
        }

        final contentType = request.headers["Content-Type"];
        final mediaType = MediaType.parse(contentType ?? "");
        if (mediaType.type == "application" && mediaType.subtype == "json") {
          body = (await request.body.asJson) as JsonObject? ?? {};
        } else {
          if (request.isMultipart) {
            await for (final part in request.parts) {
              await processPart(part);
            }
          }
        }

        body[Client.camel[ClientKeys.logo]!] = null;
        body[Client.camel[ClientKeys.logoBh]!] = null;

        if (clientLogoImage != null) body[Client.camel[ClientKeys.logo]!] = clientLogoImage;
        if (clientLogoImageBh != null) body[Client.camel[ClientKeys.logoBh]!] = clientLogoImageBh;

        final dao = SellerClientDAO(session, context);
        final client = Client.fromMap(body, Client.camel);
        final affected = create ? await dao.create(client, userId) : await dao.update(client);
        if (create && affected == -1) return api.badRequest(errorFailedToSaveData);

        final cacheKey = CacheKeys.client(clientId);
        await Cache().clearAll(api.redis, cacheKey);

        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String clientId) => _createOrUpdate(request, clientId, true);

  Future<Response> _update(Request request, String clientId) => _createOrUpdate(request, clientId, false);

  Future<Response> _patch(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        final demoCredit = tryParseInt(body["demoCredit"]);
        if (blocked == null && archived == null && demoCredit == null)
          return api.badRequest(errorBrokenLogicEx("blocked or archived"));
        final patched = await SellerClientDAO(session, context)
            .patch(clientId, blocked: blocked, archived: archived, demoCredit: demoCredit);

        final cacheKey = CacheKeys.client(clientId);
        await Cache().clearAll(api.redis, cacheKey);

        return api.accepted({"affected": patched});
      });

  // /v1/dashboard/seller/client
  Router get router {
    final router = Router();

    router.post("/<clientId|$idRegExp>", _create);
    router.put("/<clientId|$idRegExp>", _update);
    router.patch("/<clientId|$idRegExp>", _patch);

    router.get("/", _list);

    return router;
  }
}

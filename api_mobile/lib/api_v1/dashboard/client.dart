import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class ClientHandler extends ApiServerHandler {
  ClientHandler(super.api);

  /// Returns details about client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 204, 403, 500
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _detail(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final client = await ClientDAO(session, context).select(session.clientId!);
        if (client == null) return api.noContent();
        client.logo = api.storageUrl(client.logo, StorageObject.client, timeStamp: client.updatedAt);
        final json = client.toMap(Client.camel);
        return api.json({"client": json});
      });

  /// Update existing client.
  /// Required roles: pos or admin
  /// Response status codes: 202, 403, 500
  /// Notes:
  ///   client_id is determined by the session.
  Future<Response> _update(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final clientId = session.clientId!;

        JsonObject body = {};
        String? clientLogoImage;
        String? clientLogoImageBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (clientLogoImage != null) api.log.warning("Program client logo already set");
            clientLogoImage = "logo_$clientId.${mediaType.subtype}";
            final filePath = api.storagePath(clientLogoImage!, StorageObject.client);
            log.debug("Saving logo image to $filePath");
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

        final dao = ClientDAO(session, context);
        final client = Client.fromMap(body, Client.camel);

        final updated = await dao.update(client);

        if (updated > 0) {
          final cacheKey = CacheKeys.client(clientId);
          await Cache().clearAll(api.redis, cacheKey);
        }

        return api.accepted({"affected": updated});
      });

  // /v1/dashboard/client
  Router get router {
    final router = Router();

    router.get("/detail/", _detail);
    router.put("/", _update);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

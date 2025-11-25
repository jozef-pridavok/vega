import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/dashboard/program.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class ProgramHandler extends ApiServerHandler {
  ProgramHandler(super.api);

  /// Returns list of programs for client.
  /// Required roles: pos or admin
  /// Response status codes: 200, 400, 401, 403, 500
  /// Parameters: search, filter, limit.
  ///   filter: 1 - active, 2 - prepared, 3 - finished, 4 - archived. Default is 1.
  ///   limit: number of records to return. Skip to return all programs.
  ///   search: optional - search string for program name.
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        final query = request.url.queryParameters;
        final search = query["search"];
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");
        final dao = ProgramDAO(session, context);
        final programs = await dao.list(filter: filter, limit: limit, search: search);
        if (programs.isEmpty) return api.noContent();
        final json = programs.map((program) {
          program.image = api.storageUrl(program.image, StorageObject.program, timeStamp: program.updatedAt);
          return program.toMap(Convention.camel);
        }).toList();
        return api.json({
          "length": json.length,
          "programs": json,
        });
      });

  Future<Response> _createOrUpdate(Request request, String programId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? programImage;
        String? programImageBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          print(mediaType);
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (programImage != null) log.warning("Program image already set");
            programImage = "program_$programId.${mediaType.subtype}";
            final filePath = api.storagePath(programImage!, StorageObject.program);
            log.debug("Saving program image to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            programImageBh = await getImageBhFromFile(filePath) ?? "";
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

        body[Program.camel[ProgramKeys.image]!] = null;
        body[Program.camel[ProgramKeys.imageBh]!] = null;

        if (programImage != null) body[Program.camel[ProgramKeys.image]!] = programImage;
        if (programImageBh != null) body[Program.camel[ProgramKeys.imageBh]!] = programImageBh;

        final dao = ProgramDAO(session, context);
        final program = Program.fromMap(body, Convention.camel);
        final affected = create ? await dao.insert(program) : await dao.update(program);

        if (affected > 0) {
          final cardId = program.cardId;
          final affectedUsers = await Cache().members(api.redis, CacheKeys.cardUsers(cardId));
          log.debug("Affected users: $affectedUsers");
          await Future.wait(affectedUsers.map((userId) => Cache().clear(api.redis, CacheKeys.userUserCards(userId))));
        }

        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String programId) => _createOrUpdate(request, programId, true);

  Future<Response> _update(Request request, String programId) => _createOrUpdate(request, programId, false);

  Future<Response> _patch(Request request, String programId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final start = tryParseBool(body["start"]);
        final finish = tryParseBool(body["finish"]);
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (start == null && finish == null && blocked == null && archived == null)
          return api.badRequest(errorBrokenLogicEx("start, finish, blocked or archived"));

        final (patched, cardId) = await ProgramDAO(session, context).patch(
          programId,
          start: start,
          finish: finish,
          blocked: blocked,
          archived: archived,
        );

        if (patched > 0) {
          final affectedUsers = await Cache().members(api.redis, CacheKeys.cardUsers(cardId));
          log.debug("Affected users: $affectedUsers");
          await Future.wait(affectedUsers.map(
            (userId) async {
              await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
              await Cache().clear(api.redis, CacheKeys.userUserCard(userId, "*")); // TODO: to vymazať len jednu
            },
          ));
        }

        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple programs.
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reorder": ["program6", "program1", "program3" ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final programs = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (programs?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ProgramDAO(session, context).reorder(programs!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/program
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

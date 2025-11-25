import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/program_reward.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class ProgramRewardHandler extends ApiServerHandler {
  ProgramRewardHandler(super.api);

  Future<Response> _list(Request request, String programId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final search = query["search"];
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;
        final limit = int.tryParse(query["limit"] ?? "");

        final resultSet =
            await RewardDAO(session, context).list(programId, filter: filter, limit: limit, search: search);
        final rewards = resultSet.map((e) {
          return e.toMap(Convention.camel);
        }).toList();

        return api.json({
          "length": rewards.length,
          "program_rewards": rewards,
        });
      });

  Future<Response> _createOrUpdate(Request request, String rewardId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? rewardImage;
        String? rewardImageBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          print(mediaType);
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (rewardImage != null) log.warning("Reward image already set");
            rewardImage = "reward_$rewardId.${mediaType.subtype}";
            final filePath = api.storagePath(rewardImage!, StorageObject.reward);
            log.debug("Saving reward image to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            rewardImageBh = await getImageBhFromFile(filePath) ?? "";
          }
        }

        final contentType = request.headers["Content-Type"];
        final mediaType = MediaType.parse(contentType ?? "");
        if (mediaType.type == "application" && mediaType.subtype == "json") {
          body = (await request.body.asJson) as JsonObject;
        } else {
          if (request.isMultipart) {
            await for (final part in request.parts) {
              await processPart(part);
            }
          }
        }

        body[Reward.camel[RewardKeys.image]!] = null;
        body[Reward.camel[RewardKeys.imageBh]!] = null;

        if (rewardImage != null) body[Reward.camel[RewardKeys.image]!] = rewardImage;
        if (rewardImageBh != null) body[Reward.camel[RewardKeys.imageBh]!] = rewardImageBh;

        final dao = RewardDAO(session, context);
        final reward = Reward.fromMap(body, Convention.camel);
        final affected = create ? await dao.insert(reward) : await dao.update(reward);

        if (affected > 0) {
          //await Cache().clearAll(_api.redis, CacheKeys.userUserCards("*"));
        }

        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String rewardId) => _createOrUpdate(request, rewardId, true);

  Future<Response> _update(Request request, String rewardId) => _createOrUpdate(request, rewardId, false);

  Future<Response> _patch(Request request, String rewardId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);
        //final rewardIds = rewardId != null ? [rewardId] : (await request.body.asJson) as List<String>;
        final body = (await request.body.asJson) as JsonObject;
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (blocked == null && archived == null) return api.badRequest(errorBrokenLogicEx("blocked or archived"));
        final patched = await RewardDAO(session, context).patch(rewardId, blocked: blocked, archived: archived);
        return api.accepted({"affected": patched});
      });

  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final rewards = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (rewards?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await RewardDAO(session, context).reorder(rewards!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/program_reward
  Router get router {
    final router = Router();

    router.get("/program/<id|$idRegExp>", _list);

    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof


// eof

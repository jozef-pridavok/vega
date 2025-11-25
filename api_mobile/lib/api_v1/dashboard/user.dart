import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/dashboard/client.dart";
import "../../data_access_objects/user.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/send_message.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class UserHandler extends ApiServerHandler {
  UserHandler(super.api);

  Future<Response> _listOne(Request request, String userId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        if (session.clientId == null) return api.forbidden(errorNoClientId);

        final user = await UserDAO(session, context).selectById(userId);
        if (user == null) return api.noContent();

        return api.json({
          "user": user.toMap(User.camel),
        });
      });

  Future<Response> _message(Request request, String userId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        final body = cast<JsonObject>(await request.body.asJson);

        final subject = body?["subject"] as String?;
        final message = body?["body"] as String?;
        if (message?.isEmpty ?? true) return api.badRequest(errorMissingParameter("message body is required"));

        final List<MessageType> messageTypes =
            MessageTypeCode.fromCodes((body?["messageTypes"] as List<dynamic>?)?.cast<int>() ?? []);

        if (messageTypes.isEmpty) return api.badRequest(errorMissingParameter("messageTypes"));

        final client = await ClientDAO(session, context).select(session.clientId!);

        final error = await sendMessageToUser(
          api,
          session,
          messageTypes: messageTypes,
          userId: userId,
          subject: subject,
          body: message!,
          payload: {
            "clientId": session.clientId,
            if (client != null) ...{
              "clientName": client.name,
              "clientLogo": api.storageUrl(client.logo, StorageObject.client),
            },
          },
        );

        return api.json({
          "ok": error == null,
          if (error != null) "error": {"code": error.code, "message": error.message},
        });
      });

  // /v1/dashboard/user
  Router get router {
    final router = Router();

    router.get("/<userId|$idRegExp>", _listOne);
    router.post("/message/<userId|$idRegExp>", _message);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

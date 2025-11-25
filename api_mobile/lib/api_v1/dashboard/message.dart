import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/check_role.dart";
import "../../data_access_objects/dashboard/message.dart";
import "../../extensions/request_body.dart";
import "../session.dart";

class MessageHandler extends ApiServerHandler {
  MessageHandler(super.api);

  /// Creates new message to be delivered to specific user.
  /// Required roles: pos or admin
  /// Response status codes:  201, 400, 401, 403, 404
  Future<Response> _createMessage(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final target = query["target"]?.split(",");
        if (target == null) return api.badRequest(errorMissingParameter("query: target"));
        final List<MessageType> messageTypes = [];
        for (final messageType in target) {
          final parsedType = MessageTypeCode.fromCodeOrNull(int.tryParse(messageType.trim()));
          if (parsedType == null) {
            return api.badRequest(errorInvalidParameterType("query: target", "target should be in MessageTypeCode"));
          }
          messageTypes.add(parsedType);
        }

        final body = (await request.body.asJson) as JsonObject;
        final messageDao = MessageDAO(session, context);
        int affected = 0;
        for (final messageType in messageTypes) {
          final messageId = uuid();
          final insertedMessage = await messageDao.insert(
            messageId: messageId,
            messageType: messageType,
            toId: body["userId"] as String,
            subject: body["subject"] as String?,
            body: body["body"] as String?,
            payload: body["payload"] as JsonObject?,
          );
          if (insertedMessage != 1)
            return api.internalError(errorBrokenLogicEx("error occurred while creating message"));

          final inserted = await messageDao.insertDeliveryMessage(
            deliveryMessageId: uuid(),
            messageId: messageId,
            userId: body["userId"] as String,
            messageType: messageType,
            deviceToken: body["deviceToken"] as String?,
            email: body["email"] as String?,
            phone: body["phone"] as String?,
            subject: body["subject"] as String?,
            body: body["body"] as String?,
            payload: body["payload"] as JsonObject?,
          );
          if (inserted != 1) return api.internalError(errorBrokenLogicEx("Delivery message not created"));
          affected += 1;
        }
        return api.created({"affected": affected});
      });

  // /v1/dashboard/message
  Router get router {
    final router = Router();

    router.post("/for_delivery", _createMessage);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

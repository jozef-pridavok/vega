import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../extensions/request_body.dart";
import "../implementations/api_shelf2.dart";
import "session.dart";

class MessageHandler extends ApiServerHandler {
  final MobileApi _api;
  MessageHandler(this._api) : super(_api);

  // TODO: to be obsolete

  /// Creates one or multiple delivery_message(s) to be delivered to one or multiple user(s).
  /// Required roles: none or pos or admin or superadmin
  /// Response status codes:  201, 400, 401, 403, 404
  Future<Response> _createMessage(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);

        final hasPosRole = session.userRoles.contains(UserRole.pos);
        final hasAdminRole = session.userRoles.contains(UserRole.admin);
        final hasSuperAdminRole = session.userRoles.contains(UserRole.superadmin);
        final allowedRoles = hasPosRole || hasAdminRole || hasSuperAdminRole;

        final body = (await request.body.asJson) as JsonObject;
        final fromParticipant = MessageParticipantCode.fromCodeOrNull(body["fromParticipant"]);
        final toParticipant = MessageParticipantCode.fromCodeOrNull(body["toParticipant"]);
        final String? fromId, toId;
        switch (fromParticipant) {
          case MessageParticipant.system:
            if (!hasAdminRole && !hasSuperAdminRole) return _api.unauthorized(errorUserRoleMissing);
            fromId = null;
          case MessageParticipant.user:
            fromId = session.userId;
          case MessageParticipant.client:
            if (session.clientId == null) return _api.unauthorized(errorNoClientId);
            fromId = session.clientId;
          case MessageParticipant.allUsers:
          case MessageParticipant.allClients:
            return _api
                .badRequest(errorInvalidParameterType("fromParticipant", "allUsers / allClients is invalid value"));
          default:
            return _api
                .badRequest(errorInvalidParameterType("fromParticipant", "Should be from MessageParticipant enum"));
        }
        switch (toParticipant) {
          case MessageParticipant.system:
            return _api.badRequest(errorInvalidParameterType("toParticipant", "system is invalid value"));
          case MessageParticipant.user:
          case MessageParticipant.client:
            toId = body["toId"];
          case MessageParticipant.allClients:
          case MessageParticipant.allUsers:
            if (!allowedRoles) return _api.unauthorized(errorUserRoleMissing);
            toId = null;
          default:
            return _api
                .badRequest(errorInvalidParameterType("toParticipant", "Should be from MessageParticipant enum"));
        }
        final query = request.url.queryParameters;
        final target = query["target"]?.split(",");
        if (target == null) return _api.badRequest(errorMissingParameter("query: target"));
        final List<MessageType> messageTypes = [];
        for (final messageType in target) {
          final parsedType = MessageTypeCode.fromCodeOrNull(int.tryParse(messageType.trim()));
          if (parsedType == null) {
            return _api.badRequest(errorInvalidParameterType("query: target", "target should be in MessageTypeCode"));
          }
          messageTypes.add(parsedType);
        }

        int affected = 0;
        final now = DateTime.now();
        for (final messageType in messageTypes) {
          final sqlMessage = """
            INSERT INTO messages(message_id, message_type, from_participant, from_id,
              to_participant, to_id, subject, body, payload, created_at, updated_at)
            VALUES 
            (@message_id, @message_type, @from_participant, @from_id, @to_participant, @to_id,
              @subject, @body, @payload, @now, @now)
          """;
          final messageId = uuid();
          final sqlParamsMessage = <String, dynamic>{
            "message_id": messageId,
            "message_type": messageType.code,
            "from_participant": fromParticipant!.code,
            "from_id": fromId,
            "to_participant": toParticipant!.code,
            "to_id": toId,
            "subject": body["subject"] as String?,
            "body": body["body"] as String?,
            "payload": body["payload"] as JsonObject?,
            "now": now,
          };

          _api.log.verbose(sqlMessage);
          _api.log.verbose(sqlParamsMessage.toString());

          final insertedMessage = await _api.insert(sqlMessage, params: sqlParamsMessage);
          if (insertedMessage != 1) return _api.internalError(errorBrokenLogicEx("message not created"));

          final String sqlDeliveryMessage;
          if (messageType == MessageType.pushNotification) {
            sqlDeliveryMessage = """
              INSERT INTO delivery_messages(delivery_message_id, message_id, user_id, message_type, 
                status, device_token, subject, body, payload, created_at, updated_at)
              SELECT uuid_generate_v4(), @message_id, u.user_id, @message_type, @status, i.device_token,
                @subject, @body, @payload, @now, @now
              FROM users u
              INNER JOIN installations i ON i.user_id = u.user_id 
                AND i.expires_at > @now AND i.device_token IS NOT NULL
              WHERE u.blocked IS FALSE
              ${toParticipant == MessageParticipant.user ? "AND u.user_id = @user_id" : ""}
              ${toParticipant == MessageParticipant.client ? "AND u.client_id = @client_id AND @support_role = ANY(roles)" : ""}
              ${toParticipant == MessageParticipant.allClients ? "AND @support_role = ANY(roles)" : ""}
              AND (u.meta->'notifications'->'optOutPNs')::boolean IS NOT TRUE
            """;
          } else {
            sqlDeliveryMessage = """
              INSERT INTO delivery_messages(delivery_message_id, message_id, user_id, message_type, 
                status, email, subject, body, payload, created_at, updated_at)
              SELECT uuid_generate_v4(), @message_id, u.user_id, @message_type, @status, u.email,
                @subject, @body, @payload, @now, @now
              FROM users u
              WHERE u.blocked IS FALSE
              ${toParticipant == MessageParticipant.user ? "AND u.user_id = @user_id" : ""}
              ${toParticipant == MessageParticipant.client ? "AND u.client_id = @client_id AND @support_role = ANY(roles)" : ""}
              ${toParticipant == MessageParticipant.allClients ? "AND @support_role = ANY(roles)" : ""}
              AND (u.meta->'notifications'->'optOutEmails')::boolean IS NOT TRUE
            """;
          }
          final sqlParamsDeliveryMessage = <String, dynamic>{
            "message_id": messageId,
            "message_type": messageType.code,
            if (toParticipant == MessageParticipant.user) "user_id": toId as String,
            if (toParticipant == MessageParticipant.client) "client_id": toId as String,
            if ([MessageParticipant.client, MessageParticipant.allClients].contains(toParticipant))
              "support_role": UserRole.support.code,
            "status": MessageStatus.created.code,
            "subject": body["subject"] as String?,
            "body": body["body"] as String?,
            "payload": body["payload"] as JsonObject?,
            "now": now
          };

          _api.log.verbose(sqlDeliveryMessage);
          _api.log.verbose(sqlParamsDeliveryMessage.toString());

          final inserted = await _api.insert(sqlDeliveryMessage, params: sqlParamsDeliveryMessage);
          if (inserted < 1) return _api.internalError(errorBrokenLogicEx("Delivery message not created"));
          affected += inserted;
        }
        return _api.created({"affected": affected});
      });

  // /v1/message
  Router get router {
    final router = Router();

    router.post("/", _createMessage);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class MessageDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  MessageDAO(this.session, this.context) : super(context.api);

  Future<int> insert({
    required String messageId,
    required MessageType messageType,
    required String toId,
    String? subject,
    String? body,
    JsonObject? payload,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = <String, dynamic>{
          "message_id": messageId,
          "message_type": messageType.code,
          "from_participant": MessageParticipant.client.code,
          "from_id": session.clientId,
          "to_participant": MessageParticipant.user.code,
          "to_id": toId,
          "subject": subject,
          "body": body,
          "payload": payload,
          "now": DateTime.now(),
        };
        final sql = """
          INSERT INTO messages(message_id, message_type, from_participant, from_id,
            to_participant, to_id, subject, body, payload, created_at, updated_at)
          VALUES 
          (@message_id, @message_type, @from_participant, @from_id, @to_participant, @to_id,
            @subject, @body, @payload, @now, @now)
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> insertDeliveryMessage({
    required String deliveryMessageId,
    required String messageId,
    required MessageType messageType,
    required String userId,
    String? deviceToken,
    String? email,
    String? phone,
    String? subject,
    String? body,
    JsonObject? payload,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = <String, dynamic>{
          "delivery_message_id": deliveryMessageId,
          "message_id": messageId,
          "user_id": userId,
          "message_type": messageType.code,
          "status": MessageStatus.created.code,
          "device_token": deviceToken,
          "email": email,
          "phone": phone,
          "subject": subject,
          "body": body,
          "payload": payload,
          "now": DateTime.now(),
        };
        final sql = """
          INSERT INTO delivery_messages(delivery_message_id, message_id, user_id, message_type, 
            status, device_token, email, phone, subject, body, payload, created_at, updated_at)
          VALUES 
          (@delivery_message_id, @message_id, @user_id, @message_type, @status, @device_token, 
            @email, @phone, @subject, @body, @payload, @now, @now)
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });
}

// eof

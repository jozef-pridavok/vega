import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class MessageDAO extends ApiServerDAO {
  final ApiServerContext context;

  MessageDAO(this.context) : super(context.api);

  Future<bool> setMessageStatus(
    DeliveryMessage deliveryMessage,
    MessageStatus status, {
    JsonObject? response,
  }) =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE messages
          SET status = ${status.code}, 
          ${response != null ? "response = JSONB_SET(COALESCE(response,'{}'), '{${deliveryMessage.deliveryMessageId}}', @response::JSONB, TRUE) ," : ""}
          updated_at = NOW()
          WHERE message_id = @message_id
        """;

        final sqlParams = <String, dynamic>{
          "message_id": deliveryMessage.messageId,
          if (response != null) "response": response,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams) == 1;
      });
}

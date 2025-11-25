import "package:api_cron/api_v1/messages/message.dart";
import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart";

class MessagePushFCM extends ProcessMessageImplementation {
  MessagePushFCM(super.api);

  @override
  Future<(bool, JsonObject?)> process(DeliveryMessage deliveryMessage) async {
    if (deliveryMessage.deviceTokens.isEmpty) {
      return (
        false,
        {
          "sent": false,
          "error": "No device tokens",
          "messageId": deliveryMessage.messageId,
        }
      );
    }

    api.log.verbose("Sending FCM for message: ${deliveryMessage.messageId}");

    final dio = Dio(
      BaseOptions(
        headers: {"Content-Type": "application/json;charset=UTF-8", "X-Api-Key": api.config.pushServiceApiKey},
      ),
    );
    try {
      final res = await dio.post(api.config.pushServiceUrl, data: {
        "tokens": deliveryMessage.deviceTokens,
        "pushTitle": deliveryMessage.subject,
        "pushBody": deliveryMessage.body,
        "payload": deliveryMessage.payload,
      });
      final json = res.data as Map<String, dynamic>?;
      final failureTokens = json?["failureTokens"] as List<dynamic>?;
      // check if deviceToken is in failureTokens
      if (failureTokens != null && failureTokens.contains(deliveryMessage.deviceTokens)) {
        api.log.verbose("  Invalid token for delivery_message: $deliveryMessage.");
        return (
          false,
          {
            "sent": false,
            "statusCode": res.statusCode,
            if (failureTokens.isNotEmpty) "failureTokens": failureTokens,
            "deviceToken": deliveryMessage.deviceTokens,
          }
        );
      }
      api.log.verbose("  Result: ${res.statusCode == 200}, failure tokens: $failureTokens");
      return (
        res.statusCode == 200,
        {
          "sent": res.statusCode == 200,
          if (res.statusCode != null) "statusCode": res.statusCode,
          if (res.statusMessage != null) "statusMessage": res.statusMessage,
          if (failureTokens?.isNotEmpty ?? false) "failureTokens": failureTokens,
        }
      );
    } on DioException catch (e) {
      api.log.error("Dio error (FCM) for message id: ${deliveryMessage.messageId}.\n$e");
      return Future.error(e);
    } catch (e) {
      api.log.error("Unspecified error (FCM) for message id: ${deliveryMessage.messageId}.\n$e");
      return Future.error(e);
    }
  }
}
// eof

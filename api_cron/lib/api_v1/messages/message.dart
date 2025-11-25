import "package:api_cron/api_v1/messages/message_push_apn.dart";
import "package:api_cron/implementations/api_shelf.dart";
import "package:core_dart/core_dart.dart";

import "message_email.dart";
import "message_push_fcm.dart";
import "message_sms.dart";
import "message_whatsapp.dart";

abstract class ProcessMessageImplementation {
  final CronApi api;

  ProcessMessageImplementation(this.api);

  Future<(bool, JsonObject?)> process(DeliveryMessage deliveryMessage);
}

class ProcessMessageHandler {
  final CronApi api;

  ProcessMessageHandler({required this.api});

  ProcessMessageImplementation? determine(DeliveryMessage deliveryMessage) {
    switch (deliveryMessage.messageType) {
      case MessageType.email:
        return MessageEmail(api);
      case MessageType.pushNotification:
        return deliveryMessage.pushNotificationType == PushNotificationType.apn
            ? MessagePushAPN(api)
            : MessagePushFCM(api);
      case MessageType.sms:
        return MessageSms(api);
      case MessageType.whatsApp:
        return MessageWhatsapp(api);
      default:
        return null;
    }
  }
}

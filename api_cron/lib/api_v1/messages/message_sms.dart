import "package:api_cron/api_v1/messages/message.dart";
import "package:core_dart/core_dart.dart";

class MessageSms extends ProcessMessageImplementation {
  MessageSms(super.api);

  @override
  Future<(bool, JsonObject?)> process(DeliveryMessage deliveryMessage) => throw UnimplementedError();
}

// eof

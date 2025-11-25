import "package:core_dart/core_dart.dart";

enum GroupDeliveryMessageKeys {
  messageId,
  messageType,
  subject,
  body,
  deliveryMessageIds,
  deviceTokens,
  emails,
  phones,
  payload,
}

class GroupDeliveryMessage {
  final String messageId;
  final int messageType;
  final String subject;
  final String body;
  final List<String> deliveryMessageIds;
  final List<String?> deviceTokens;
  final List<String?> emails;
  final List<String?> phones;
  final JsonObject payload;

  GroupDeliveryMessage({
    required this.messageId,
    required this.messageType,
    required this.subject,
    required this.body,
    required this.deliveryMessageIds,
    required this.deviceTokens,
    required this.emails,
    required this.phones,
    required this.payload,
  });

  static const camel = {
    GroupDeliveryMessageKeys.messageId: "messageId",
    GroupDeliveryMessageKeys.messageType: "messageType",
    GroupDeliveryMessageKeys.subject: "subject",
    GroupDeliveryMessageKeys.body: "body",
    GroupDeliveryMessageKeys.deliveryMessageIds: "deliveryMessageIds",
    GroupDeliveryMessageKeys.deviceTokens: "deviceTokens",
    GroupDeliveryMessageKeys.emails: "emails",
    GroupDeliveryMessageKeys.phones: "phones",
    GroupDeliveryMessageKeys.payload: "payload",
  };

  static const snake = {
    GroupDeliveryMessageKeys.messageId: "message_id",
    GroupDeliveryMessageKeys.messageType: "message_type",
    GroupDeliveryMessageKeys.subject: "subject",
    GroupDeliveryMessageKeys.body: "body",
    GroupDeliveryMessageKeys.deliveryMessageIds: "delivery_message_ids",
    GroupDeliveryMessageKeys.deviceTokens: "device_tokens",
    GroupDeliveryMessageKeys.emails: "emails",
    GroupDeliveryMessageKeys.phones: "phones",
    GroupDeliveryMessageKeys.payload: "payload",
  };

  JsonObject toJson() => {
        "messageId": messageId,
        "messageType": messageType,
        "subject": subject,
        "body": body,
        "deliveryMessageIds": deliveryMessageIds,
        "deviceTokens": deviceTokens,
        "emails": emails,
        "phones": phones,
        "payload": payload
      };

  factory GroupDeliveryMessage.fromMap(Map<String, dynamic> map, Map<GroupDeliveryMessageKeys, String> mapper) =>
      GroupDeliveryMessage(
        messageId: map[mapper[GroupDeliveryMessageKeys.messageId]] as String,
        messageType: map[mapper[GroupDeliveryMessageKeys.messageType]] as int,
        subject: map[mapper[GroupDeliveryMessageKeys.subject]] as String,
        body: map[mapper[GroupDeliveryMessageKeys.body]] as String,
        deliveryMessageIds: map[mapper[GroupDeliveryMessageKeys.deliveryMessageIds]] as List<String>,
        deviceTokens: map[mapper[GroupDeliveryMessageKeys.deviceTokens]] as List<String?>,
        emails: map[mapper[GroupDeliveryMessageKeys.emails]] as List<String?>,
        phones: map[mapper[GroupDeliveryMessageKeys.phones]] as List<String?>,
        payload: map[mapper[GroupDeliveryMessageKeys.payload]] as JsonObject,
      );

  Map<String, dynamic> toMap(Map<GroupDeliveryMessageKeys, String> mapper) => {
        mapper[GroupDeliveryMessageKeys.messageId]!: messageId,
        mapper[GroupDeliveryMessageKeys.messageType]!: messageType,
        mapper[GroupDeliveryMessageKeys.subject]!: subject,
        mapper[GroupDeliveryMessageKeys.body]!: body,
        mapper[GroupDeliveryMessageKeys.deliveryMessageIds]!: deliveryMessageIds,
        mapper[GroupDeliveryMessageKeys.deviceTokens]!: deviceTokens,
        mapper[GroupDeliveryMessageKeys.emails]!: emails,
        mapper[GroupDeliveryMessageKeys.phones]!: phones,
        mapper[GroupDeliveryMessageKeys.payload]!: payload,
      };
}

import "dart:convert";

import "package:collection/collection.dart";
import "package:core_dart/core_dart.dart";

enum PushNotificationType {
  undefined,
  apn,
  fcm,
}

extension PushNotificationTypeCode on PushNotificationType {
  static final _codeMap = {
    PushNotificationType.undefined: 0,
    PushNotificationType.apn: 1,
    PushNotificationType.fcm: 2,
  };

  int get code => _codeMap[this]!;

  static PushNotificationType fromCode(int? code, {PushNotificationType def = PushNotificationType.undefined}) =>
      PushNotificationType.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static PushNotificationType? fromCodeOrNull(int? code) =>
      PushNotificationType.values.firstWhereOrNull((r) => r.code == code);

  static List<PushNotificationType> fromCodes(List<int>? codes) {
    if (codes == null) return [];
    return codes.map((code) => fromCode(code)).toList();
  }

  static List<int> toCodes(List<PushNotificationType>? types) {
    if (types == null) return [];
    return types.map((role) => role.code).toList();
  }
}

class DeliveryMessage {
  final String deliveryMessageId;
  final String messageId;
  final MessageType messageType;
  final MessageStatus messageStatus;
  final String? subject;
  final String body;
  final JsonObject? payload;
  final DateTime createdAt;
  final List<String> emailAddresses;
  final PushNotificationType pushNotificationType;
  final List<String> deviceTokens;

  DeliveryMessage({
    required this.deliveryMessageId,
    required this.messageId,
    required this.messageType,
    required this.messageStatus,
    this.subject,
    required this.body,
    this.payload,
    required this.createdAt,
    this.emailAddresses = const [],
    this.pushNotificationType = PushNotificationType.undefined,
    this.deviceTokens = const [],
  });

  DeliveryMessage copyWith({
    String? deliveryMessageId,
    String? messageId,
    MessageType? messageType,
    MessageStatus? messageStatus,
    String? subject,
    String? body,
    JsonObject? payload,
    DateTime? createdAt,
    List<String>? emailAddresses,
    PushNotificationType? pushNotificationType,
    List<String>? deviceTokens,
  }) {
    return DeliveryMessage(
      deliveryMessageId: deliveryMessageId ?? this.deliveryMessageId,
      messageId: messageId ?? this.messageId,
      messageType: messageType ?? this.messageType,
      messageStatus: messageStatus ?? this.messageStatus,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      emailAddresses: emailAddresses ?? this.emailAddresses,
      pushNotificationType: pushNotificationType ?? this.pushNotificationType,
      deviceTokens: deviceTokens ?? this.deviceTokens,
    );
  }

  factory DeliveryMessage.fromJsonForRedis(Map<String, dynamic> json) {
    return DeliveryMessage(
      deliveryMessageId: json["deliveryMessageId"] as String,
      messageId: json["messageId"] as String,
      messageType: MessageTypeCode.fromCode(tryParseInt(json["messageType"])),
      messageStatus: MessageStatusCode.fromCode(tryParseInt(json["messageStatus"])),
      subject: json["subject"] as String?,
      body: json["body"] as String,
      payload: json["payload"] is String ? jsonDecode(json["payload"]) : json["payload"] as JsonObject?,
      createdAt: DateTime.parse(json["createdAt"] as String),
      emailAddresses: (json["emailAddresses"] as String?)?.split("\n") ?? [],
      pushNotificationType: PushNotificationTypeCode.fromCode(tryParseInt(json["pushNotificationType"])),
      deviceTokens: (json["deviceTokens"] as String?)?.split("\n") ?? [],
    );
  }

  Map<String, dynamic> toJsonForRedis() {
    return {
      "deliveryMessageId": deliveryMessageId,
      "messageId": messageId,
      "messageType": messageType.code,
      "messageStatus": messageStatus.code,
      if (subject != null) "subject": subject,
      "body": body,
      if (payload != null) "payload": jsonEncode(payload),
      "createdAt": createdAt.toIso8601String(),
      if (emailAddresses.isNotEmpty) "emailAddresses": emailAddresses.join("\n"),
      if (pushNotificationType != PushNotificationType.undefined) "pushNotificationType": pushNotificationType.code,
      if (deviceTokens.isNotEmpty) "deviceTokens": deviceTokens.join("\n"),
    };
  }

  @override
  toString() => toJsonForRedis().toString();
}

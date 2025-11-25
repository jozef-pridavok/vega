import "dart:convert";

import "package:core_dart/core_dart.dart";

class PushNotification {
  final String? title;
  final String? body;
  final JsonObject? payload;

  String? get uuid => payload?["_uuid"] as String?;
  ActionType? get actionType => ActionTypeCode.fromCodeOrNull(tryParseInt(payload?["action"]));

  String? operator [](String key) => payload?[key] as String?;

  PushNotification({this.title, this.body, this.payload});

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json["notification"]["title"] as String?,
      body: json["notification"]["body"] as String?,
      payload: json["data"]["payload"] is String ? jsonDecode(json["data"]["payload"]) : null,
    );
  }

  @override
  toString() => "PushNotification{uuid: $uuid, title: $title, body: $body, payload: $payload}";
}

// eof

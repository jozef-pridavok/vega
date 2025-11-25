import "package:collection/collection.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";
import "template_generator.dart";

Future<CoreError?> sendMessageToClient(
  ApiServer2 api,
  Session session, {
  required List<MessageType> messageTypes,
  required String clientId,
  required List<UserRole> roles,
  String? subject,
  required String body,
  JsonObject? payload,
}) async {
  final now = DateTime.now();
  List<String> apnDeviceTokens = [];
  List<String> fcmDeviceTokens = [];
  List<String> emails = [];

  final sendPN = messageTypes.firstWhereOrNull((x) => x == MessageType.pushNotification) != null;
  final sendEmail = messageTypes.firstWhereOrNull((x) => x == MessageType.email) != null;
  final sendSMS = messageTypes.firstWhereOrNull((x) => x == MessageType.sms) != null;
  if (sendSMS) return errorBrokenLogicEx("SMS not implemented.");

  if (sendPN) {
    final sql = """
      SELECT i.device_token, device_info->>'os' AS os 
      INNER JOIN users u ON u.user_id = i.user_id AND u.deleted_at IS NULL AND u.blocked = FALSE
      INNER JOIN clients c ON c.user_id = u.user_id AND c.deleted_at IS NULL AND c.blocked = FALSE
      FROM installations i WHERE i.user_id = @user_id AND i.device_token IS NOT NULL
      WHERE c.client_id = @client_id AND u.roles && @roles
    """;
    final sqlParams = <String, dynamic>{
      "client_id": clientId,
      "roles": roles.join(","),
    };

    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = (await api.select(sql, params: sqlParams))
        .where((e) => (e["device_token"] as String?)?.isNotEmpty ?? false)
        .map((e) => {"token": e["device_token"], "os": e["os"]})
        .toList();
    apnDeviceTokens = results.where((e) => e["os"] == "ios").map((e) => e["token"] as String).toList();
    fcmDeviceTokens = results.where((e) => e["os"] == "android").map((e) => e["token"] as String).toList();
  }

  if (sendEmail) {
    final sql = """
      SELECT u.email FROM users u
      WHERE u.deleted_at IS NULL AND u.blocked = FALSE AND u.email IS NOT NULL AND LENGTH(u.email) > 0
      INNER JOIN clients c ON c.user_id = u.user_id AND c.deleted_at IS NULL AND c.blocked = FALSE
      WHERE c.client_id = @client_id AND u.roles && @roles
      """
        .tidyCode();
    final sqlParams = <String, dynamic>{
      "client_id": clientId,
      "roles": roles.join(","),
    };
    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = await api.select(sql, params: sqlParams);
    emails = results.map((e) => e["email"] as String?).whereType<String>().toList();
  }

  final sqlMessage = """
    INSERT INTO messages(
      message_id, message_type, status, from_participant, from_id,
      to_participant, to_id, subject, body, payload, created_at, updated_at
    ) VALUES (
      @message_id, @message_type, @status, @from_participant, @from_id, 
      @to_participant, @to_id, @subject, @body, @payload, @now, @now
    )
    """
      .tidyCode();

  List<DeliveryMessage> messages = [];

  for (final messageType in messageTypes) {
    final messageId = uuid();
    final sqlParamsMessage = <String, dynamic>{
      "message_id": messageId,
      "message_type": messageType.code,
      "status": messageType == MessageType.inApp ? MessageStatus.sent.code : MessageStatus.created.code,
      "from_participant": MessageParticipant.system.code,
      "from_id": MessageParticipant.system.code,
      "to_participant": MessageParticipant.client.code,
      "to_id": clientId,
      "subject": subject,
      "body": body,
      "payload": payload,
      "now": now,
    };

    api.log.verbose(sqlMessage);
    api.log.verbose(sqlParamsMessage.toString());

    final insertedMessage = await api.insert(sqlMessage, params: sqlParamsMessage);
    if (insertedMessage != 1) {
      api.log.warning("Error occurred while creating message.");
      continue;
    }

    if (messageType == MessageType.pushNotification && apnDeviceTokens.isNotEmpty)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.pushNotification,
          messageStatus: MessageStatus.created,
          body: body,
          subject: subject,
          payload: payload,
          pushNotificationType: PushNotificationType.apn,
          deviceTokens: apnDeviceTokens,
          createdAt: now,
        ),
      );

    if (messageType == MessageType.pushNotification && fcmDeviceTokens.isNotEmpty)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.pushNotification,
          messageStatus: MessageStatus.created,
          body: body,
          subject: subject,
          payload: payload,
          pushNotificationType: PushNotificationType.fcm,
          deviceTokens: fcmDeviceTokens,
          createdAt: now,
        ),
      );

    if (messageType == MessageType.email && emails.isNotEmpty)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.email,
          messageStatus: MessageStatus.created,
          body: body,
          subject: subject,
          emailAddresses: emails,
          createdAt: now,
        ),
      );
  }

  if (messages.isEmpty) api.log.debug("No delivery messages.");
  return _sendToRedis(api, messages);
}

// old
Future<CoreError?> sendMessageToUserOld(
  ApiServer api,
  Session session, {
  required List<MessageType> messageTypes,
  required String userId,
  required String subject,
  required String body,
  JsonObject? payload,
}) async {
  final from = MessageParticipant.client;
  final to = MessageParticipant.user;

  final now = DateTime.now();
  List<(String, String?)> deviceTokens = <(String, String?)>[];
  String? email;

  final sendIM = messageTypes.firstWhereOrNull((x) => x == MessageType.inApp) != null;
  final sendPN = messageTypes.firstWhereOrNull((x) => x == MessageType.pushNotification) != null;
  final sendEmail = messageTypes.firstWhereOrNull((x) => x == MessageType.email) != null;
  final sendSMS = messageTypes.firstWhereOrNull((x) => x == MessageType.sms) != null;
  if (sendSMS) return errorBrokenLogicEx("SMS not implemented.");

  if (sendPN) {
    final sql = """
      SELECT device_token, device_info->>'os' AS os 
      FROM installations WHERE user_id = @user_id AND device_token IS NOT NULL
    """;
    final sqlParams = <String, dynamic>{"user_id": userId};
    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = await api.select(sql, params: sqlParams);
    deviceTokens = results.map((e) => (e["device_token"] as String, e["os"] as String?)).toList();
  }

  if (sendEmail) {
    final sql = "SELECT email FROM users WHERE user_id=@user_id AND email IS NOT NULL AND LENGTH(email) > 0";
    final sqlParams = <String, dynamic>{"user_id": userId};
    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = await api.select(sql, params: sqlParams);
    email = results.map((e) => (e["email"] as String?)).where((e) => e?.isNotEmpty ?? true).firstOrNull;
  }

  int affected = 0;
  for (final messageType in messageTypes) {
    final sqlMessage = """
          INSERT INTO messages(message_id, message_type, from_participant, from_id,
            to_participant, to_id, subject, body, payload, created_at, updated_at)
          VALUES 
          (@message_id, @message_type, @from_participant, @from_id, 
            @to_participant, @to_id, @subject, @body, @payload, @now, @now)
        """
        .tidyCode();

    final messageId = uuid();
    final sqlParamsMessage = <String, dynamic>{
      "message_id": messageId,
      "message_type": messageType.code,
      "from_participant": from.code,
      "from_id": session.clientId,
      "to_participant": to.code,
      "to_id": userId,
      "subject": subject,
      "body": body,
      "payload": payload,
      "now": now,
    };

    api.log.verbose(sqlMessage);
    api.log.verbose(sqlParamsMessage.toString());

    final insertedMessage = await api.insert(sqlMessage, params: sqlParamsMessage);
    if (insertedMessage != 1) return errorBrokenLogicEx("Error occurred while creating message.");

    final sqlDeliveryMessage = """
          INSERT INTO delivery_messages(
            delivery_message_id, message_id, user_id, message_type, status, device_token, os,
            email, phone, subject, body, payload, created_at, updated_at
          )
          VALUES (
            @delivery_message_id, @message_id, @user_id, @message_type, @status, @device_token, @os,
            @email, @phone, @subject, @body, @payload, @now, @now
          )
        """
        .tidyCode();

    final deliverInAppMessageParam = <String, dynamic>{
      "delivery_message_id": uuid(),
      "message_id": messageId,
      "user_id": userId,
      "message_type": MessageType.inApp.code,
      "status": MessageStatus.delivered.code,
      "device_token": null,
      "os": null,
      "email": null,
      "phone": null,
      "subject": subject,
      "body": body,
      "payload": payload,
      "now": now
    };

    final deliverPushNotificationParam = deviceTokens
        .map((e) => <String, dynamic>{
              "delivery_message_id": uuid(),
              "message_id": messageId,
              "user_id": userId,
              "message_type": MessageType.pushNotification.code,
              "status": MessageStatus.created.code,
              "device_token": e.$1,
              "os": e.$2,
              "email": null,
              "phone": null,
              "subject": subject,
              "body": body,
              "payload": payload,
              "now": now
            })
        .toList();

    final deliverEmailParam = <String, dynamic>{
      "delivery_message_id": uuid(),
      "message_id": messageId,
      "user_id": userId,
      "message_type": MessageType.email.code,
      "status": MessageStatus.created.code,
      "device_token": null,
      "os": null,
      "email": email,
      "phone": null,
      "subject": subject,
      "body": body,
      "payload": payload,
      "now": now
    };

    List<Map<String, dynamic>> deliverParams = [];
    if (sendIM && messageType == MessageType.inApp) deliverParams.add(deliverInAppMessageParam);
    if (sendPN && messageType == MessageType.pushNotification) deliverParams.addAll(deliverPushNotificationParam);
    if (sendEmail && messageType == MessageType.email && email != null) deliverParams.add(deliverEmailParam);

    if (deliverParams.isNotEmpty) {
      final futures = deliverParams.map((params) async {
        api.log.verbose(sqlDeliveryMessage);
        api.log.verbose(params.toString());
        return await api.insert(sqlDeliveryMessage, params: params);
      }).toList();

      final results = await Future.wait(futures);
      affected += results.fold(0, (acc, current) => acc + current);
    }
  }

  api.log.debug("Created $affected messages.");
  return null;
}

Future<CoreError?> _sendToRedis(ApiServer2 api, List<DeliveryMessage> messages) async {
  messages = messages.map(
    (message) {
      if (message.messageType != MessageType.pushNotification) return message;
      final payload = message.payload ?? {};
      payload["_uuid"] = message.deliveryMessageId;
      return message.copyWith(payload: payload);
    },
  ).toList();

  final messageExpiry = switch (api.config.environment) {
    Flavor.dev => const Duration(minutes: 30).inSeconds,
    Flavor.qa => const Duration(days: 1).inSeconds,
    _ => const Duration(days: 30).inSeconds
  };

  try {
    // pridám správy do zoznamu čakajúcich správ na koniec zoznamu
    await api.redis(
      ["RPUSH", CacheKey.shared("messages:waiting_queue"), ...messages.map((e) => e.deliveryMessageId)],
    );
    /*
      // pridám správy do množiny čakajúcich správ
      await api.redis(
        ["SADD", CacheKey.shared("messages:waiting_set"), ...all.map((e) => e["delivery_message_id"])],
      );
      */
    // poznačím si db id (message_id) lebo v prípade expirovanej správy ju nebudem mať
    await Future.wait(messages.map((deliveryMessage) async {
      await api.redis([
        "HSET",
        CacheKey.shared("messages:db"),
        deliveryMessage.deliveryMessageId,
        deliveryMessage.messageId,
      ]);
    }));
    // uložím správy do cache s expiráciou
    await Future.wait(
      messages.map(
        (deliveryMessage) async {
          await api.redis(
            [
              "HMSET",
              CacheKey.shared("messages:data:${deliveryMessage.deliveryMessageId}"),
              ...deliveryMessage
                  .toJsonForRedis()
                  .entries
                  .where((e) => e.value != null)
                  .expand((entry) => [entry.key, entry.value.toString()])
            ],
          );
          await api.redis(
            ["EXPIRE", CacheKey.shared("messages:data:${deliveryMessage.deliveryMessageId}"), messageExpiry],
          );
        },
      ),
    );
  } on CoreError catch (ex) {
    api.log.error(ex.toString());
    return errorUnexpectedException(ex);
  } catch (ex) {
    api.log.error(ex.toString());
    return errorUnexpectedException(ex);
  }
  return null;
}

Future<CoreError?> sendMessageToUser(
  ApiServer2 api,
  Session session, {
  required List<MessageType> messageTypes,
  required String userId,
  String? subject,
  required String body,
  JsonObject? payload,
  bool bodyIsHtml = false,
}) async {
  final from = MessageParticipant.client;
  final to = MessageParticipant.user;

  final now = DateTime.now();
  List<String> apnDeviceTokens = [];
  List<String> fcmDeviceTokens = [];
  String? email;

  final sendPN = messageTypes.firstWhereOrNull((x) => x == MessageType.pushNotification) != null;
  final sendEmail = messageTypes.firstWhereOrNull((x) => x == MessageType.email) != null;
  final sendSMS = messageTypes.firstWhereOrNull((x) => x == MessageType.sms) != null;
  if (sendSMS) return errorBrokenLogicEx("SMS not implemented.");

  if (sendPN) {
    final sql = """
      SELECT device_token, device_info->>'os' AS os 
      FROM installations WHERE user_id = @user_id AND device_token IS NOT NULL
    """;
    final sqlParams = <String, dynamic>{"user_id": userId};
    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = (await api.select(sql, params: sqlParams))
        .where((e) => (e["device_token"] as String?)?.isNotEmpty ?? false)
        .map((e) => {"token": e["device_token"], "os": e["os"]})
        .toList();
    apnDeviceTokens = results.where((e) => e["os"] == "ios").map((e) => e["token"] as String).toList();
    fcmDeviceTokens = results.where((e) => e["os"] == "android").map((e) => e["token"] as String).toList();
  }

  if (sendEmail) {
    final sql = "SELECT email FROM users WHERE user_id=@user_id AND email IS NOT NULL AND LENGTH(email) > 0";
    final sqlParams = <String, dynamic>{"user_id": userId};
    api.log.verbose(sql);
    api.log.verbose(sqlParams.toString());
    final results = await api.select(sql, params: sqlParams);
    if (results.isNotEmpty) email = results.map((e) => e["email"] as String).first;
  }

  final sqlMessage = """
    INSERT INTO messages(
      message_id, message_type, status, from_participant, from_id,
      to_participant, to_id, subject, body, payload, created_at, updated_at
    ) VALUES (
      @message_id, @message_type, @status, @from_participant, @from_id, 
      @to_participant, @to_id, @subject, @body, @payload, @now, @now
    )
    """
      .tidyCode();

  List<DeliveryMessage> messages = [];

  for (final messageType in messageTypes) {
    final messageId = uuid();
    final sqlParamsMessage = <String, dynamic>{
      "message_id": messageId,
      "message_type": messageType.code,
      "status": messageType == MessageType.inApp ? MessageStatus.sent.code : MessageStatus.created.code,
      "from_participant": from.code,
      "from_id": session.clientId,
      "to_participant": to.code,
      "to_id": userId,
      "subject": subject,
      "body": body,
      "payload": payload,
      "now": now,
    };

    api.log.verbose(sqlMessage);
    api.log.verbose(sqlParamsMessage.toString());

    final insertedMessage = await api.insert(sqlMessage, params: sqlParamsMessage);
    if (insertedMessage != 1) {
      api.log.warning("Error occurred while creating message.");
      continue;
    }

    if (messageType == MessageType.pushNotification && apnDeviceTokens.isNotEmpty)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.pushNotification,
          messageStatus: MessageStatus.created,
          body: body,
          subject: subject,
          payload: payload,
          pushNotificationType: PushNotificationType.apn,
          deviceTokens: apnDeviceTokens,
          createdAt: now,
        ),
      );

    if (messageType == MessageType.pushNotification && fcmDeviceTokens.isNotEmpty)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.pushNotification,
          messageStatus: MessageStatus.created,
          body: body,
          subject: subject,
          payload: payload,
          pushNotificationType: PushNotificationType.fcm,
          deviceTokens: fcmDeviceTokens,
          createdAt: now,
        ),
      );

    if (messageType == MessageType.email && email != null)
      messages.add(
        DeliveryMessage(
          deliveryMessageId: uuid(),
          messageId: messageId,
          messageType: MessageType.email,
          messageStatus: MessageStatus.created,
          body: bodyIsHtml
              ? body
              : await TemplateGenerator(api).email(
                  subject,
                  body,
                  payload?["clientName"],
                  payload?["clientLogo"],
                ),
          subject: subject,
          emailAddresses: [email],
          createdAt: now,
        ),
      );
  }

  if (messages.isEmpty) api.log.debug("No delivery messages.");
  return _sendToRedis(api, messages);
}

// eof

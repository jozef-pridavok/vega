import "dart:convert";
import "dart:io";

import "package:api_cron/api_v1/messages/message.dart";
import "package:api_cron/implementations/api_shelf.dart";
import "package:core_dart/core_dart.dart";
import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:http2/http2.dart" as http2;
import "package:http2/http2.dart";

extension AppleOnApiServer on CronApi {
  String getApnCardsBundleId() {
    switch (config.environment) {
      case Flavor.dev:
        return "com.vega.app.dev";
      case Flavor.qa:
        return "com.vega.app.qa";
      case Flavor.demo:
        return "com.vega.app.demo";
      case Flavor.prod:
        return "com.vega.app";
    }
  }

  String getApnDashboardBundleId() {
    switch (config.environment) {
      case Flavor.dev:
        return "com.vega.dashboard.dev";
      case Flavor.qa:
        return "com.vega.dashboard.qa";
      case Flavor.demo:
        return "com.vega.dashboard.demo";
      case Flavor.prod:
        return "com.vega.dashboard";
    }
  }

  bool isApnSandbox() {
    switch (config.environment) {
      case Flavor.dev:
        return true;
      case Flavor.qa:
        return true;
      case Flavor.demo:
        return false;
      case Flavor.prod:
        return false;
    }
  }
}

class MessagePushAPN extends ProcessMessageImplementation {
  static MessagePushAPN? _instance;
  static String? privateKey;

  factory MessagePushAPN(CronApi api) {
    _instance ??= MessagePushAPN._internal(api);
    return _instance!;
  }

  MessagePushAPN._internal(super.api) {
    privateKey ??= File(_getFullPathToPrivateKey()).readAsStringSync();
    api.log.debug("Vega Cards bundle id: ${api.getApnCardsBundleId()}");
    api.log.debug("Vega Dashboard bundle id: ${api.getApnDashboardBundleId()}");
  }

  String _getFullPathToPrivateKey() {
    return joinPath([api.config.localPath, api.config.apnPrivateKey]);
  }

  @override
  Future<(bool, JsonObject?)> process(DeliveryMessage deliveryMessage) async {
    if (deliveryMessage.deviceTokens.isEmpty) {
      return (
        false,
        {
          "sent": false,
          "error": "No device tokens",
          "messageId": deliveryMessage.messageId,
        },
      );
    }

    api.log.verbose("Sending APN for message: ${deliveryMessage.messageId}");

    final jwtToken = _getJwtToken();
    final connection = await _connect(api.isApnSandbox());
    try {
      final responses = <String, dynamic>{};

      for (final deviceToken in deliveryMessage.deviceTokens) {
        final res = await sendPushNotification(
          client: connection,
          jwtToken: jwtToken,
          bundleId: api.getApnCardsBundleId(),
          deviceToken: deviceToken,
          title: deliveryMessage.subject,
          body: deliveryMessage.body,
          payload: deliveryMessage.payload,
        );
        responses[deviceToken] = {
          "sent": res.$1,
          if (res.$2 != null) "result": res.$2!,
        };
      }

      return (true, responses);
    } on CoreError catch (e) {
      api.log.error(
        "Core Errorocurred while sending apn push notification for delivery_message: $deliveryMessage.\n$e",
      );
      api.log.debug("Key ID: ${api.config.apnKeyId}");
      api.log.debug("Team ID: ${api.config.apnTeamId}");
      api.log.debug("Private key: ${api.config.apnPrivateKey}");
      api.log.debug("Local path: ${api.config.localPath}");
      api.log.debug("Full path to private key: ${_getFullPathToPrivateKey()}");
      return Future.error(e);
    } catch (e) {
      api.log.error(
        "Unspecified error ocurred while sending apn push notification for delivery_message: $deliveryMessage.\n$e",
      );
      return Future.error(e);
    } finally {
      await connection.finish();
    }
  }

  String _getJwtToken() {
    final iat = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final jwt = JWT(
      header: {"alg": "ES256", "kid": api.config.apnKeyId},
      {"iss": api.config.apnTeamId, "iat": iat.round()},
    );
    final token = jwt.sign(
      ECPrivateKey(privateKey!),
      algorithm: JWTAlgorithm.ES256,
    );
    return token;
  }

  Future<ClientTransportConnection> _connect(bool sandbox) async {
    return http2.ClientTransportConnection.viaSocket(
      await SecureSocket.connect(
        sandbox ? "api.sandbox.push.apple.com" : "api.push.apple.com",
        443,
        onBadCertificate: (X509Certificate cert) => true,
      ),
    );
  }

  Future<(bool, JsonObject?)> sendPushNotification({
    required ClientTransportConnection client,
    required String jwtToken,
    required String bundleId,
    required String deviceToken,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
  }) async {
    api.log.debug("  Sending push notification to device: $deviceToken");

    final request = client.makeRequest([
      http2.Header.ascii(":method", "POST"),
      http2.Header.ascii(":path", "/3/device/$deviceToken"),
      http2.Header.ascii("authorization", "bearer $jwtToken"),
      http2.Header.ascii("apns-topic", bundleId),
    ]);

    // https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html
    request.sendData(
      utf8.encode(
        jsonEncode({
          "aps": {
            "alert": {
              if (title != null) "title": title,
              if (body != null) "body": body,
            },
            "sound": "default",
          },
          if (payload != null) "payload": payload,
        }),
      ),
    );

    await request.outgoingMessages.close();

    final response = await request.incomingMessages.toList();

    // https://developer.apple.com/documentation/usernotifications/handling-notification-responses-from-apns
    final headers = <String, String>{};
    final data = <dynamic>[];
    for (final message in response) {
      if (message is http2.HeadersStreamMessage) {
        for (final header in message.headers) {
          final name = utf8.decode(header.name);
          final value = utf8.decode(header.value);
          headers[name] = value;
        }
      } else if (message is http2.DataStreamMessage) {
        final res = utf8.decode(message.bytes);
        if (res.isNotEmpty)
          try {
            data.add(jsonDecode(res));
          } catch (e) {
            data.add(res);
          }
      } else {
        api.log.debug("  Response: $message, ${message.runtimeType}");
      }
    }

    final sent = headers[":status"] == "200";
    return (
      sent,
      sent
          ? null
          : {"status": headers[":status"], if (data.isNotEmpty) "data": data},
    );
  }
}

// eof

import "package:api_cron/api_v1/messages/message.dart";
import "package:core_dart/core_dart.dart";
import "package:mailer/mailer.dart";
import "package:mailer/smtp_server.dart";

class MessageEmail extends ProcessMessageImplementation {
  MessageEmail(super.api);

  @override
  Future<(bool, JsonObject?)> process(DeliveryMessage deliveryMessage) async {
    if (deliveryMessage.emailAddresses.isEmpty)
      return (
        false,
        {
          "sent": false,
          "error": "No email addresses",
          "messageId": deliveryMessage.messageId,
        }
      );

    api.log.verbose("Sending email for message: ${deliveryMessage.messageId}");

    final smtpServer = SmtpServer(
      api.config.smtpHost,
      username: api.config.smtpUsername,
      password: api.config.smtpPassword,
      port: api.config.smtpPort,
      ssl: api.config.smtpUseSsl,
    );

    final message = Message()
      ..from = Address(api.config.smtpFrom)
      ..subject = deliveryMessage.subject
      ..html = deliveryMessage.body;

    if (deliveryMessage.emailAddresses.length == 1) {
      message.recipients.add(deliveryMessage.emailAddresses.first);
    } else {
      message.bccRecipients.addAll(deliveryMessage.emailAddresses);
    }

    try {
      api.log.verbose("Sending email to ${deliveryMessage.emailAddresses.join(',')}");
      final sendReport = await send(message, smtpServer);
      api.log.verbose("   Result: sent ${sendReport.connectionOpened}");
      return (
        true,
        {
          "sent": true,
          "connectionOpened": sendReport.connectionOpened.toUtc().toIso8601String(),
          "messageSendingStart": sendReport.messageSendingStart.toUtc().toIso8601String(),
          "messageSendingEnd": sendReport.messageSendingEnd.toUtc().toIso8601String(),
        },
      );
    } on MailerException catch (e) {
      api.log.verbose("   Result: error ${e.message}");
      return (
        true,
        {
          "sent": false,
          "problems": e.problems.map((p) => {"code": p.code, "msg": p.msg}).toList(),
        },
      );
    } catch (e) {
      api.log.error("Unspecified error ocurred while sending email for delivery_message_id: $deliveryMessage.\n$e");
      return Future.error(e);
    }
  }
}

// eof

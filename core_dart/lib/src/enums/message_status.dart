import "package:collection/collection.dart";

enum MessageStatus { created, queuedForDelivery, sent, delivered, read, expired, failed }

extension MessageStatusCode on MessageStatus {
  static final _codeMap = {
    MessageStatus.created: 1,
    MessageStatus.queuedForDelivery: 2,
    MessageStatus.sent: 3,
    MessageStatus.delivered: 4,
    MessageStatus.read: 5,
    MessageStatus.expired: 6,
    MessageStatus.failed: 7,
  };

  int get code => _codeMap[this]!;

  static MessageStatus fromCode(int? code, {MessageStatus def = MessageStatus.created}) =>
      MessageStatus.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static MessageStatus? fromCodeOrNull(int? code) => MessageStatus.values.firstWhereOrNull((r) => r.code == code);
}

// eof

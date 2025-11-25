import "package:collection/collection.dart";

enum MessageType { email, pushNotification, sms, inApp, whatsApp }

extension MessageTypeCode on MessageType {
  static final _codeMap = {
    MessageType.email: 1,
    MessageType.pushNotification: 2,
    MessageType.sms: 3,
    MessageType.inApp: 4,
    MessageType.whatsApp: 5,
  };

  int get code => _codeMap[this]!;

  static MessageType fromCode(int? code, {MessageType def = MessageType.email}) => MessageType.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static MessageType? fromCodeOrNull(int? code) => MessageType.values.firstWhereOrNull((r) => r.code == code);

  static List<MessageType> fromCodes(List<int>? codes) {
    if (codes == null) return [];
    return codes.map((code) => fromCode(code)).toList();
  }

  static List<int> toCodes(List<MessageType>? messageTypes) {
    if (messageTypes == null) return [];
    return messageTypes.map((role) => role.code).toList();
  }
}

// eof

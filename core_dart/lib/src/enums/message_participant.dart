import "package:collection/collection.dart";

enum MessageParticipant { user, client, system, allUsers, allClients }

extension MessageParticipantCode on MessageParticipant {
  static final _codeMap = {
    MessageParticipant.user: 1,
    MessageParticipant.client: 2,
    MessageParticipant.system: 3,
    MessageParticipant.allUsers: 4,
    MessageParticipant.allClients: 5,
  };

  int get code => _codeMap[this]!;

  static MessageParticipant fromCode(int? code, {MessageParticipant def = MessageParticipant.user}) =>
      MessageParticipant.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static MessageParticipant? fromCodeOrNull(int? code) =>
      MessageParticipant.values.firstWhereOrNull((r) => r.code == code);
}

// eof

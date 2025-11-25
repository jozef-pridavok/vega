import "package:collection/collection.dart";

enum LoyaltyTransactionObjectType {
  order,
  reservation,
  receipt,
  externalReceipt,
  pos,
  qrTag,
  programReward,
}

extension LoyaltyTransactionObjectTypeCode on LoyaltyTransactionObjectType {
  static final _translationKeyMap = {
    LoyaltyTransactionObjectType.order: "order",
    LoyaltyTransactionObjectType.reservation: "reservation",
    LoyaltyTransactionObjectType.receipt: "receipt",
    LoyaltyTransactionObjectType.externalReceipt: "external_receipt",
    LoyaltyTransactionObjectType.pos: "pos",
    LoyaltyTransactionObjectType.qrTag: "qr_tag",
    LoyaltyTransactionObjectType.programReward: "program_reward",
  };

  String get translationKey => _translationKeyMap[this]!;

  static final _codeMap = {
    LoyaltyTransactionObjectType.order: 1,
    LoyaltyTransactionObjectType.reservation: 2,
    LoyaltyTransactionObjectType.receipt: 3,
    LoyaltyTransactionObjectType.externalReceipt: 4,
    LoyaltyTransactionObjectType.pos: 5,
    LoyaltyTransactionObjectType.qrTag: 6,
    LoyaltyTransactionObjectType.programReward: 7,
  };

  int get code => _codeMap[this]!;

  static LoyaltyTransactionObjectType fromCode(int? code,
          {LoyaltyTransactionObjectType def = LoyaltyTransactionObjectType.pos}) =>
      LoyaltyTransactionObjectType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static LoyaltyTransactionObjectType? fromCodeOrNull(int? code) =>
      LoyaltyTransactionObjectType.values.firstWhereOrNull((r) => r.code == code);
}

// eof

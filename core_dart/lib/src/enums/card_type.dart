import "package:collection/collection.dart";

enum CardType {
  loyaltyCard,
  coupon,
  ticket,
  code,
  deliveryTracking,
}

extension CardTypeCode on CardType {
  static final _codeMap = {
    CardType.loyaltyCard: 1,
    CardType.coupon: 2,
    CardType.ticket: 3,
    CardType.code: 4,
    CardType.deliveryTracking: 5,
  };

  int get code => _codeMap[this]!;

  static CardType fromCode(int? code, {CardType def = CardType.loyaltyCard}) =>
      CardType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static CardType? fromCodeOrNull(int? code) => CardType.values.firstWhereOrNull((r) => r.code == code);
}

// eof

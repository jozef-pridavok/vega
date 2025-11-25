import "package:collection/collection.dart";

enum LoyaltyMode { none, countReservations, countSpentMoney, discountForCreditPayment }

extension LoyaltyModeCode on LoyaltyMode {
  static final _translationKeyMap = {
    LoyaltyMode.none: "none",
    LoyaltyMode.countReservations: "count_reservations",
    LoyaltyMode.countSpentMoney: "count_spent_money",
    LoyaltyMode.discountForCreditPayment: "discount_for_credit_payment",
  };

  String get translationKey => _translationKeyMap[this]!;

  static final _codeMap = {
    LoyaltyMode.none: 1,
    LoyaltyMode.countReservations: 2,
    LoyaltyMode.countSpentMoney: 3,
    LoyaltyMode.discountForCreditPayment: 4,
  };

  int get code => _codeMap[this]!;

  static LoyaltyMode fromCode(int? code, {LoyaltyMode def = LoyaltyMode.none}) =>
      LoyaltyMode.values.firstWhere((r) => r.code == code, orElse: () => def);

  static LoyaltyMode? fromCodeOrNull(int? code) => LoyaltyMode.values.firstWhereOrNull((r) => r.code == code);
}

extension LoyaltyModes on LoyaltyMode {
  static List<LoyaltyMode> get all => LoyaltyMode.values;

  static List<LoyaltyMode> get reservations => [
        LoyaltyMode.none,
        LoyaltyMode.countReservations,
        LoyaltyMode.discountForCreditPayment,
      ];
}

// eof

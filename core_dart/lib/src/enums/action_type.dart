import "package:collection/collection.dart";

enum ActionType {
  userCardCreated,
  userCardUpdated,
  userCardDeleted,
  userCouponCreated,
  userCouponRedeemed,
  userCouponExpired,
  pointsReceived,
  pointsSpent,
  rewardsReceived,
  orderAccepted,
  orderChanged,
  orderClosed,
  reservationAccepted,
  reservationChanged,
  reservationClosed,
  messageReceived,
}

extension ActionTypeCategory on ActionType {
  bool get isUserCard =>
      this == ActionType.userCardCreated || this == ActionType.userCardUpdated || this == ActionType.userCardDeleted;
  bool get isUserCoupon =>
      this == ActionType.userCouponCreated ||
      this == ActionType.userCouponRedeemed ||
      this == ActionType.userCouponExpired;
  bool get isPoints => this == ActionType.pointsReceived || this == ActionType.pointsSpent;
  bool get isRewards => this == ActionType.rewardsReceived;
  bool get isProgram => isPoints || isRewards;
  bool get isOrder =>
      this == ActionType.orderAccepted || this == ActionType.orderChanged || this == ActionType.orderClosed;
  bool get isReservation =>
      this == ActionType.reservationAccepted ||
      this == ActionType.reservationChanged ||
      this == ActionType.reservationClosed;
  bool get isMessage => this == ActionType.messageReceived;

  bool get isCardDetail => isUserCard || isUserCoupon || isPoints || isRewards || isOrder || isReservation;
}

extension ActionTypeCode on ActionType {
  static final _codeMap = {
    ActionType.userCardCreated: 10,
    ActionType.userCardUpdated: 11,
    ActionType.userCardDeleted: 12,
    ActionType.userCouponCreated: 20,
    ActionType.userCouponRedeemed: 21,
    ActionType.userCouponExpired: 22,
    ActionType.pointsReceived: 30,
    ActionType.pointsSpent: 31,
    ActionType.rewardsReceived: 40,
    ActionType.orderAccepted: 50,
    ActionType.orderChanged: 51,
    ActionType.orderClosed: 52,
    ActionType.reservationAccepted: 60,
    ActionType.reservationChanged: 61,
    ActionType.reservationClosed: 62,
    ActionType.messageReceived: 70,
  };

  int get code => _codeMap[this]!;

  static ActionType fromCode(int? code, {ActionType def = ActionType.userCardCreated}) =>
      ActionType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ActionType? fromCodeOrNull(int? code) => ActionType.values.firstWhereOrNull((r) => r.code == code);
}

// eof

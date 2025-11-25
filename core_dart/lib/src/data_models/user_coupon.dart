import "package:core_dart/core_dart.dart";

enum UserCouponKeys {
  userCouponId,
  userId,
  couponId,
  clientId,
  expiresAt,
  redeemedAt,
  redeemedByPosId,
  userNick,
  name,
  description,
  type,
  validFrom,
  validTo,
}

class UserCoupon {
  final String userCouponId;
  final String userId;
  final String couponId;
  final String clientId;
  final IntDate expiresAt;
  final DateTime? redeemedAt;
  final String? redeemedByPosId;
  final String? userNick;
  final String? name;
  final String? description;
  final CouponType? type;
  final IntDate? validFrom;
  final IntDate? validTo;

  const UserCoupon({
    required this.userCouponId,
    required this.userId,
    required this.couponId,
    required this.clientId,
    required this.expiresAt,
    this.redeemedAt,
    this.redeemedByPosId,
    this.userNick,
    this.name,
    this.description,
    this.type,
    this.validFrom,
    this.validTo,
  });

  static const camel = {
    UserCouponKeys.userCouponId: "userCouponId",
    UserCouponKeys.userId: "userId",
    UserCouponKeys.couponId: "couponId",
    UserCouponKeys.clientId: "clientId",
    UserCouponKeys.expiresAt: "expiresAt",
    UserCouponKeys.redeemedAt: "redeemedAt",
    UserCouponKeys.redeemedByPosId: "redeemedByPosId",
    UserCouponKeys.userNick: "userNick",
    UserCouponKeys.name: "name",
    UserCouponKeys.description: "description",
    UserCouponKeys.type: "type",
    UserCouponKeys.validFrom: "validFrom",
    UserCouponKeys.validTo: "validTo",
  };

  static const snake = {
    UserCouponKeys.userCouponId: "user_coupon_id",
    UserCouponKeys.userId: "user_id",
    UserCouponKeys.couponId: "coupon_id",
    UserCouponKeys.clientId: "client_id",
    UserCouponKeys.expiresAt: "expires_at",
    UserCouponKeys.redeemedAt: "redeemed_at",
    UserCouponKeys.redeemedByPosId: "redeemed_by_pos_id",
    UserCouponKeys.userNick: "user_nick",
    UserCouponKeys.name: "name",
    UserCouponKeys.description: "description",
    UserCouponKeys.type: "type",
    UserCouponKeys.validFrom: "valid_from",
    UserCouponKeys.validTo: "valid_to",
  };

  factory UserCoupon.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserCoupon.camel : UserCoupon.snake;
    return UserCoupon(
      userCouponId: map[mapper[UserCouponKeys.userCouponId]] as String,
      userId: map[mapper[UserCouponKeys.userId]] as String,
      couponId: map[mapper[UserCouponKeys.couponId]] as String,
      clientId: map[mapper[UserCouponKeys.clientId]] as String,
      expiresAt: IntDate.fromInt(map[mapper[UserCouponKeys.expiresAt]] as int),
      redeemedAt: tryParseDateTime(map[mapper[UserCouponKeys.redeemedAt]]),
      redeemedByPosId: map[mapper[UserCouponKeys.redeemedByPosId]] as String?,
      userNick: map[mapper[UserCouponKeys.userNick]] as String?,
      name: map[mapper[UserCouponKeys.name]] as String?,
      description: map[mapper[UserCouponKeys.description]] as String?,
      type: CouponTypeCode.fromCodeOrNull(map[mapper[UserCouponKeys.type]] as int?),
      validFrom: IntDate.parseInt(map[mapper[UserCouponKeys.validFrom]] as int?),
      validTo: IntDate.parseInt(map[mapper[UserCouponKeys.validTo]] as int?),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserCoupon.camel : UserCoupon.snake;
    return {
      mapper[UserCouponKeys.userCouponId]!: userCouponId,
      mapper[UserCouponKeys.userId]!: userId,
      mapper[UserCouponKeys.couponId]!: couponId,
      mapper[UserCouponKeys.clientId]!: clientId,
      mapper[UserCouponKeys.expiresAt]!: expiresAt.value,
      if (redeemedAt != null) mapper[UserCouponKeys.redeemedAt]!: redeemedAt!.toIso8601String(),
      if (redeemedByPosId != null) mapper[UserCouponKeys.redeemedByPosId]!: redeemedByPosId,
      if (userNick != null) mapper[UserCouponKeys.userNick]!: userNick,
      if (name != null) mapper[UserCouponKeys.name]!: name,
      if (description != null) mapper[UserCouponKeys.description]!: description,
      if (type != null) mapper[UserCouponKeys.type]!: type!.code,
      if (validFrom != null) mapper[UserCouponKeys.validFrom]!: validFrom?.value,
      if (validTo != null) mapper[UserCouponKeys.validTo]!: validTo?.value,
    };
  }
}

// eof

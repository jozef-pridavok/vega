import "package:core_dart/core_dart.dart";

enum UserCardKeys {
  userCardId,
  userId,
  cardId,
  cardName,
  clientId,
  clientName,
  codeType,
  number,
  name,
  notes,
  logo,
  logoBh,
  color,
  front,
  frontBh,
  back,
  backBh,
  // --
  eligibleReservationsCount,
  reservationsCount,
  offersCount,
  ordersCount,
  receiptsCount,
  leafletsCount,
  userCoupons,
  programs,
  lastProductOrder,
  active,
  lastActivity,
  userName,
}

class UserCard with SyncedDataModel {
  final String userCardId;
  final String userId;
  final String? cardId;
  final String? cardName;
  final String? clientId;
  final String? clientName;
  final CodeType codeType;
  final String? number;
  final String? name;
  final String? notes;
  final String? logo;
  final String? logoBh;
  final Color? color;
  final String? front;
  final String? frontBh;
  final String? back;
  final String? backBh;
  // --
  final int? eligibleReservationsCount;
  final int? reservationsCount;
  final int? offersCount;
  final int? ordersCount;
  final int? receiptsCount;
  final int? leafletsCount;
  final List<UserCouponOnUserCard>? userCoupons;
  final List<ProgramOnUserCard>? programs;
  final UserOrder? lastProductOrder;
  final bool? active;
  final DateTime? lastActivity;
  final String? userName;

  UserCard({
    required this.userCardId,
    required this.userId,
    this.cardId,
    this.cardName,
    this.clientId,
    this.clientName,
    required this.codeType,
    this.number,
    this.name,
    this.notes,
    this.logo,
    this.logoBh,
    this.color,
    this.front,
    this.frontBh,
    this.back,
    this.backBh,
    // --
    this.reservationsCount,
    this.eligibleReservationsCount,
    this.offersCount,
    this.ordersCount,
    this.receiptsCount,
    this.leafletsCount,
    this.userCoupons,
    this.programs,
    this.lastProductOrder,
    this.active,
    this.lastActivity,
    this.userName,
  });

  UserCard copyWith({
    String? name,
    String? number,
    String? notes,
    String? logo,
    String? logoBh,
    Color? color,
    String? front,
    String? frontBh,
    String? back,
    String? backBh,
    List<UserCouponOnUserCard>? userCoupons,
    List<ProgramOnUserCard>? programs,
  }) {
    return UserCard(
      userCardId: userCardId,
      userId: userId,
      cardId: cardId,
      cardName: cardName,
      clientId: clientId,
      clientName: clientName,
      codeType: codeType,
      number: number ?? this.number,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      logo: logo ?? this.logo,
      logoBh: logoBh ?? this.logoBh,
      color: color ?? this.color,
      front: front ?? this.front,
      frontBh: frontBh ?? this.frontBh,
      back: back ?? this.back,
      backBh: backBh ?? this.backBh,
      // --
      reservationsCount: reservationsCount,
      eligibleReservationsCount: eligibleReservationsCount,
      offersCount: offersCount,
      ordersCount: ordersCount,
      receiptsCount: receiptsCount,
      leafletsCount: leafletsCount,
      userCoupons: userCoupons ?? this.userCoupons,
      programs: programs ?? this.programs,
      lastProductOrder: lastProductOrder,
      active: active,
      lastActivity: lastActivity,
      userName: userName,
    )
      ..syncIsActive = syncIsActive
      ..syncIsModified = syncIsModified
      ..syncIsRemote = syncIsRemote;
  }

  static const camel = {
    UserCardKeys.userCardId: "userCardId",
    UserCardKeys.userId: "userId",
    UserCardKeys.cardId: "cardId",
    UserCardKeys.cardName: "cardName",
    UserCardKeys.clientId: "clientId",
    UserCardKeys.clientName: "clientName",
    UserCardKeys.codeType: "codeType",
    UserCardKeys.number: "number",
    UserCardKeys.name: "name",
    UserCardKeys.notes: "notes",
    UserCardKeys.logo: "logo",
    UserCardKeys.logoBh: "logoBh",
    UserCardKeys.color: "color",
    UserCardKeys.front: "front",
    UserCardKeys.frontBh: "frontBh",
    UserCardKeys.back: "back",
    UserCardKeys.backBh: "backBh",
    // --
    UserCardKeys.eligibleReservationsCount: "eligibleReservationsCount",
    UserCardKeys.reservationsCount: "reservationsCount",
    UserCardKeys.offersCount: "offersCount",
    UserCardKeys.ordersCount: "ordersCount",
    UserCardKeys.receiptsCount: "receiptsCount",
    UserCardKeys.leafletsCount: "leafletsCount",
    UserCardKeys.userCoupons: "userCoupons",
    UserCardKeys.programs: "programs",
    UserCardKeys.lastProductOrder: "lastProductOrder",
    UserCardKeys.active: "active",
    UserCardKeys.lastActivity: "lastActivity",
    UserCardKeys.userName: "userName",
  };

  static const snake = {
    UserCardKeys.userCardId: "user_card_id",
    UserCardKeys.userId: "user_id",
    UserCardKeys.cardId: "card_id",
    UserCardKeys.cardName: "card_name",
    UserCardKeys.clientId: "client_id",
    UserCardKeys.clientName: "client_name",
    UserCardKeys.codeType: "code_type",
    UserCardKeys.number: "number",
    UserCardKeys.name: "name",
    UserCardKeys.notes: "notes",
    UserCardKeys.logo: "logo",
    UserCardKeys.logoBh: "logo_bh",
    UserCardKeys.color: "color",
    UserCardKeys.front: "front",
    UserCardKeys.frontBh: "front_bh",
    UserCardKeys.back: "back",
    UserCardKeys.backBh: "back_bh",
    // --
    UserCardKeys.eligibleReservationsCount: "eligible_reservations_count",
    UserCardKeys.reservationsCount: "reservations_count",
    UserCardKeys.offersCount: "offers_count",
    UserCardKeys.ordersCount: "orders_count",
    UserCardKeys.receiptsCount: "receipts_count",
    UserCardKeys.leafletsCount: "leaflets_count",
    UserCardKeys.userCoupons: "user_coupons",
    UserCardKeys.programs: "programs",
    UserCardKeys.lastProductOrder: "last_product_order",
    UserCardKeys.active: "active",
    UserCardKeys.lastActivity: "last_activity",
    UserCardKeys.userName: "user_name",
  };

  factory UserCard.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserCard.camel : UserCard.snake;
    return UserCard(
      userCardId: map[mapper[UserCardKeys.userCardId]!] as String,
      userId: map[mapper[UserCardKeys.userId]!] as String,
      cardId: map[mapper[UserCardKeys.cardId]!] as String?,
      cardName: map[mapper[UserCardKeys.cardName]!] as String?,
      clientId: map[mapper[UserCardKeys.clientId]!] as String?,
      clientName: map[mapper[UserCardKeys.clientName]!] as String?,
      codeType: CodeTypeCode.fromCode(map[mapper[UserCardKeys.codeType]] as int?),
      number: map[mapper[UserCardKeys.number]!] as String?,
      name: map[mapper[UserCardKeys.name]!] as String?,
      notes: map[mapper[UserCardKeys.notes]!] as String?,
      logo: map[mapper[UserCardKeys.logo]!] as String?,
      logoBh: map[mapper[UserCardKeys.logoBh]!] as String?,
      color: Color.fromHexOrNull(map[mapper[UserCardKeys.color]] as String?),
      front: map[mapper[UserCardKeys.front]!] as String?,
      frontBh: map[mapper[UserCardKeys.frontBh]!] as String?,
      back: map[mapper[UserCardKeys.back]!] as String?,
      backBh: map[mapper[UserCardKeys.backBh]!] as String?,
      // --
      eligibleReservationsCount: map[mapper[UserCardKeys.eligibleReservationsCount]!] as int?,
      reservationsCount: map[mapper[UserCardKeys.reservationsCount]!] as int?,
      offersCount: map[mapper[UserCardKeys.offersCount]!] as int?,
      ordersCount: map[mapper[UserCardKeys.ordersCount]!] as int?,
      receiptsCount: map[mapper[UserCardKeys.receiptsCount]!] as int?,
      leafletsCount: map[mapper[UserCardKeys.leafletsCount]!] as int?,
      userCoupons: (map[mapper[UserCardKeys.userCoupons]!] as JsonArray?)
          ?.cast<JsonObject>()
          .map((e) => UserCouponOnUserCard.fromMap(e, convention))
          .toList(),
      programs: (map[mapper[UserCardKeys.programs]!] as JsonArray?)
          ?.cast<JsonObject>()
          .map((e) => ProgramOnUserCard.fromMap(e, convention))
          .toList(),
      lastProductOrder: map[mapper[UserCardKeys.lastProductOrder]!] == null
          ? null
          : UserOrder.fromMap(map[mapper[UserCardKeys.lastProductOrder]!] as Map<String, dynamic>, convention),
      active: map[mapper[UserCardKeys.active]!] as bool?,
      lastActivity: tryParseDateTime(map[mapper[UserCardKeys.lastActivity]!]),
      userName: map[mapper[UserCardKeys.userName]!] as String?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserCard.camel : UserCard.snake;
    return {
      mapper[UserCardKeys.userCardId]!: userCardId,
      mapper[UserCardKeys.userId]!: userId,
      if (cardId != null) mapper[UserCardKeys.cardId]!: cardId,
      if (cardName != null) mapper[UserCardKeys.cardName]!: cardName,
      if (clientId != null) mapper[UserCardKeys.clientId]!: clientId,
      if (clientName != null) mapper[UserCardKeys.clientName]!: clientName,
      mapper[UserCardKeys.codeType]!: codeType.code,
      if (number != null) mapper[UserCardKeys.number]!: number,
      if (name != null) mapper[UserCardKeys.name]!: name,
      if (notes != null) mapper[UserCardKeys.notes]!: notes,
      if (logo != null) mapper[UserCardKeys.logo]!: logo,
      if (logoBh != null) mapper[UserCardKeys.logoBh]!: logoBh,
      if (color != null) mapper[UserCardKeys.color]!: color?.toHex(),
      if (front != null) mapper[UserCardKeys.front]!: front,
      if (frontBh != null) mapper[UserCardKeys.frontBh]!: frontBh,
      if (back != null) mapper[UserCardKeys.back]!: back,
      if (backBh != null) mapper[UserCardKeys.backBh]!: backBh,
      // --
      if (eligibleReservationsCount != null) mapper[UserCardKeys.eligibleReservationsCount]!: eligibleReservationsCount,
      if (reservationsCount != null) mapper[UserCardKeys.reservationsCount]!: reservationsCount,
      if (offersCount != null) mapper[UserCardKeys.offersCount]!: offersCount,
      if (ordersCount != null) mapper[UserCardKeys.ordersCount]!: ordersCount,
      if (receiptsCount != null) mapper[UserCardKeys.receiptsCount]!: receiptsCount,
      if (leafletsCount != null) mapper[UserCardKeys.leafletsCount]!: leafletsCount,
      if (userCoupons?.isNotEmpty ?? false)
        mapper[UserCardKeys.userCoupons]!: userCoupons!.map((e) => e.toMap(convention)).toList(),
      if (programs?.isNotEmpty ?? false)
        mapper[UserCardKeys.programs]!: programs!.map((e) => e.toMap(convention)).toList(),
      if (lastProductOrder != null) mapper[UserCardKeys.lastProductOrder]!: lastProductOrder!.toMap(convention),
      if (active != null) mapper[UserCardKeys.active]!: active,
      if (lastActivity != null) mapper[UserCardKeys.lastActivity]!: lastActivity?.toUtc().toIso8601String(),
      if (userName != null) mapper[UserCardKeys.userName]!: userName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserCard && other.userCardId == userCardId;
  }

  @override
  int get hashCode => userCardId.hashCode;

  @override
  String toString() =>
      "UserCard{userCardId: ${userCardId.shorten()}, name: $name, number: $number, userId: ${userId.shorten()}, cardId: ${cardId?.shorten()}, clientId: ${clientId?.shorten()}, codeType: $codeType, notes: $notes, logo: $logo, logoBh: $logoBh, color: $color, front: $front, frontBh: $frontBh, back: $back, backBh: $backBh, active: $active, lastActivity: $lastActivity, syncIsActive: $syncIsActive, syncIsModified: $syncIsModified, syncIsRemote: $syncIsRemote}";
}

// eof

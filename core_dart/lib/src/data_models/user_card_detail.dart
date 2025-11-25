
/*
enum UserCardDetailKeys {
  userCardId,
  userId,
  cardId,
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
  meta,
  eligibleReservationsCount,
  reservationsCount,
  offersCount,
  ordersCount,
  receiptsCount,
  leafletsCount,
  userCoupons,
  programs,
  lastProductOrder,
}

class UserCardDetail {
  final String userCardId;
  final String userId;
  final String? cardId;
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
  final JsonObject? meta;
  final int eligibleReservationsCount;
  final int reservationsCount;
  final int offersCount;
  final int ordersCount;
  final int receiptsCount;
  final int leafletsCount;
  final List<UserCouponOnUserCard> userCoupons;
  final List<ProgramOnUserCard> programs;

  final UserOrder? lastProductOrder;

  UserCardDetail({
    required this.userCardId,
    required this.userId,
    this.cardId,
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
    this.meta,
    required this.reservationsCount,
    required this.eligibleReservationsCount,
    required this.offersCount,
    required this.ordersCount,
    required this.receiptsCount,
    required this.leafletsCount,
    required this.userCoupons,
    required this.programs,
    this.lastProductOrder,
  });

  static const camel = {
    UserCardDetailKeys.userCardId: "userCardId",
    UserCardDetailKeys.userId: "userId",
    UserCardDetailKeys.cardId: "cardId",
    UserCardDetailKeys.clientName: "clientName",
    UserCardDetailKeys.clientId: "clientId",
    UserCardDetailKeys.codeType: "codeType",
    UserCardDetailKeys.number: "number",
    UserCardDetailKeys.name: "name",
    UserCardDetailKeys.notes: "notes",
    UserCardDetailKeys.logo: "logo",
    UserCardDetailKeys.logoBh: "logoBh",
    UserCardDetailKeys.color: "color",
    UserCardDetailKeys.front: "front",
    UserCardDetailKeys.frontBh: "frontBh",
    UserCardDetailKeys.back: "back",
    UserCardDetailKeys.backBh: "backBh",
    UserCardDetailKeys.meta: "meta",
    UserCardDetailKeys.eligibleReservationsCount: "eligibleReservationsCount",
    UserCardDetailKeys.reservationsCount: "reservationsCount",
    UserCardDetailKeys.offersCount: "offersCount",
    UserCardDetailKeys.ordersCount: "ordersCount",
    UserCardDetailKeys.receiptsCount: "receiptsCount",
    UserCardDetailKeys.leafletsCount: "leafletsCount",
    UserCardDetailKeys.userCoupons: "userCoupons",
    UserCardDetailKeys.programs: "programs",
    UserCardDetailKeys.lastProductOrder: "lastProductOrder",
  };

  static const snake = {
    UserCardDetailKeys.userCardId: "user_card_id",
    UserCardDetailKeys.userId: "user_id",
    UserCardDetailKeys.cardId: "card_id",
    UserCardDetailKeys.clientId: "client_id",
    UserCardDetailKeys.clientName: "client_name",
    UserCardDetailKeys.codeType: "code_type",
    UserCardDetailKeys.number: "number",
    UserCardDetailKeys.name: "name",
    UserCardDetailKeys.notes: "notes",
    UserCardDetailKeys.logo: "logo",
    UserCardDetailKeys.logoBh: "logo_bh",
    UserCardDetailKeys.color: "color",
    UserCardDetailKeys.front: "front",
    UserCardDetailKeys.frontBh: "front_bh",
    UserCardDetailKeys.back: "back",
    UserCardDetailKeys.backBh: "back_bh",
    UserCardDetailKeys.meta: "meta",
    UserCardDetailKeys.eligibleReservationsCount: "eligible_reservations_count",
    UserCardDetailKeys.reservationsCount: "reservations_count",
    UserCardDetailKeys.offersCount: "offers_count",
    UserCardDetailKeys.ordersCount: "orders_count",
    UserCardDetailKeys.receiptsCount: "receipts_count",
    UserCardDetailKeys.leafletsCount: "leaflets_count",
    UserCardDetailKeys.userCoupons: "user_coupons",
    UserCardDetailKeys.programs: "programs",
    UserCardDetailKeys.lastProductOrder: "last_product_order",
  };

  static UserCardDetail fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserCardDetail.camel : UserCardDetail.snake;
    return UserCardDetail(
      userCardId: map[mapper[UserCardDetailKeys.userCardId]!] as String,
      userId: map[mapper[UserCardDetailKeys.userId]!] as String,
      cardId: map[mapper[UserCardDetailKeys.cardId]!] as String?,
      clientName: map[mapper[UserCardDetailKeys.clientName]!] as String?,
      clientId: map[mapper[UserCardDetailKeys.clientId]!] as String?,
      codeType: CodeTypeCode.fromCode(map[mapper[UserCardDetailKeys.codeType]!] as int),
      number: map[mapper[UserCardDetailKeys.number]!] as String?,
      name: map[mapper[UserCardDetailKeys.name]!] as String?,
      notes: map[mapper[UserCardDetailKeys.notes]!] as String?,
      logo: map[mapper[UserCardDetailKeys.logo]!] as String?,
      logoBh: map[mapper[UserCardDetailKeys.logoBh]!] as String?,
      color: Color.fromHexOrNull(map[mapper[UserCardDetailKeys.color]!] as String?),
      front: map[mapper[UserCardDetailKeys.front]!] as String?,
      frontBh: map[mapper[UserCardDetailKeys.frontBh]!] as String?,
      back: map[mapper[UserCardDetailKeys.back]!] as String?,
      backBh: map[mapper[UserCardDetailKeys.backBh]!] as String?,
      meta: map[mapper[UserCardDetailKeys.meta]!] as Map<String, dynamic>?,
      eligibleReservationsCount: map[mapper[UserCardDetailKeys.eligibleReservationsCount]!] as int,
      reservationsCount: map[mapper[UserCardDetailKeys.reservationsCount]!] as int,
      offersCount: map[mapper[UserCardDetailKeys.offersCount]!] as int,
      ordersCount: map[mapper[UserCardDetailKeys.ordersCount]!] as int,
      receiptsCount: map[mapper[UserCardDetailKeys.receiptsCount]!] as int,
      leafletsCount: map[mapper[UserCardDetailKeys.leafletsCount]!] as int,
      userCoupons: (map[mapper[UserCardDetailKeys.userCoupons]!] as JsonArray)
          .cast<JsonObject>()
          .map((e) => UserCouponOnUserCard.fromMap(e, convention))
          .toList(),
      programs: (map[mapper[UserCardDetailKeys.programs]!] as JsonArray)
          .cast<JsonObject>()
          .map((e) => ProgramOnUserCard.fromMap(e, convention))
          .toList(),
      lastProductOrder: map[mapper[UserCardDetailKeys.lastProductOrder]!] == null
          ? null
          : UserOrder.fromMap(map[mapper[UserCardDetailKeys.lastProductOrder]!] as Map<String, dynamic>, convention),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserCardDetail.camel : UserCardDetail.snake;
    return {
      mapper[UserCardDetailKeys.userCardId]!: userCardId,
      mapper[UserCardDetailKeys.userId]!: userId,
      if (cardId != null) mapper[UserCardDetailKeys.cardId]!: cardId,
      if (clientId != null) mapper[UserCardDetailKeys.clientId]!: clientId,
      if (clientName != null) mapper[UserCardDetailKeys.clientName]!: clientName,
      mapper[UserCardDetailKeys.codeType]!: codeType.code,
      if (number != null) mapper[UserCardDetailKeys.number]!: number,
      if (name != null) mapper[UserCardDetailKeys.name]!: name,
      if (notes != null) mapper[UserCardDetailKeys.notes]!: notes,
      if (logo != null) mapper[UserCardDetailKeys.logo]!: logo,
      if (logoBh != null) mapper[UserCardDetailKeys.logoBh]!: logoBh,
      if (color != null) mapper[UserCardDetailKeys.color]!: color?.toHex(),
      if (front != null) mapper[UserCardDetailKeys.front]!: front,
      if (frontBh != null) mapper[UserCardDetailKeys.frontBh]!: frontBh,
      if (back != null) mapper[UserCardDetailKeys.back]!: back,
      if (backBh != null) mapper[UserCardDetailKeys.backBh]!: backBh,
      if (meta != null) mapper[UserCardDetailKeys.meta]!: meta,
      mapper[UserCardDetailKeys.eligibleReservationsCount]!: eligibleReservationsCount,
      mapper[UserCardDetailKeys.reservationsCount]!: reservationsCount,
      mapper[UserCardDetailKeys.offersCount]!: offersCount,
      mapper[UserCardDetailKeys.ordersCount]!: ordersCount,
      mapper[UserCardDetailKeys.receiptsCount]!: receiptsCount,
      mapper[UserCardDetailKeys.leafletsCount]!: leafletsCount,
      mapper[UserCardDetailKeys.userCoupons]!: userCoupons.map((e) => e.toMap(convention)).toList(),
      mapper[UserCardDetailKeys.programs]!: programs.map((e) => e.toMap(convention)).toList(),
      if (lastProductOrder != null) mapper[UserCardDetailKeys.lastProductOrder]!: lastProductOrder!.toMap(convention),
    };
  }
}
*/
// eof

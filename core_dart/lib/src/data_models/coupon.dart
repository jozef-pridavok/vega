import "package:core_dart/core_dart.dart";

enum CouponKeys {
  couponId,
  clientId,
  locationId,
  type,
  name,
  description,
  discount,
  code,
  codes,
  image,
  imageBh,
  countries,
  rank,
  validFrom,
  validTo,
  blocked,
  meta,
  updatedAt,
  clientName,
  clientLogo,
  clientLogoBh,
  clientColor,
  locationName,
  locationAddressLine1,
  locationAddressLine2,
  locationCity,
  locationLongitude,
  locationLatitude,
  couponsIssued,
  reservation,
  order,
}

class Coupon {
  final String couponId;
  final String clientId;
  final String? locationId;
  final CouponType type;
  final String name;
  final String? description;
  final String? discount;
  final String? code;
  final List<String>? codes;
  String? image;
  final String? imageBh;
  final List<Country>? countries;
  final int rank;
  final IntDate validFrom;
  final IntDate? validTo;
  final bool blocked;
  Map<String, dynamic>? meta;
  DateTime? updatedAt;

  String? clientName;
  String? clientLogo;
  String? clientLogoBh;
  Color? clientColor;

  String? locationName;
  String? locationAddressLine1;
  String? locationAddressLine2;
  String? locationCity;
  GeoPoint? locationPoint;

  final int? couponsIssued;

  final CouponReservation? reservation;
  final CouponOrder? order;

  Coupon({
    required this.couponId,
    required this.clientId,
    this.locationId,
    required this.type,
    required this.name,
    this.description,
    this.discount,
    this.code,
    this.codes,
    this.image,
    this.imageBh,
    this.countries,
    this.rank = 1,
    required this.validFrom,
    this.validTo,
    this.blocked = false,
    this.meta,
    this.updatedAt,
    this.clientName,
    this.clientLogo,
    this.clientLogoBh,
    this.clientColor,
    this.locationName,
    this.locationAddressLine1,
    this.locationAddressLine2,
    this.locationCity,
    this.locationPoint,
    this.couponsIssued,
    this.reservation,
    this.order,
  });

  Coupon copyWith({
    String? couponId,
    String? clientId,
    String? locationId,
    CouponType? type,
    String? name,
    String? description,
    String? discount,
    String? code,
    List<String>? codes,
    String? image,
    String? imageBh,
    List<Country>? countries,
    int? rank,
    IntDate? validFrom,
    IntDate? validTo,
    bool? blocked,
    Map<String, dynamic>? meta,
    DateTime? updatedAt,
    String? clientName,
    String? clientLogo,
    String? clientLogoBh,
    Color? clientColor,
    String? locationName,
    String? locationAddressLine1,
    String? locationAddressLine2,
    String? locationCity,
    GeoPoint? locationPoint,
    int? couponsIssued,
    CouponReservation? reservation,
    CouponOrder? order,
  }) =>
      Coupon(
        couponId: couponId ?? this.couponId,
        clientId: clientId ?? this.clientId,
        locationId: locationId ?? this.locationId,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        discount: discount ?? this.discount,
        code: code ?? this.code,
        codes: codes ?? this.codes,
        image: image ?? this.image,
        imageBh: imageBh ?? this.imageBh,
        countries: countries ?? this.countries,
        rank: rank ?? this.rank,
        validFrom: validFrom ?? this.validFrom,
        validTo: validTo ?? this.validTo,
        blocked: blocked ?? this.blocked,
        meta: meta ?? this.meta,
        updatedAt: updatedAt ?? this.updatedAt,
        clientName: clientName ?? this.clientName,
        clientLogo: clientLogo ?? this.clientLogo,
        clientLogoBh: clientLogoBh ?? this.clientLogoBh,
        clientColor: clientColor ?? this.clientColor,
        locationName: locationName ?? this.locationName,
        locationAddressLine1: locationAddressLine1 ?? this.locationAddressLine1,
        locationAddressLine2: locationAddressLine2 ?? this.locationAddressLine2,
        locationCity: locationCity ?? this.locationCity,
        locationPoint: locationPoint ?? this.locationPoint,
        couponsIssued: couponsIssued ?? this.couponsIssued,
        reservation: reservation ?? this.reservation,
        order: order ?? this.order,
      );

  static const camel = {
    CouponKeys.couponId: "couponId",
    CouponKeys.clientId: "clientId",
    CouponKeys.locationId: "locationId",
    CouponKeys.type: "type",
    CouponKeys.name: "name",
    CouponKeys.description: "description",
    CouponKeys.discount: "discount",
    CouponKeys.code: "code",
    CouponKeys.codes: "codes",
    CouponKeys.image: "image",
    CouponKeys.imageBh: "imageBh",
    CouponKeys.countries: "countries",
    CouponKeys.rank: "rank",
    CouponKeys.validFrom: "validFrom",
    CouponKeys.validTo: "validTo",
    CouponKeys.blocked: "blocked",
    CouponKeys.meta: "meta",
    CouponKeys.updatedAt: "updatedAt",
    CouponKeys.clientName: "clientName",
    CouponKeys.clientLogo: "clientLogo",
    CouponKeys.clientLogoBh: "clientLogoBh",
    CouponKeys.clientColor: "clientColor",
    CouponKeys.locationName: "locationName",
    CouponKeys.locationAddressLine1: "locationAddressLine1",
    CouponKeys.locationAddressLine2: "locationAddressLine2",
    CouponKeys.locationCity: "locationCity",
    CouponKeys.locationLongitude: "locationLongitude",
    CouponKeys.locationLatitude: "locationLatitude",
    CouponKeys.couponsIssued: "couponsIssued",
    CouponKeys.reservation: "reservation",
    CouponKeys.order: "order",
  };

  static const snake = {
    CouponKeys.couponId: "coupon_id",
    CouponKeys.clientId: "client_id",
    CouponKeys.locationId: "location_id",
    CouponKeys.type: "type",
    CouponKeys.name: "name",
    CouponKeys.description: "description",
    CouponKeys.discount: "discount",
    CouponKeys.code: "code",
    CouponKeys.codes: "codes",
    CouponKeys.image: "image",
    CouponKeys.imageBh: "image_bh",
    CouponKeys.countries: "countries",
    CouponKeys.rank: "rank",
    CouponKeys.validFrom: "valid_from",
    CouponKeys.validTo: "valid_to",
    CouponKeys.blocked: "blocked",
    CouponKeys.meta: "meta",
    CouponKeys.updatedAt: "updated_at",
    CouponKeys.clientName: "client_name",
    CouponKeys.clientLogo: "client_logo",
    CouponKeys.clientLogoBh: "client_logo_bh",
    CouponKeys.clientColor: "client_color",
    CouponKeys.locationName: "location_name",
    CouponKeys.locationAddressLine1: "location_address_line_1",
    CouponKeys.locationAddressLine2: "location_address_line_2",
    CouponKeys.locationCity: "location_city",
    CouponKeys.locationLongitude: "location_longitude",
    CouponKeys.locationLatitude: "location_latitude",
    CouponKeys.couponsIssued: "coupons_issued",
    CouponKeys.reservation: "reservation",
    CouponKeys.order: "order",
  };

  factory Coupon.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Coupon.camel : Coupon.snake;
    return Coupon(
      couponId: map[mapper[CouponKeys.couponId]!] as String,
      clientId: map[mapper[CouponKeys.clientId]!] as String,
      locationId: map[mapper[CouponKeys.locationId]!] as String?,
      type: CouponTypeCode.fromCode(map[mapper[CouponKeys.type]!] as int),
      name: map[mapper[CouponKeys.name]!] as String,
      description: map[mapper[CouponKeys.description]!] as String?,
      discount: map[mapper[CouponKeys.discount]!] as String?,
      code: map[mapper[CouponKeys.code]!] as String?,
      codes: (map[mapper[CouponKeys.codes]!] as List<dynamic>?)?.cast<String>(),
      image: map[mapper[CouponKeys.image]!] as String?,
      imageBh: map[mapper[CouponKeys.imageBh]!] as String?,
      countries: CountryCode.fromCodesOrNull((map[mapper[CouponKeys.countries]!] as List<dynamic>?)?.cast<String>()),
      rank: map[mapper[CouponKeys.rank]!] as int? ?? 1,
      validFrom: IntDate.fromInt(map[mapper[CouponKeys.validFrom]] as int),
      validTo: IntDate.parseInt(map[mapper[CouponKeys.validTo]] as int?),
      blocked: tryParseBool(map[mapper[CouponKeys.blocked]!]) ?? false,
      meta: map[mapper[CouponKeys.meta]!] as Map<String, dynamic>?,
      updatedAt: tryParseDateTime(map[mapper[CouponKeys.updatedAt]]),
      clientName: map[mapper[CouponKeys.clientName]!] as String?,
      clientLogo: map[mapper[CouponKeys.clientLogo]!] as String?,
      clientLogoBh: map[mapper[CouponKeys.clientLogoBh]!] as String?,
      clientColor: Color.fromHexOrNull(map[mapper[CouponKeys.clientColor]] as String?),
      locationName: map[mapper[CouponKeys.locationName]!] as String?,
      locationAddressLine1: map[mapper[CouponKeys.locationAddressLine1]!] as String?,
      locationAddressLine2: map[mapper[CouponKeys.locationAddressLine2]!] as String?,
      locationCity: map[mapper[CouponKeys.locationCity]!] as String?,
      locationPoint:
          GeoPoint.tryParse(map[mapper[CouponKeys.locationLongitude]!], map[mapper[CouponKeys.locationLatitude]!]),
      couponsIssued: map[mapper[CouponKeys.couponsIssued]!] as int?,
      reservation: map[mapper[CouponKeys.meta]]?[mapper[CouponKeys.reservation]] != null
          ? CouponReservation.fromMap(map[mapper[CouponKeys.meta]]?[mapper[CouponKeys.reservation]])
          : null,
      order: map[mapper[CouponKeys.meta]]?[mapper[CouponKeys.order]] != null
          ? CouponOrder.fromMap(map[mapper[CouponKeys.meta]]?[mapper[CouponKeys.order]])
          : null,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Coupon.camel : Coupon.snake;
    if (reservation != null) (meta ??= {})[mapper[CouponKeys.reservation]!] = reservation!.toMap();
    if (order != null) (meta ??= {})[mapper[CouponKeys.order]!] = order!.toMap();
    return {
      mapper[CouponKeys.couponId]!: couponId,
      mapper[CouponKeys.clientId]!: clientId,
      if (locationId != null) mapper[CouponKeys.locationId]!: locationId,
      mapper[CouponKeys.type]!: type.code,
      mapper[CouponKeys.name]!: name,
      if (description != null) mapper[CouponKeys.description]!: description,
      if (discount != null) mapper[CouponKeys.discount]!: discount,
      if (code != null) mapper[CouponKeys.code]!: code,
      if (codes?.isNotEmpty ?? false) mapper[CouponKeys.codes]!: codes,
      if (image != null) mapper[CouponKeys.image]!: image,
      if (imageBh != null) mapper[CouponKeys.imageBh]!: imageBh,
      if (countries != null) mapper[CouponKeys.countries]!: countries!.toCodes(),
      if (rank != 1) mapper[CouponKeys.rank]!: rank,
      mapper[CouponKeys.validFrom]!: validFrom.value,
      if (validTo != null) mapper[CouponKeys.validTo]!: validTo?.value,
      if (blocked) mapper[CouponKeys.blocked]!: blocked,
      if (meta != null) mapper[CouponKeys.meta]!: meta,
      if (clientName != null) mapper[CouponKeys.clientName]!: clientName,
      if (clientLogo != null) mapper[CouponKeys.clientLogo]!: clientLogo,
      if (clientLogoBh != null) mapper[CouponKeys.clientLogoBh]!: clientLogoBh,
      if (clientColor != null) mapper[CouponKeys.clientColor]!: clientColor?.toHex(),
      if (locationName != null) mapper[CouponKeys.locationName]!: locationName,
      if (locationAddressLine1 != null) mapper[CouponKeys.locationAddressLine1]!: locationAddressLine1,
      if (locationAddressLine2 != null) mapper[CouponKeys.locationAddressLine2]!: locationAddressLine2,
      if (locationCity != null) mapper[CouponKeys.locationCity]!: locationCity,
      if (locationPoint != null) ...{
        mapper[CouponKeys.locationLongitude]!: locationPoint?.longitude,
        mapper[CouponKeys.locationLatitude]!: locationPoint?.latitude,
      },
      if (couponsIssued != null) mapper[CouponKeys.couponsIssued]!: couponsIssued,
    };
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Coupon) return couponId == other.couponId;
    return false;
  }

  @override
  int get hashCode => couponId.hashCode;
}

// eof

import "../../core_dart.dart";

enum UserCouponOnUserCardKeys {
  userCouponId,
  couponId,
  name,
  description,
  discount,
  image,
  imageBh,
  color,
  type,
  code,
  validFrom,
  validTo,
  locationId,
  locationName,
  locationAddressLine1,
  locationAddressLine2,
  locationCity,
}

class UserCouponOnUserCard {
  final String userCouponId;
  final String couponId;
  final String name;
  final String? description;
  final String? discount;
  final String? image;
  final String? imageBh;
  final Color? color;
  final CouponType type;
  final String? code;
  final IntDate validFrom;
  final IntDate? validTo;
  final String? locationId;
  final String? locationName;
  final String? locationAddressLine1;
  final String? locationAddressLine2;
  final String? locationCity;

  UserCouponOnUserCard({
    required this.userCouponId,
    required this.couponId,
    required this.name,
    this.description,
    required this.discount,
    this.image,
    this.imageBh,
    this.color,
    required this.type,
    this.code,
    required this.validFrom,
    this.validTo,
    this.locationId,
    this.locationName,
    this.locationAddressLine1,
    this.locationAddressLine2,
    this.locationCity,
  });

  UserCouponOnUserCard copyWith({
    String? name,
    String? description,
    String? image,
    String? imageBh,
    Color? color,
  }) {
    return UserCouponOnUserCard(
      userCouponId: userCouponId,
      couponId: couponId,
      name: name ?? this.name,
      description: description ?? this.description,
      discount: discount,
      image: image ?? this.image,
      imageBh: imageBh ?? this.imageBh,
      color: color ?? this.color,
      type: type,
      code: code,
      validFrom: validFrom,
      validTo: validTo,
      locationId: locationId,
      locationName: locationName,
      locationAddressLine1: locationAddressLine1,
      locationAddressLine2: locationAddressLine2,
      locationCity: locationCity,
    );
  }

  static const camel = {
    UserCouponOnUserCardKeys.userCouponId: "userCouponId",
    UserCouponOnUserCardKeys.couponId: "couponId",
    UserCouponOnUserCardKeys.name: "name",
    UserCouponOnUserCardKeys.description: "description",
    UserCouponOnUserCardKeys.discount: "discount",
    UserCouponOnUserCardKeys.image: "image",
    UserCouponOnUserCardKeys.imageBh: "imageBh",
    UserCouponOnUserCardKeys.color: "color",
    UserCouponOnUserCardKeys.type: "type",
    UserCouponOnUserCardKeys.code: "code",
    UserCouponOnUserCardKeys.validFrom: "validFrom",
    UserCouponOnUserCardKeys.validTo: "validTo",
    UserCouponOnUserCardKeys.locationId: "locationId",
    UserCouponOnUserCardKeys.locationName: "locationName",
    UserCouponOnUserCardKeys.locationAddressLine1: "locationAddressLine1",
    UserCouponOnUserCardKeys.locationAddressLine2: "locationAddressLine2",
    UserCouponOnUserCardKeys.locationCity: "locationCity",
  };

  static const snake = {
    UserCouponOnUserCardKeys.userCouponId: "user_coupon_id",
    UserCouponOnUserCardKeys.couponId: "coupon_id",
    UserCouponOnUserCardKeys.name: "name",
    UserCouponOnUserCardKeys.description: "description",
    UserCouponOnUserCardKeys.discount: "discount",
    UserCouponOnUserCardKeys.image: "image",
    UserCouponOnUserCardKeys.imageBh: "image_bh",
    UserCouponOnUserCardKeys.color: "color",
    UserCouponOnUserCardKeys.type: "type",
    UserCouponOnUserCardKeys.code: "code",
    UserCouponOnUserCardKeys.validFrom: "valid_from",
    UserCouponOnUserCardKeys.validTo: "valid_to",
    UserCouponOnUserCardKeys.locationId: "location_id",
    UserCouponOnUserCardKeys.locationName: "location_name",
    UserCouponOnUserCardKeys.locationAddressLine1: "location_address_line_1",
    UserCouponOnUserCardKeys.locationAddressLine2: "location_address_line_2",
    UserCouponOnUserCardKeys.locationCity: "location_city",
  };

  static UserCouponOnUserCard fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserCouponOnUserCard.camel : UserCouponOnUserCard.snake;
    return UserCouponOnUserCard(
      userCouponId: map[mapper[UserCouponOnUserCardKeys.userCouponId]!] as String,
      couponId: map[mapper[UserCouponOnUserCardKeys.couponId]!] as String,
      name: map[mapper[UserCouponOnUserCardKeys.name]!] as String,
      description: map[mapper[UserCouponOnUserCardKeys.description]!] as String?,
      discount: map[mapper[UserCouponOnUserCardKeys.discount]!] as String?,
      image: map[mapper[UserCouponOnUserCardKeys.image]!] as String?,
      imageBh: map[mapper[UserCouponOnUserCardKeys.imageBh]!] as String?,
      color: Color.fromHexOrNull(map[mapper[UserCouponOnUserCardKeys.color]!]),
      type: CouponTypeCode.fromCode(map[mapper[UserCouponOnUserCardKeys.type]!] as int?),
      code: map[mapper[UserCouponOnUserCardKeys.code]!] as String?,
      validFrom: IntDate.fromInt(map[mapper[UserCouponOnUserCardKeys.validFrom]] as int),
      validTo: IntDate.parseInt(map[mapper[UserCouponOnUserCardKeys.validTo]] as int?),
      locationId: map[mapper[UserCouponOnUserCardKeys.locationId]!] as String?,
      locationName: map[mapper[UserCouponOnUserCardKeys.locationName]!] as String?,
      locationAddressLine1: map[mapper[UserCouponOnUserCardKeys.locationAddressLine1]!] as String?,
      locationAddressLine2: map[mapper[UserCouponOnUserCardKeys.locationAddressLine2]!] as String?,
      locationCity: map[mapper[UserCouponOnUserCardKeys.locationCity]!] as String?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserCouponOnUserCard.camel : UserCouponOnUserCard.snake;
    return {
      mapper[UserCouponOnUserCardKeys.userCouponId]!: userCouponId,
      mapper[UserCouponOnUserCardKeys.couponId]!: couponId,
      mapper[UserCouponOnUserCardKeys.name]!: name,
      if (description != null) mapper[UserCouponOnUserCardKeys.description]!: description,
      if (discount != null) mapper[UserCouponOnUserCardKeys.discount]!: discount,
      if (image != null) mapper[UserCouponOnUserCardKeys.image]!: image,
      if (imageBh != null) mapper[UserCouponOnUserCardKeys.imageBh]!: imageBh,
      if (color != null) mapper[UserCouponOnUserCardKeys.color]!: color?.toHex(),
      if (code != null) mapper[UserCouponOnUserCardKeys.code]!: code,
      if (type != CouponType.universal) mapper[UserCouponOnUserCardKeys.type]!: type.code,
      mapper[UserCouponOnUserCardKeys.validFrom]!: validFrom.value,
      if (validTo != null) mapper[UserCouponOnUserCardKeys.validTo]!: validTo?.value,
      if (locationId != null) mapper[UserCouponOnUserCardKeys.locationId]!: locationId,
      if (locationName != null) mapper[UserCouponOnUserCardKeys.locationName]!: locationName,
      if (locationAddressLine1 != null) mapper[UserCouponOnUserCardKeys.locationAddressLine1]!: locationAddressLine1,
      if (locationAddressLine2 != null) mapper[UserCouponOnUserCardKeys.locationAddressLine2]!: locationAddressLine2,
      if (locationCity != null) mapper[UserCouponOnUserCardKeys.locationCity]!: locationCity,
    };
  }
}

// eof

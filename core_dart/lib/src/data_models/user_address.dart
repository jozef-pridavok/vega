import "package:core_dart/core_dart.dart";

enum UserAddressKeys {
  userAddressId,
  userId,
  name,
  addressLine1,
  addressLine2,
  city,
  zip,
  state,
  country,
  latitude,
  longitude,
}

class UserAddress {
  UserAddress({
    required this.userAddressId,
    required this.userId,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.zip,
    this.state,
    this.country,
    this.geoPoint,
  });

  final String userAddressId;
  final String userId;
  final String name;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? zip;
  final String? state;
  final Country? country;
  final GeoPoint? geoPoint;

  static const camel = {
    UserAddressKeys.userAddressId: "userAddressId",
    UserAddressKeys.userId: "userId",
    UserAddressKeys.name: "name",
    UserAddressKeys.addressLine1: "addressLine1",
    UserAddressKeys.addressLine2: "addressLine2",
    UserAddressKeys.city: "city",
    UserAddressKeys.zip: "zip",
    UserAddressKeys.state: "state",
    UserAddressKeys.country: "country",
    UserAddressKeys.latitude: "latitude",
    UserAddressKeys.longitude: "longitude",
  };

  static const snake = {
    UserAddressKeys.userAddressId: "user_address_id",
    UserAddressKeys.userId: "user_id",
    UserAddressKeys.name: "name",
    UserAddressKeys.addressLine1: "address_line_1",
    UserAddressKeys.addressLine2: "address_line_2",
    UserAddressKeys.city: "city",
    UserAddressKeys.zip: "zip",
    UserAddressKeys.state: "state",
    UserAddressKeys.country: "country",
    UserAddressKeys.latitude: "latitude",
    UserAddressKeys.longitude: "longitude",
  };

  UserAddress copyWith({
    String? userAddressId,
    String? userId,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? zip,
    String? state,
    Country? country,
    GeoPoint? geoPoint,
  }) {
    return UserAddress(
      userAddressId: userAddressId ?? this.userAddressId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      state: state ?? this.state,
      country: country ?? this.country,
      geoPoint: geoPoint ?? this.geoPoint,
    );
  }

  factory UserAddress.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserAddress.camel : UserAddress.snake;
    return UserAddress(
      userAddressId: map[mapper[UserAddressKeys.userAddressId]] as String,
      userId: map[mapper[UserAddressKeys.userId]] as String,
      name: map[mapper[UserAddressKeys.name]] as String,
      addressLine1: map[mapper[UserAddressKeys.addressLine1]] as String?,
      addressLine2: map[mapper[UserAddressKeys.addressLine2]] as String?,
      city: map[mapper[UserAddressKeys.city]] as String?,
      zip: map[mapper[UserAddressKeys.zip]] as String?,
      state: map[mapper[UserAddressKeys.state]] as String?,
      country: CountryCode.fromCodeOrNull(map[mapper[UserAddressKeys.country]]),
      geoPoint: GeoPoint.tryParse(map[mapper[UserAddressKeys.longitude]!], map[mapper[UserAddressKeys.latitude]!]),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserAddress.camel : UserAddress.snake;
    return {
      mapper[UserAddressKeys.userAddressId]!: userAddressId,
      mapper[UserAddressKeys.userId]!: userId,
      mapper[UserAddressKeys.name]!: name,
      if (addressLine1 != null) mapper[UserAddressKeys.addressLine1]!: addressLine1,
      if (addressLine2 != null) mapper[UserAddressKeys.addressLine2]!: addressLine2,
      if (city != null) mapper[UserAddressKeys.city]!: city,
      if (zip != null) mapper[UserAddressKeys.zip]!: zip,
      if (state != null) mapper[UserAddressKeys.state]!: state,
      if (country != null) mapper[UserAddressKeys.country]!: country!.code,
      if (geoPoint != null) ...{
        mapper[UserAddressKeys.longitude]!: geoPoint?.longitude,
        mapper[UserAddressKeys.latitude]!: geoPoint?.latitude,
      },
    };
  }
}

// eof

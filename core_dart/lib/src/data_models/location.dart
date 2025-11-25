import "package:core_dart/core_dart.dart";

enum LocationKeys {
  locationId,
  clientId,
  type,
  rank,
  name,
  description,
  addressLine1,
  addressLine2,
  city,
  zip,
  state,
  country,
  phone,
  email,
  website,
  openingHours,
  openingHoursExceptions,
  latitude,
  longitude,
}

class Location {
  String locationId;
  String clientId;
  LocationType type;
  int rank;
  String name;
  String? description;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? zip;
  String? state;
  Country? country;
  String? phone;
  String? email;
  OpeningHours? openingHours;
  OpeningHoursExceptions? openingHoursExceptions;
  String? website;
  double latitude;
  double longitude;

  GeoPoint geoPoint;

  Location({
    required this.locationId,
    required this.clientId,
    this.type = LocationType.mainBranch,
    this.rank = 1,
    required this.name,
    this.description,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.zip,
    this.state,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.openingHoursExceptions,
    required this.latitude,
    required this.longitude,
  }) : geoPoint = GeoPoint(latitude: latitude, longitude: longitude);

  Location copyWith({
    String? locationId,
    String? clientId,
    LocationType? type,
    int? rank,
    String? name,
    String? description,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? zip,
    String? state,
    Country? country,
    String? phone,
    String? email,
    String? website,
    OpeningHours? openingHours,
    OpeningHoursExceptions? openingHoursExceptions,
    double? latitude,
    double? longitude,
  }) {
    return Location(
      locationId: locationId ?? this.locationId,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      description: description ?? this.description,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      state: state ?? this.state,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      openingHoursExceptions: openingHoursExceptions ?? this.openingHoursExceptions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  static Location? _emptyInstance;

  factory Location.empty() {
    return _emptyInstance ??= Location(
      locationId: "",
      clientId: "",
      name: "",
      latitude: 0,
      longitude: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && other.locationId == locationId;
  }

  @override
  int get hashCode => locationId.hashCode;

  GeoPoint toGeoPoint() => GeoPoint(latitude: latitude, longitude: longitude);

  void setGeoPoint(GeoPoint point) {
    latitude = point.latitude;
    longitude = point.longitude;
  }

  static const camel = {
    LocationKeys.locationId: "locationId",
    LocationKeys.clientId: "clientId",
    LocationKeys.type: "type",
    LocationKeys.rank: "rank",
    LocationKeys.name: "name",
    LocationKeys.description: "description",
    LocationKeys.addressLine1: "addressLine1",
    LocationKeys.addressLine2: "addressLine2",
    LocationKeys.city: "city",
    LocationKeys.zip: "zip",
    LocationKeys.state: "state",
    LocationKeys.country: "country",
    LocationKeys.phone: "phone",
    LocationKeys.email: "email",
    LocationKeys.website: "website",
    LocationKeys.openingHours: "openingHours",
    LocationKeys.openingHoursExceptions: "openingHoursExceptions",
    LocationKeys.latitude: "latitude",
    LocationKeys.longitude: "longitude",
  };

  static const snake = {
    LocationKeys.locationId: "location_id",
    LocationKeys.clientId: "client_id",
    LocationKeys.type: "type",
    LocationKeys.rank: "rank",
    LocationKeys.name: "name",
    LocationKeys.description: "description",
    LocationKeys.addressLine1: "address_line_1",
    LocationKeys.addressLine2: "address_line_2",
    LocationKeys.city: "city",
    LocationKeys.zip: "zip",
    LocationKeys.state: "state",
    LocationKeys.country: "country",
    LocationKeys.phone: "phone",
    LocationKeys.email: "email",
    LocationKeys.website: "website",
    LocationKeys.openingHours: "opening_hours",
    LocationKeys.openingHoursExceptions: "opening_hours_exceptions",
    LocationKeys.latitude: "latitude",
    LocationKeys.longitude: "longitude",
  };

  factory Location.fromMap(Map<String, dynamic> map, Map<LocationKeys, String> mapper) {
    return Location(
      locationId: map[mapper[LocationKeys.locationId]!] as String,
      clientId: map[mapper[LocationKeys.clientId]!] as String,
      type: LocationTypeCode.fromCode(map[mapper[LocationKeys.type]!] as int?),
      rank: map[mapper[LocationKeys.rank]!] as int? ?? 1,
      name: map[mapper[LocationKeys.name]!] as String,
      description: map[mapper[LocationKeys.description]!] as String?,
      addressLine1: map[mapper[LocationKeys.addressLine1]!] as String?,
      addressLine2: map[mapper[LocationKeys.addressLine2]!] as String?,
      city: map[mapper[LocationKeys.city]!] as String?,
      zip: map[mapper[LocationKeys.zip]!] as String?,
      state: map[mapper[LocationKeys.state]!] as String?,
      country: CountryCode.fromCodeOrNull(map[mapper[LocationKeys.country]!] as String?),
      phone: map[mapper[LocationKeys.phone]!] as String?,
      email: map[mapper[LocationKeys.email]!] as String?,
      website: map[mapper[LocationKeys.website]!] as String?,
      openingHours: OpeningHours.fromMapOrNull(map[mapper[LocationKeys.openingHours]!] as Map<String, dynamic>?),
      openingHoursExceptions: OpeningHoursExceptions.fromMapOrNull(
          map[mapper[LocationKeys.openingHoursExceptions]!] as Map<String, dynamic>?),
      latitude: map[mapper[LocationKeys.latitude]!] as double,
      longitude: map[mapper[LocationKeys.longitude]!] as double,
    );
  }

  Map<String, dynamic> toMap(Map<LocationKeys, String> mapper) {
    return <String, dynamic>{
      mapper[LocationKeys.locationId]!: locationId,
      mapper[LocationKeys.clientId]!: clientId,
      mapper[LocationKeys.type]!: type.code,
      if (rank != 1) mapper[LocationKeys.rank]!: rank,
      mapper[LocationKeys.name]!: name,
      if (description != null) mapper[LocationKeys.description]!: description,
      if (addressLine1 != null) mapper[LocationKeys.addressLine1]!: addressLine1,
      if (addressLine2 != null) mapper[LocationKeys.addressLine2]!: addressLine2,
      if (city != null) mapper[LocationKeys.city]!: city,
      if (zip != null) mapper[LocationKeys.zip]!: zip,
      if (state != null) mapper[LocationKeys.state]!: state,
      if (country != null) mapper[LocationKeys.country]!: country!.code,
      if (phone != null) mapper[LocationKeys.phone]!: phone,
      if (email != null) mapper[LocationKeys.email]!: email,
      if (website != null) mapper[LocationKeys.website]!: website,
      if (openingHours != null) mapper[LocationKeys.openingHours]!: openingHours!.toMap(),
      if (openingHoursExceptions != null) mapper[LocationKeys.openingHoursExceptions]!: openingHoursExceptions!.toMap(),
      mapper[LocationKeys.latitude]!: latitude,
      mapper[LocationKeys.longitude]!: longitude,
    };
  }

  String buildAddress() {
    final address = StringBuffer();
    if (addressLine1 != null) {
      address.write(addressLine1);
      if (addressLine2 != null) {
        address.write(", ");
        address.write(addressLine2);
      }
    }
    if (city != null) {
      if (address.isNotEmpty) address.write(", ");
      address.write(city);
    }
    return address.toString().trim();
  }
}

// eof

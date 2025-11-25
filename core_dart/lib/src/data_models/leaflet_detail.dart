import "package:core_dart/core_dart.dart";

enum LeafletDetailKeys {
  leafletId,
  clientId,
  locationId,
  locationName,
  locationAddressLine1,
  locationAddressLine2,
  locationCity,
  country,
  name,
  rank,
  validFrom,
  validTo,
  thumbnail,
  thumbnailBh,
  leaflet,
  pages,
  pagesBh,
  updatedAt,
}

class LeafletDetail {
  String leafletId;
  String clientId;
  String? locationId;
  String? locationName;
  String? locationAddressLine1;
  String? locationAddressLine2;
  String? locationCity;
  Country country;
  String name;
  int rank;
  IntDate validFrom;
  IntDate validTo;
  String? thumbnail;
  String? thumbnailBh;
  String? leaflet;
  List<String>? pages;
  List<String>? pagesBh;
  DateTime? updatedAt;

  LeafletDetail({
    required this.leafletId,
    required this.clientId,
    this.locationId,
    this.locationName,
    this.locationAddressLine1,
    this.locationAddressLine2,
    this.locationCity,
    required this.country,
    required this.name,
    required this.rank,
    required this.validFrom,
    required this.validTo,
    this.thumbnail,
    this.thumbnailBh,
    this.leaflet,
    this.pages,
    this.pagesBh,
    this.updatedAt,
  });

  static const camel = {
    LeafletDetailKeys.leafletId: "leafletId",
    LeafletDetailKeys.clientId: "clientId",
    LeafletDetailKeys.locationId: "locationId",
    LeafletDetailKeys.locationName: "locationName",
    LeafletDetailKeys.locationAddressLine1: "locationAddressLine1",
    LeafletDetailKeys.locationAddressLine2: "locationAddressLine2",
    LeafletDetailKeys.locationCity: "locationCity",
    LeafletDetailKeys.country: "country",
    LeafletDetailKeys.name: "name",
    LeafletDetailKeys.rank: "rank",
    LeafletDetailKeys.validFrom: "validFrom",
    LeafletDetailKeys.validTo: "validTo",
    LeafletDetailKeys.thumbnail: "thumbnail",
    LeafletDetailKeys.thumbnailBh: "thumbnailBh",
    LeafletDetailKeys.leaflet: "leaflet",
    LeafletDetailKeys.pages: "pages",
    LeafletDetailKeys.pagesBh: "pagesBh",
    LeafletDetailKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    LeafletDetailKeys.leafletId: "leaflet_id",
    LeafletDetailKeys.clientId: "client_id",
    LeafletDetailKeys.locationId: "location_id",
    LeafletDetailKeys.locationName: "location_name",
    LeafletDetailKeys.locationAddressLine1: "location_address_line_1",
    LeafletDetailKeys.locationAddressLine2: "location_address_line_2",
    LeafletDetailKeys.locationCity: "location_city",
    LeafletDetailKeys.country: "country",
    LeafletDetailKeys.name: "name",
    LeafletDetailKeys.rank: "rank",
    LeafletDetailKeys.validFrom: "valid_from",
    LeafletDetailKeys.validTo: "valid_to",
    LeafletDetailKeys.thumbnail: "thumbnail",
    LeafletDetailKeys.thumbnailBh: "thumbnail_bh",
    LeafletDetailKeys.leaflet: "leaflet",
    LeafletDetailKeys.pages: "pages",
    LeafletDetailKeys.pagesBh: "pages_bh",
    LeafletDetailKeys.updatedAt: "updated_at",
  };

  factory LeafletDetail.fromMap(Map<String, dynamic> map, Map<LeafletDetailKeys, String> mapper) => LeafletDetail(
        leafletId: map[mapper[LeafletDetailKeys.leafletId]] as String,
        clientId: map[mapper[LeafletDetailKeys.clientId]] as String,
        locationId: map[mapper[LeafletDetailKeys.locationId]] as String?,
        locationName: map[mapper[LeafletDetailKeys.locationName]] as String?,
        locationAddressLine1: map[mapper[LeafletDetailKeys.locationAddressLine1]] as String?,
        locationAddressLine2: map[mapper[LeafletDetailKeys.locationAddressLine2]] as String?,
        locationCity: map[mapper[LeafletDetailKeys.locationCity]] as String?,
        country: CountryCode.fromCode(map[mapper[LeafletDetailKeys.country]]),
        name: map[mapper[LeafletDetailKeys.name]] as String,
        rank: map[mapper[LeafletDetailKeys.rank]] as int? ?? 1,
        validFrom: IntDate.fromInt(map[mapper[LeafletDetailKeys.validFrom]] as int),
        validTo: IntDate.fromInt(map[mapper[LeafletDetailKeys.validTo]] as int),
        thumbnail: map[mapper[LeafletDetailKeys.thumbnail]] as String?,
        thumbnailBh: map[mapper[LeafletDetailKeys.thumbnailBh]] as String?,
        leaflet: map[mapper[LeafletDetailKeys.leaflet]] as String?,
        pages: (map[mapper[LeafletDetailKeys.pages]] as List<dynamic>?)?.cast<String>(),
        pagesBh: (map[mapper[LeafletDetailKeys.pagesBh]] as List<dynamic>?)?.cast<String>(),
        updatedAt: tryParseDateTime(map[mapper[LeafletDetailKeys.updatedAt]]),
      );

  Map<String, dynamic> toMap(Map<LeafletDetailKeys, String> mapper) => {
        mapper[LeafletDetailKeys.leafletId]!: leafletId,
        mapper[LeafletDetailKeys.clientId]!: clientId,
        if (locationId != null) mapper[LeafletDetailKeys.locationId]!: locationId,
        if (locationName != null) mapper[LeafletDetailKeys.locationName]!: locationName,
        if (locationAddressLine1 != null) mapper[LeafletDetailKeys.locationAddressLine1]!: locationAddressLine1,
        if (locationAddressLine2 != null) mapper[LeafletDetailKeys.locationAddressLine2]!: locationAddressLine2,
        if (locationCity != null) mapper[LeafletDetailKeys.locationCity]!: locationCity,
        mapper[LeafletDetailKeys.country]!: country.code,
        mapper[LeafletDetailKeys.name]!: name,
        if (rank != 1) mapper[LeafletDetailKeys.rank]!: rank,
        mapper[LeafletDetailKeys.validFrom]!: validFrom.value,
        mapper[LeafletDetailKeys.validTo]!: validTo.value,
        if (thumbnail != null) mapper[LeafletDetailKeys.thumbnail]!: thumbnail,
        if (thumbnailBh != null) mapper[LeafletDetailKeys.thumbnailBh]!: thumbnailBh,
        if (leaflet != null) mapper[LeafletDetailKeys.leaflet]!: leaflet,
        if (pages != null) mapper[LeafletDetailKeys.pages]!: pages,
        if (pagesBh != null) mapper[LeafletDetailKeys.pagesBh]!: pagesBh,
      };
}

// eof

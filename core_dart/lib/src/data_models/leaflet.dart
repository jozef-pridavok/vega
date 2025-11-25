import "package:core_dart/core_dart.dart";

enum LeafletKeys {
  leafletId,
  clientId,
  locationId,
  locationName,
  locationZip,
  locationCity,
  country,
  name,
  rank,
  validFrom,
  validTo,
  blocked,
  thumbnail,
  thumbnailBh,
  leaflet,
  pages,
  pagesBh,
  meta,
  updatedAt,
}

class Leaflet {
  String leafletId;
  String clientId;
  String? locationId;
  String? locationName;
  String? locationCity;
  String? locationZip;
  Country country;
  String name;
  int rank;
  IntDate validFrom;
  IntDate validTo;
  bool blocked;
  String? thumbnail;
  String? thumbnailBh;
  String? leaflet;
  List<String> pages;
  List<String> pagesBh;
  Map<String, dynamic>? meta;
  DateTime? updatedAt;

  Leaflet({
    required this.leafletId,
    required this.clientId,
    this.locationId,
    this.locationName,
    this.locationZip,
    this.locationCity,
    required this.country,
    required this.name,
    this.rank = 1,
    required this.validFrom,
    required this.validTo,
    this.blocked = false,
    this.thumbnail,
    this.thumbnailBh,
    this.leaflet,
    this.pages = const [],
    this.pagesBh = const [],
    this.meta,
    this.updatedAt,
  });

  Leaflet copyWith({
    String? leafletId,
    String? clientId,
    String? locationId,
    Country? country,
    String? name,
    int? rank,
    IntDate? validFrom,
    IntDate? validTo,
    String? thumbnail,
    String? thumbnailBh,
    String? leaflet,
    List<String>? pages,
    List<String>? pagesBh,
    bool? blocked,
  }) {
    return Leaflet(
      leafletId: leafletId ?? this.leafletId,
      clientId: clientId ?? this.clientId,
      locationId: locationId ?? this.locationId,
      country: country ?? this.country,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailBh: thumbnailBh ?? this.thumbnailBh,
      leaflet: leaflet ?? this.leaflet,
      pages: pages ?? this.pages,
      pagesBh: pagesBh ?? this.pagesBh,
      blocked: blocked ?? this.blocked,
    );
  }

  static const camel = {
    LeafletKeys.leafletId: "leafletId",
    LeafletKeys.clientId: "clientId",
    LeafletKeys.locationId: "locationId",
    LeafletKeys.locationName: "locationName",
    LeafletKeys.locationZip: "locationZip",
    LeafletKeys.locationCity: "locationCity",
    LeafletKeys.country: "country",
    LeafletKeys.name: "name",
    LeafletKeys.rank: "rank",
    LeafletKeys.validFrom: "validFrom",
    LeafletKeys.validTo: "validTo",
    LeafletKeys.blocked: "blocked",
    LeafletKeys.thumbnail: "thumbnail",
    LeafletKeys.thumbnailBh: "thumbnailBh",
    LeafletKeys.leaflet: "leaflet",
    LeafletKeys.pages: "pages",
    LeafletKeys.pagesBh: "pagesBh",
    LeafletKeys.meta: "meta",
    LeafletKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    LeafletKeys.leafletId: "leaflet_id",
    LeafletKeys.clientId: "client_id",
    LeafletKeys.locationId: "location_id",
    LeafletKeys.locationName: "location_name",
    LeafletKeys.locationCity: "location_city",
    LeafletKeys.locationZip: "location_zip",
    LeafletKeys.country: "country",
    LeafletKeys.name: "name",
    LeafletKeys.rank: "rank",
    LeafletKeys.validFrom: "valid_from",
    LeafletKeys.validTo: "valid_to",
    LeafletKeys.blocked: "blocked",
    LeafletKeys.thumbnail: "thumbnail",
    LeafletKeys.thumbnailBh: "thumbnail_bh",
    LeafletKeys.leaflet: "leaflet",
    LeafletKeys.pages: "pages",
    LeafletKeys.pagesBh: "pages_bh",
    LeafletKeys.meta: "meta",
    LeafletKeys.updatedAt: "updated_at",
  };

  factory Leaflet.fromMap(Map<String, dynamic> map, Map<LeafletKeys, String> mapper) => Leaflet(
        leafletId: map[mapper[LeafletKeys.leafletId]] as String,
        clientId: map[mapper[LeafletKeys.clientId]] as String,
        locationId: map[mapper[LeafletKeys.locationId]] as String?,
        locationName: map[mapper[LeafletKeys.locationName]] as String?,
        locationCity: map[mapper[LeafletKeys.locationCity]] as String?,
        locationZip: map[mapper[LeafletKeys.locationZip]] as String?,
        country: CountryCode.fromCode(map[mapper[LeafletKeys.country]]),
        name: map[mapper[LeafletKeys.name]] as String,
        rank: map[mapper[LeafletKeys.rank]] as int? ?? 1,
        validFrom: IntDate.fromInt(map[mapper[LeafletKeys.validFrom]] as int),
        validTo: IntDate.fromInt(map[mapper[LeafletKeys.validTo]] as int),
        blocked: map[mapper[LeafletKeys.blocked]] as bool? ?? false,
        thumbnail: map[mapper[LeafletKeys.thumbnail]] as String?,
        thumbnailBh: map[mapper[LeafletKeys.thumbnailBh]] as String?,
        leaflet: map[mapper[LeafletKeys.leaflet]] as String?,
        pages: (map[mapper[LeafletKeys.pages]] as List<dynamic>?)?.cast<String>() ?? [],
        pagesBh: (map[mapper[LeafletKeys.pagesBh]] as List<dynamic>?)?.cast<String>() ?? [],
        meta: map[mapper[LeafletKeys.meta]!] as Map<String, dynamic>?,
        updatedAt: tryParseDateTime(map[mapper[LeafletKeys.updatedAt]]),
      );

  Map<String, dynamic> toMap(Map<LeafletKeys, String> mapper) => {
        mapper[LeafletKeys.leafletId]!: leafletId,
        mapper[LeafletKeys.clientId]!: clientId,
        if (locationId != null) mapper[LeafletKeys.locationId]!: locationId,
        if (locationName != null) mapper[LeafletKeys.locationName]!: locationName,
        if (locationCity != null) mapper[LeafletKeys.locationCity]!: locationCity,
        if (locationZip != null) mapper[LeafletKeys.locationZip]!: locationZip,
        mapper[LeafletKeys.country]!: country.code,
        mapper[LeafletKeys.name]!: name,
        if (rank != 1) mapper[LeafletKeys.rank]!: rank,
        mapper[LeafletKeys.validFrom]!: validFrom.value,
        mapper[LeafletKeys.validTo]!: validTo.value,
        if (blocked) mapper[LeafletKeys.blocked]!: blocked,
        if (thumbnail != null) mapper[LeafletKeys.thumbnail]!: thumbnail,
        if (thumbnailBh != null) mapper[LeafletKeys.thumbnailBh]!: thumbnailBh,
        if (leaflet != null) mapper[LeafletKeys.leaflet]!: leaflet,
        mapper[LeafletKeys.pages]!: pages,
        mapper[LeafletKeys.pagesBh]!: pagesBh,
        if (meta != null) mapper[LeafletKeys.meta]!: meta,
      };
}

// eof

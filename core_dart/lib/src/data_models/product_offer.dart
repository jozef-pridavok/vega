import "../../core_dart.dart";

enum ProductOfferKeys {
  offerId,
  clientId,
  programId,
  locationId,
  name,
  description,
  loyaltyMode,
  type,
  date,
  rank,
  blocked,
  meta,
  updatedAt,
  //
  sections,
  items,
  modifications,
  options,
}

class ProductOffer {
  String offerId;
  String clientId;
  String? programId;
  String? locationId;
  String name;
  String? description;
  LoyaltyMode loyaltyMode;
  ProductOfferType type;
  IntDate date;
  int rank;
  bool blocked;
  JsonObject? meta;
  DateTime? updatedAt;

  List<ProductSection>? sections;
  List<ProductItem>? items;
  List<ProductItemModification>? modifications;
  List<ProductItemOption>? options;

  ProductOffer({
    required this.offerId,
    required this.clientId,
    this.programId,
    this.locationId,
    required this.name,
    this.description,
    required this.loyaltyMode,
    required this.type,
    required this.date,
    this.rank = 1,
    this.blocked = false,
    this.meta,
    this.updatedAt,
    this.sections,
    this.items,
    this.modifications,
    this.options,
  });

  static ProductOffer? _emptyInstance;

  factory ProductOffer.empty() {
    return _emptyInstance ??= ProductOffer(
      clientId: "",
      offerId: "",
      name: "",
      loyaltyMode: LoyaltyMode.none,
      type: ProductOfferType.regular,
      date: IntDate.now(),
    );
  }

  static const camel = {
    ProductOfferKeys.offerId: "offerId",
    ProductOfferKeys.clientId: "clientId",
    ProductOfferKeys.programId: "programId",
    ProductOfferKeys.locationId: "locationId",
    ProductOfferKeys.name: "name",
    ProductOfferKeys.description: "description",
    ProductOfferKeys.loyaltyMode: "loyaltyMode",
    ProductOfferKeys.type: "type",
    ProductOfferKeys.date: "date",
    ProductOfferKeys.rank: "rank",
    ProductOfferKeys.blocked: "blocked",
    ProductOfferKeys.meta: "meta",
    ProductItemKeys.updatedAt: "updatedAt",
    ProductOfferKeys.sections: "sections",
    ProductOfferKeys.items: "items",
    ProductOfferKeys.modifications: "modifications",
    ProductOfferKeys.options: "options",
  };

  static const snake = {
    ProductOfferKeys.offerId: "offer_id",
    ProductOfferKeys.clientId: "client_id",
    ProductOfferKeys.programId: "program_id",
    ProductOfferKeys.locationId: "location_id",
    ProductOfferKeys.name: "name",
    ProductOfferKeys.description: "description",
    ProductOfferKeys.loyaltyMode: "loyalty_mode",
    ProductOfferKeys.type: "type",
    ProductOfferKeys.date: "date",
    ProductOfferKeys.rank: "rank",
    ProductOfferKeys.blocked: "blocked",
    ProductOfferKeys.meta: "meta",
    ProductItemKeys.updatedAt: "updated_at",
    ProductOfferKeys.sections: "sections",
    ProductOfferKeys.items: "items",
    ProductOfferKeys.modifications: "modifications",
    ProductOfferKeys.options: "options",
  };

  static ProductOffer fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProductOffer.camel : ProductOffer.snake;
    return ProductOffer(
      offerId: map[mapper[ProductOfferKeys.offerId]] as String,
      clientId: map[mapper[ProductOfferKeys.clientId]] as String,
      programId: map[mapper[ProductOfferKeys.programId]] as String?,
      locationId: map[mapper[ProductOfferKeys.locationId]] as String?,
      name: map[mapper[ProductOfferKeys.name]] as String,
      description: map[mapper[ProductOfferKeys.description]] as String?,
      loyaltyMode: LoyaltyModeCode.fromCode(map[mapper[ProductOfferKeys.loyaltyMode]] as int),
      type: ProductOfferTypeCode.fromCode(map[mapper[ProductOfferKeys.type]!] as int?),
      date: IntDate.fromInt(map[mapper[ProductOfferKeys.date]] as int),
      rank: map[mapper[ProductOfferKeys.rank]] as int? ?? 1,
      blocked: (map[mapper[ProductOfferKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ProductOfferKeys.meta]] as JsonObject?,
      updatedAt: tryParseDateTime(map[mapper[ProductItemKeys.updatedAt]]),
      sections: (map[mapper[ProductOfferKeys.sections]] as List<dynamic>?)
          ?.map((e) => ProductSection.fromMap(e, convention))
          .toList(),
      items: (map[mapper[ProductOfferKeys.items]] as List<dynamic>?)
          ?.map((e) => ProductItem.fromMap(e, convention))
          .toList(),
      modifications: (map[mapper[ProductOfferKeys.modifications]] as List<dynamic>?)
          ?.map((e) => ProductItemModification.fromMap(e, convention))
          .toList(),
      options: (map[mapper[ProductOfferKeys.options]] as List<dynamic>?)
          ?.map((e) => ProductItemOption.fromMap(e, convention))
          .toList(),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProductOffer.camel : ProductOffer.snake;
    return {
      mapper[ProductOfferKeys.offerId]!: offerId,
      mapper[ProductOfferKeys.clientId]!: clientId,
      if (programId != null) mapper[ProductOfferKeys.programId]!: programId,
      if (locationId != null) mapper[ProductOfferKeys.locationId]!: locationId,
      mapper[ProductOfferKeys.name]!: name,
      if (description != null) mapper[ProductOfferKeys.description]!: description,
      mapper[ProductOfferKeys.loyaltyMode]!: loyaltyMode.code,
      mapper[ProductOfferKeys.type]!: type.code,
      mapper[ProductOfferKeys.date]!: date.value,
      if (rank != 1) mapper[ProductOfferKeys.rank]!: rank,
      if (blocked) mapper[ProductOfferKeys.blocked]!: blocked,
      if (meta != null) mapper[ProductOfferKeys.meta]!: meta,
      if (updatedAt != null) mapper[ProductItemKeys.updatedAt]!: updatedAt!.toIso8601String(),
      if (sections != null) mapper[ProductOfferKeys.sections]!: sections!.map((e) => e.toMap(convention)).toList(),
      if (items != null) mapper[ProductOfferKeys.items]!: items!.map((e) => e.toMap(convention)).toList(),
      if (modifications != null)
        mapper[ProductOfferKeys.modifications]!: modifications!.map((e) => e.toMap(convention)).toList(),
      if (options != null) mapper[ProductOfferKeys.options]!: options!.map((e) => e.toMap(convention)).toList(),
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductOffer && offerId == other.offerId;

  @override
  int get hashCode => offerId.hashCode;
}


// eof

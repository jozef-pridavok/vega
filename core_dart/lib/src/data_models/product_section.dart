import "../../core_dart.dart";

enum ProductSectionKeys {
  sectionId,
  clientId,
  offerId,
  name,
  description,
  rank,
  blocked,
  meta,
}

class ProductSection {
  String sectionId;
  String? clientId;
  String? offerId;
  String name;
  String? description;
  int rank;
  bool blocked;
  JsonObject? meta;

  ProductSection({
    required this.sectionId,
    this.clientId,
    this.offerId,
    required this.name,
    this.description,
    this.rank = 1,
    this.blocked = false,
    this.meta,
  });

  static ProductSection? _emptyInstance;

  factory ProductSection.empty() {
    return _emptyInstance ??= ProductSection(
      sectionId: "",
      clientId: "",
      offerId: "",
      name: "",
    );
  }

  static const camel = {
    ProductSectionKeys.sectionId: "sectionId",
    ProductSectionKeys.clientId: "clientId",
    ProductSectionKeys.offerId: "offerId",
    ProductSectionKeys.name: "name",
    ProductSectionKeys.description: "description",
    ProductSectionKeys.rank: "rank",
    ProductSectionKeys.blocked: "blocked",
    ProductSectionKeys.meta: "meta",
  };

  static const snake = {
    ProductSectionKeys.sectionId: "section_id",
    ProductSectionKeys.clientId: "client_id",
    ProductSectionKeys.offerId: "offer_id",
    ProductSectionKeys.name: "name",
    ProductSectionKeys.description: "description",
    ProductSectionKeys.rank: "rank",
    ProductSectionKeys.blocked: "blocked",
    ProductSectionKeys.meta: "meta",
  };

  static ProductSection fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProductSection.camel : ProductSection.snake;
    return ProductSection(
      sectionId: map[mapper[ProductSectionKeys.sectionId]] as String,
      clientId: map[mapper[ProductSectionKeys.clientId]] as String?,
      offerId: map[mapper[ProductSectionKeys.offerId]] as String?,
      name: map[mapper[ProductSectionKeys.name]] as String,
      description: map[mapper[ProductSectionKeys.description]] as String?,
      rank: map[mapper[ProductSectionKeys.rank]] as int? ?? 1,
      blocked: (map[mapper[ProductSectionKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ProductSectionKeys.meta]] as JsonObject?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProductSection.camel : ProductSection.snake;
    return {
      mapper[ProductSectionKeys.sectionId]!: sectionId,
      if (clientId != null) mapper[ProductSectionKeys.clientId]!: clientId,
      if (offerId != null) mapper[ProductSectionKeys.offerId]!: offerId,
      mapper[ProductSectionKeys.name]!: name,
      if (description != null) mapper[ProductSectionKeys.description]!: description,
      if (rank != 1) mapper[ProductSectionKeys.rank]!: rank,
      if (blocked) mapper[ProductSectionKeys.blocked]!: blocked,
      if (meta != null) mapper[ProductSectionKeys.meta]!: meta,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductSection && sectionId == other.sectionId;

  @override
  int get hashCode => sectionId.hashCode;
}


// eof

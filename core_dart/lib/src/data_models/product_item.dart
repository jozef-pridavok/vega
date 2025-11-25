import "../../core_dart.dart";

enum ProductItemKeys {
  itemId,
  sectionId,
  clientId,
  name,
  description,
  photo,
  photoBh,
  rank,
  price,
  currency,
  qtyPrecision,
  unit,
  blocked,
  meta,
  updatedAt,
}

class ProductItem {
  String itemId;
  String? sectionId;
  String clientId;
  String name;
  String? description;
  String? photo;
  String? photoBh;
  int rank;
  int? price;
  Currency currency;
  int qtyPrecision;
  String? unit;
  bool blocked;
  JsonObject? meta;
  DateTime? updatedAt;

  ProductItem({
    required this.itemId,
    this.sectionId,
    required this.clientId,
    required this.name,
    this.description,
    this.photo,
    this.photoBh,
    this.rank = 1,
    this.price,
    required this.currency,
    this.qtyPrecision = 0,
    this.unit,
    this.blocked = false,
    this.meta,
    this.updatedAt,
  });

  static ProductItem? _emptyInstance;

  factory ProductItem.empty() {
    return _emptyInstance ??= ProductItem(
      clientId: "",
      itemId: "",
      sectionId: "",
      name: "",
      rank: 0,
      currency: defaultCurrency,
    );
  }

  static const camel = {
    ProductItemKeys.itemId: "itemId",
    ProductItemKeys.sectionId: "sectionId",
    ProductItemKeys.clientId: "clientId",
    ProductItemKeys.name: "name",
    ProductItemKeys.description: "description",
    ProductItemKeys.photo: "photo",
    ProductItemKeys.photoBh: "photoBh",
    ProductItemKeys.rank: "rank",
    ProductItemKeys.price: "price",
    ProductItemKeys.currency: "currency",
    ProductItemKeys.qtyPrecision: "qtyPrecision",
    ProductItemKeys.unit: "unit",
    ProductItemKeys.blocked: "blocked",
    ProductItemKeys.meta: "meta",
    ProductItemKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    ProductItemKeys.itemId: "item_id",
    ProductItemKeys.sectionId: "section_id",
    ProductItemKeys.clientId: "client_id",
    ProductItemKeys.name: "name",
    ProductItemKeys.description: "description",
    ProductItemKeys.photo: "photo",
    ProductItemKeys.photoBh: "photo_bh",
    ProductItemKeys.rank: "rank",
    ProductItemKeys.price: "price",
    ProductItemKeys.currency: "currency",
    ProductItemKeys.qtyPrecision: "qty_precision",
    ProductItemKeys.unit: "unit",
    ProductItemKeys.blocked: "blocked",
    ProductItemKeys.meta: "meta",
    ProductItemKeys.updatedAt: "updated_at",
  };

  static ProductItem fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProductItem.camel : ProductItem.snake;
    return ProductItem(
      itemId: map[mapper[ProductItemKeys.itemId]] as String,
      sectionId: map[mapper[ProductItemKeys.sectionId]] as String?,
      clientId: map[mapper[ProductItemKeys.clientId]] as String,
      name: map[mapper[ProductItemKeys.name]] as String,
      description: map[mapper[ProductItemKeys.description]] as String?,
      photo: map[mapper[ProductItemKeys.photo]] as String?,
      photoBh: map[mapper[ProductItemKeys.photoBh]] as String?,
      rank: map[mapper[ProductItemKeys.rank]] as int? ?? 1,
      price: map[mapper[ProductItemKeys.price]] as int?,
      currency: CurrencyCode.fromCode(map[mapper[ProductItemKeys.currency]!] as String),
      qtyPrecision: map[mapper[ProductItemKeys.qtyPrecision]] as int,
      unit: map[mapper[ProductItemKeys.unit]] as String?,
      blocked: (map[mapper[ProductItemKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ProductItemKeys.meta]] as JsonObject?,
      updatedAt: tryParseDateTime(map[mapper[ProductItemKeys.updatedAt]]),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProductItem.camel : ProductItem.snake;
    return {
      mapper[ProductItemKeys.itemId]!: itemId,
      if (sectionId != null) mapper[ProductItemKeys.sectionId]!: sectionId,
      mapper[ProductItemKeys.clientId]!: clientId,
      mapper[ProductItemKeys.name]!: name,
      if (description != null) mapper[ProductItemKeys.description]!: description,
      if (photo != null) mapper[ProductItemKeys.photo]!: photo,
      if (photoBh != null) mapper[ProductItemKeys.photoBh]!: photoBh,
      if (rank != 1) mapper[ProductItemKeys.rank]!: rank,
      if (price != null) mapper[ProductItemKeys.price]!: price,
      mapper[ProductItemKeys.currency]!: currency.code,
      mapper[ProductItemKeys.qtyPrecision]!: qtyPrecision,
      if (unit != null) mapper[ProductItemKeys.unit]!: unit,
      if (blocked) mapper[ProductItemKeys.blocked]!: blocked,
      if (meta != null) mapper[ProductItemKeys.meta]!: meta,
      if (updatedAt != null) mapper[ProductItemKeys.updatedAt]!: updatedAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductItem && itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;
}

// Sorted by rank

extension SortedProductItemList on Iterable<ProductItem> {
  /// Returns a new list of [ProductItem] sorted by [compare] predicate. If compare is null, sort by rank then by name.
  List<ProductItem> sorted({int Function(ProductItem a, ProductItem b)? compare}) {
    final list = toList();
    list.sort(compare ??
        (a, b) {
          final rankComparison = a.rank.compareTo(b.rank);
          return rankComparison == 0 ? a.name.compareTo(b.name) : rankComparison;
        });
    return list;
  }
}

// eof

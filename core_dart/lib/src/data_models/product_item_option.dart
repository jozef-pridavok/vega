import "../../core_dart.dart";

enum ProductItemOptionKeys {
  optionId,
  modificationId,
  clientId,
  name,
  price,
  pricing,
  unit,
  rank,
  blocked,
  meta,
}

class ProductItemOption {
  String optionId;
  String modificationId;
  String? clientId;
  String name;
  int price;
  ProductItemOptionPricing pricing;
  String unit;
  int rank;
  bool blocked;
  JsonObject? meta;

  ProductItemOption({
    required this.optionId,
    required this.modificationId,
    this.clientId,
    required this.name,
    required this.price,
    this.pricing = ProductItemOptionPricing.add,
    required this.unit,
    this.rank = 1,
    this.blocked = false,
    this.meta,
  });

  static ProductItemOption? _emptyInstance;

  factory ProductItemOption.empty() {
    return _emptyInstance ??= ProductItemOption(
      optionId: "",
      modificationId: "",
      price: 0,
      name: "",
      unit: "kg",
    );
  }

  static const camel = {
    ProductItemOptionKeys.optionId: "optionId",
    ProductItemOptionKeys.modificationId: "modificationId",
    ProductItemOptionKeys.clientId: "clientId",
    ProductItemOptionKeys.name: "name",
    ProductItemOptionKeys.price: "price",
    ProductItemOptionKeys.pricing: "pricing",
    ProductItemOptionKeys.unit: "unit",
    ProductItemOptionKeys.rank: "rank",
    ProductItemOptionKeys.blocked: "blocked",
    ProductItemOptionKeys.meta: "meta",
  };

  static const snake = {
    ProductItemOptionKeys.optionId: "option_id",
    ProductItemOptionKeys.modificationId: "modification_id",
    ProductItemOptionKeys.clientId: "client_id",
    ProductItemOptionKeys.name: "name",
    ProductItemOptionKeys.price: "price",
    ProductItemOptionKeys.pricing: "pricing",
    ProductItemOptionKeys.unit: "unit",
    ProductItemOptionKeys.rank: "rank",
    ProductItemOptionKeys.blocked: "blocked",
    ProductItemOptionKeys.meta: "meta",
  };

  static ProductItemOption fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProductItemOption.camel : ProductItemOption.snake;
    return ProductItemOption(
      optionId: map[mapper[ProductItemOptionKeys.optionId]] as String,
      modificationId: map[mapper[ProductItemOptionKeys.modificationId]] as String,
      clientId: map[mapper[ProductItemOptionKeys.clientId]] as String?,
      name: map[mapper[ProductItemOptionKeys.name]] as String,
      price: map[mapper[ProductItemOptionKeys.price]] as int,
      pricing: ProductItemOptionPricingCode.fromCode(map[mapper[ProductItemOptionKeys.pricing]] as int?),
      unit: map[mapper[ProductItemOptionKeys.unit]] as String,
      rank: map[mapper[ProductItemOptionKeys.rank]] as int? ?? 1,
      blocked: (map[mapper[ProductItemOptionKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ProductItemOptionKeys.meta]] as JsonObject?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProductItemOption.camel : ProductItemOption.snake;
    return {
      mapper[ProductItemOptionKeys.optionId]!: optionId,
      mapper[ProductItemOptionKeys.modificationId]!: modificationId,
      if (clientId != null) mapper[ProductItemOptionKeys.clientId]!: clientId,
      mapper[ProductItemOptionKeys.name]!: name,
      mapper[ProductItemOptionKeys.price]!: price,
      mapper[ProductItemOptionKeys.pricing]!: pricing.code,
      mapper[ProductItemOptionKeys.unit]!: unit,
      if (rank != 1) mapper[ProductItemOptionKeys.rank]!: rank,
      if (blocked) mapper[ProductItemOptionKeys.blocked]!: blocked,
      if (meta != null) mapper[ProductItemOptionKeys.meta]!: meta,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductItemOption && optionId == other.optionId;

  @override
  int get hashCode => optionId.hashCode;
}


// eof

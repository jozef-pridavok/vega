import "../../core_dart.dart";

enum ProductItemModificationKeys {
  modificationId,
  itemId,
  clientId,
  name,
  type,
  mandatory,
  max,
  rank,
  blocked,
  meta,
}

class ProductItemModification {
  String modificationId;
  String itemId;
  String? clientId;
  String name;
  ProductItemModificationType type;
  bool mandatory;
  int? max;
  int rank;
  bool blocked;
  JsonObject? meta;

  ProductItemModification({
    required this.modificationId,
    required this.itemId,
    this.clientId,
    required this.name,
    required this.type,
    this.mandatory = false,
    this.max,
    this.rank = 1,
    this.blocked = false,
    this.meta,
  });

  static ProductItemModification? _emptyInstance;

  factory ProductItemModification.empty() {
    return _emptyInstance ??= ProductItemModification(
      modificationId: "",
      itemId: "",
      name: "",
      type: ProductItemModificationType.singleSelection,
    );
  }

  static const camel = {
    ProductItemModificationKeys.modificationId: "modificationId",
    ProductItemModificationKeys.itemId: "itemId",
    ProductItemModificationKeys.clientId: "clientId",
    ProductItemModificationKeys.name: "name",
    ProductItemModificationKeys.type: "type",
    ProductItemModificationKeys.mandatory: "mandatory",
    ProductItemModificationKeys.max: "max",
    ProductItemModificationKeys.rank: "rank",
    ProductItemModificationKeys.blocked: "blocked",
    ProductItemModificationKeys.meta: "meta",
  };

  static const snake = {
    ProductItemModificationKeys.modificationId: "modification_id",
    ProductItemModificationKeys.itemId: "item_id",
    ProductItemModificationKeys.clientId: "client_id",
    ProductItemModificationKeys.name: "name",
    ProductItemModificationKeys.type: "type",
    ProductItemModificationKeys.mandatory: "mandatory",
    ProductItemModificationKeys.max: "max",
    ProductItemModificationKeys.rank: "rank",
    ProductItemModificationKeys.blocked: "blocked",
    ProductItemModificationKeys.meta: "meta",
  };

  static ProductItemModification fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProductItemModification.camel : ProductItemModification.snake;
    return ProductItemModification(
      modificationId: map[mapper[ProductItemModificationKeys.modificationId]] as String,
      itemId: map[mapper[ProductItemModificationKeys.itemId]] as String,
      clientId: map[mapper[ProductItemModificationKeys.clientId]] as String?,
      name: map[mapper[ProductItemModificationKeys.name]] as String,
      type: ProductItemModificationTypeCode.fromCode(map[mapper[ProductItemModificationKeys.type]] as int?),
      mandatory: (map[mapper[ProductItemModificationKeys.mandatory]] ?? false) as bool,
      max: map[mapper[ProductItemModificationKeys.max]] as int?,
      rank: map[mapper[ProductItemModificationKeys.rank]] as int? ?? 1,
      blocked: (map[mapper[ProductItemModificationKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ProductItemModificationKeys.meta]] as JsonObject?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProductItemModification.camel : ProductItemModification.snake;
    return {
      mapper[ProductItemModificationKeys.modificationId]!: modificationId,
      mapper[ProductItemModificationKeys.itemId]!: itemId,
      if (clientId != null) mapper[ProductItemModificationKeys.clientId]!: clientId,
      mapper[ProductItemModificationKeys.name]!: name,
      mapper[ProductItemModificationKeys.type]!: type.code,
      mapper[ProductItemModificationKeys.mandatory]!: mandatory,
      if (max != null) mapper[ProductItemModificationKeys.max]!: max,
      if (rank != 1) mapper[ProductItemModificationKeys.rank]!: rank,
      if (blocked) mapper[ProductItemModificationKeys.blocked]!: blocked,
      if (meta != null) mapper[ProductItemModificationKeys.meta]!: meta,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductItemModification && modificationId == other.modificationId;

  @override
  int get hashCode => modificationId.hashCode;
}


// eof

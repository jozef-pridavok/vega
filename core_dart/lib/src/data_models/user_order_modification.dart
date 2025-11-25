import "package:core_dart/core_dart.dart";

enum UserOrderModificationKeys {
  //modificationName,
  modificationId,
  name,
  //price,
  //pricing,
  //unit,
  options,
}

class UserOrderModification {
  //String modificationName;
  String modificationId;
  String name;
  //int price;
  //int pricing;
  //String unit;
  List<ProductItemOption>? options;

  UserOrderModification({
    //required this.modificationName,
    required this.modificationId,
    required this.name,
    //required this.price,
    //required this.pricing,
    //required this.unit,
    this.options,
  });

  static const camel = {
    //UserOrderModificationKeys.modificationName: "modificationName",
    UserOrderModificationKeys.modificationId: "modificationId",
    UserOrderModificationKeys.name: "name",
    //UserOrderModificationKeys.price: "price",
    //UserOrderModificationKeys.pricing: "pricing",
    //UserOrderModificationKeys.unit: "unit",
    UserOrderModificationKeys.options: "options",
  };

  static const snake = {
    //UserOrderModificationKeys.modificationName: "modification_name",
    UserOrderModificationKeys.modificationId: "modification_id",
    UserOrderModificationKeys.name: "name",
    //UserOrderModificationKeys.price: "price",
    //UserOrderModificationKeys.pricing: "pricing",
    //UserOrderModificationKeys.unit: "unit",
    UserOrderModificationKeys.options: "options",
  };

  // get

  static UserOrderModification fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? UserOrderModification.camel : UserOrderModification.snake;
    return UserOrderModification(
      //modificationName: map[mapper[UserOrderModificationKeys.modificationName]] as String,
      modificationId: map[mapper[UserOrderModificationKeys.modificationId]] as String,
      name: map[mapper[UserOrderModificationKeys.name]] as String,
      //price: map[mapper[UserOrderModificationKeys.price]] as int,
      //pricing: map[mapper[UserOrderModificationKeys.pricing]] as int,
      //unit: map[mapper[UserOrderModificationKeys.unit]] as String,
      options: (map[mapper[UserOrderModificationKeys.options]] as List<dynamic>?)
          ?.map((e) => ProductItemOption.fromMap(e, convention))
          .toList(),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserOrderModification.camel : UserOrderModification.snake;
    return {
      //mapper[UserOrderModificationKeys.modificationName]!: modificationName,
      mapper[UserOrderModificationKeys.modificationId]!: modificationId,
      mapper[UserOrderModificationKeys.name]!: name,
      //mapper[UserOrderModificationKeys.price]!: price,
      //mapper[UserOrderModificationKeys.pricing]!: pricing,
      //mapper[UserOrderModificationKeys.unit]!: unit,
      if (options?.isNotEmpty ?? false)
        mapper[UserOrderModificationKeys.options]!: options!.map((e) => e.toMap(convention)).toList(),
    };
  }

  Price getPrice(ProductItem item, ProductItemModification modification) {
    assert(modificationId == modification.modificationId);

    if (modification.type == ProductItemModificationType.singleSelection) {
      final option = options?.first;
      if (option == null) return Price(0, item.currency);
      if (option.pricing == ProductItemOptionPricing.add) {
        return Price(option.price, item.currency);
      } else {
        final itemPrice = item.price ?? 0;
        return Price(option.price - itemPrice, item.currency);
      }
    }

    if (modification.type == ProductItemModificationType.multipleSelection) {
      final total = options?.fold<int>(0, (previousValue, element) => previousValue + element.price);
      return Price(total ?? 0, item.currency);
    }

    return Price(0, item.currency);
  }
}

// eof

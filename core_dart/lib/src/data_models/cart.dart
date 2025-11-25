import "../enums/convention.dart";
import "product_item.dart";
import "product_item_modification.dart";
import "product_item_option.dart";
import "product_section.dart";

enum CartKeys {
  sections,
  items,
  modifications,
  options,
}

class Cart {
  List<ProductSection> sections;
  List<ProductItem> items;
  List<ProductItemModification> modifications;
  List<ProductItemOption> options;

  static const camel = {
    CartKeys.sections: "sections",
    CartKeys.items: "items",
    CartKeys.modifications: "modifications",
    CartKeys.options: "options",
  };

  static const snake = {
    CartKeys.sections: "sections",
    CartKeys.items: "items",
    CartKeys.modifications: "modifications",
    CartKeys.options: "options",
  };

  Cart({
    required this.sections,
    required this.items,
    required this.modifications,
    required this.options,
  });

  static Cart fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Cart.camel : Cart.snake;
    return Cart(
      sections: (map[mapper[CartKeys.sections]!] as List)
          .map((e) => ProductSection.fromMap(e as Map<String, dynamic>, convention))
          .toList(),
      items: (map[mapper[CartKeys.items]!] as List)
          .map((e) => ProductItem.fromMap(e as Map<String, dynamic>, convention))
          .toList(),
      modifications: (map[mapper[CartKeys.modifications]!] as List)
          .map((e) => ProductItemModification.fromMap(e as Map<String, dynamic>, convention))
          .toList(),
      options: (map[mapper[CartKeys.options]!] as List)
          .map((e) => ProductItemOption.fromMap(e as Map<String, dynamic>, convention))
          .toList(),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Cart.camel : Cart.snake;
    return {
      mapper[CartKeys.sections]!: sections.map((e) => e.toMap(convention)).toList(),
      mapper[CartKeys.items]!: items.map((e) => e.toMap(convention)).toList(),
      mapper[CartKeys.modifications]!: modifications.map((e) => e.toMap(convention)).toList(),
      mapper[CartKeys.options]!: options.map((e) => e.toMap(convention)).toList(),
    };
  }
}

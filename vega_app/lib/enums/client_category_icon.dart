import "package:core_flutter/core_dart.dart";

extension ClientCategoryIcon on ClientCategory {
  static final _icons = {
    ClientCategory.supermarket: "category_supermarket",
    ClientCategory.auto: "category_car",
    ClientCategory.restaurant: "category_restaurant",
    ClientCategory.bar: "category_bar",
    ClientCategory.sport: "category_sport",
    ClientCategory.food: "category_food",
    ClientCategory.health: "category_health",
    ClientCategory.fashion: "category_fashion",
    ClientCategory.education: "category_education",
    ClientCategory.culture: "category_culture",
    ClientCategory.kids: "category_kids",
    ClientCategory.pets: "category_pets",
    ClientCategory.garden: "category_garden",
    ClientCategory.traveling: "category_traveling",
    ClientCategory.electro: "category_electro",
    ClientCategory.hobby: "category_hobby",
    ClientCategory.other: "category_other",
  };

  String get icon => _icons[this]!;
}

// eof

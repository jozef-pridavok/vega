import "package:core_flutter/core_dart.dart";

extension ClientCategoryPeriod on ClientCategory {
  static final _periodMap = {
    ClientCategory.supermarket: 30,
    ClientCategory.auto: 30,
    ClientCategory.restaurant: 30,
    ClientCategory.bar: 30,
    ClientCategory.sport: 30,
    ClientCategory.food: 30,
    ClientCategory.health: 60,
    ClientCategory.fashion: 90,
    ClientCategory.education: 30,
    ClientCategory.culture: 30,
    ClientCategory.kids: 30,
    ClientCategory.pets: 30,
    ClientCategory.garden: 30,
    ClientCategory.traveling: 30,
    ClientCategory.electro: 30,
    ClientCategory.hobby: 30,
    ClientCategory.other: 30,
  };

  int get period => _periodMap[this]!;
}

// eof

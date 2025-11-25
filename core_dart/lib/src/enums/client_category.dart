import "package:collection/collection.dart";

enum ClientCategory {
  supermarket,
  auto,
  restaurant,
  bar,
  sport,
  food,
  health,
  fashion,
  education,
  culture,
  kids,
  pets,
  garden,
  traveling,
  electro,
  hobby,
  other
}

extension ClientCategoryCode on ClientCategory {
  static final _codeMap = {
    ClientCategory.supermarket: 1,
    ClientCategory.auto: 2,
    ClientCategory.restaurant: 3,
    ClientCategory.bar: 4,
    ClientCategory.sport: 5,
    ClientCategory.food: 6,
    ClientCategory.health: 7,
    ClientCategory.fashion: 8,
    ClientCategory.education: 9,
    ClientCategory.culture: 10,
    ClientCategory.kids: 11,
    ClientCategory.pets: 12,
    ClientCategory.garden: 13,
    ClientCategory.traveling: 14,
    ClientCategory.electro: 15,
    ClientCategory.hobby: 16,
    ClientCategory.other: 17,
  };

  int get code => _codeMap[this]!;

  static ClientCategory fromCode(int? code, {ClientCategory def = ClientCategory.supermarket}) =>
      ClientCategory.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ClientCategory? fromCodeOrNull(int? code) => ClientCategory.values.firstWhereOrNull((r) => r.code == code);

  static List<ClientCategory> fromCodes(List<int>? codes) {
    if (codes == null) return [];
    // null if client_category is not found => remove unknown client_categories
    return codes.map((code) => fromCodeOrNull(code)).nonNulls.toList();
  }

  static List<ClientCategory> fromCodesOrNull(List<int>? codes) {
    if (codes == null) return [];
    return fromCodes(codes);
  }

  static List<int> toCodes(List<ClientCategory>? categories) {
    if (categories == null) return [];
    return categories.map((category) => category.code).toList();
  }

  static List<int>? toCodesOrNull(List<ClientCategory>? categories) {
    if (categories == null) return null;
    return toCodes(categories);
  }
}

// eof

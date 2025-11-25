import "package:core_dart/core_dart.dart";
import "package:core_flutter/core_flutter.dart";

extension ClientCategoryTranslation on ClientCategory {
  // TODO: localize core_client_category_supermarket "Supermarket", "Supermarket", "Supermercado"
  // TODO: localize core_client_category_auto "Auto", "Auto", "Auto"
  // TODO: localize core_client_category_restaurant "Reštaurácia", "Restaurant", "Restaurante"
  // TODO: localize core_client_category_bar "Bar", "Bar", "Bar"
  // TODO: localize core_client_category_sport "Šport", "Sport", "Deporte"
  // TODO: localize core_client_category_food "Jedlo", "Food", "Comida"
  // TODO: localize core_client_category_health "Zdravie", "Health", "Salud"
  // TODO: localize core_client_category_fashion "Móda", "Fashion", "Moda"
  // TODO: localize core_client_category_education "Vzdelanie", "Education", "Educación"
  // TODO: localize core_client_category_culture "Kultúra", "Culture", "Cultura"
  // TODO: localize core_client_category_kids "Deti", "Kids", "Niños"
  // TODO: localize core_client_category_pets "Domáce zvieratá", "Pets", "Mascotas"
  // TODO: localize core_client_category_garden "Záhrada", "Garden", "Jardín"
  // TODO: localize core_client_category_traveling "Cestovanie", "Traveling", "Viajando"
  // TODO: localize core_client_category_electro "Elektro", "Electro", "Electro"
  // TODO: localize core_client_category_hobby "Hobby", "Hobby", "Hobby"
  // TODO: localize core_client_category_other "Iné", "Other", "Otro"

  String get localizedName => "core_client_category_$name".tr();
}

// eof

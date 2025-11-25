import "package:core_dart/core_enums.dart";
import "package:core_flutter/core_flutter.dart";

extension LocationTypeTranslation on LocationType {
  // TODO: localize core_location_type_main_branch "Hlavná pobočka", "Main branch", "Sucursal principal"
  // TODO: localize core_location_type_regional_branch "Regionálna pobočka", "Regional branch", "Sucursal regional"
  // TODO: localize core_location_type_local_branch "Miestna pobočka", "Local branch", "Sucursal local"
  // TODO: localize core_location_type_distribution_center "Distribučné centrum", "Distribution center", "Centro de distribución"
  // TODO: localize core_location_type_store "Predajňa", "Store", "Tienda"
  // TODO: localize core_location_type_service_center "Servisné centrum", "Service center", "Centro de servicio"
  // TODO: localize core_location_type_call_center "Call centrum", "Call center", "Centro de llamadas"
  // TODO: localize core_location_type_online_store "Online obchod", "Online store", "Tienda en línea"
  // TODO: localize core_location_type_franchise_branch "Pobočka na franšízovom základe", "Franchise branch", "Sucursal de franquicia"
  // TODO: localize core_location_type_rnd_center "Výskumné a vývojové centrum", "Research and development center", "Centro de investigación y desarrollo"
  // TODO: localize core_location_type_expansion_branch "Expansijná pobočka", "Expansion branch", "Sucursal de expansión"
  // TODO: localize core_location_type_marketing_branch "Marketingová pobočka", "Marketing branch", "Sucursal de marketing"
  // TODO: localize core_location_type_logistics_center "Logistické centrum", "Logistics center", "Centro de logística"
  // TODO: localize core_location_type_training_center "Školiace centrum", "Training center", "Centro de capacitación"
  // TODO: localize core_location_type_laboratory "Laboratórium", "Laboratory", "Laboratorio"
  // TODO: localize core_location_type_issuance_point "Výdajné miesto", "Issuance point", "Punto de emisión"
  // TODO: localize core_location_type_wholesale_warehouse "Veľkoobchodný sklad", "Wholesale warehouse", "Almacén mayorista"

  String get localizedName => "core_location_type_$translationKey".tr();
}

// eof

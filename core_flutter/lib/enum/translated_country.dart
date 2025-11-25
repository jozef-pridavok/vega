import "package:core_dart/core_enums.dart";

import "../extensions/string.dart";

extension CountryTranslation on Country {
  /*
    "country_sk": "Slovensko",
    "country_cz": "Česko",
    "country_pl": "Poľsko",
    "country_de": "Nemecko",
    "country_at": "Rakúsko",
    "country_ru": "Rusko",
    "country_us": "Spojené štáty",
    "country_gb": "Veľká Británia",
    "country_it": "Taliansko",
    "country_fr": "Francúzsko",
    "country_ch": "Švajčiarsko",
    "country_ca": "Kanada",
    "country_au": "Austrália",
    "country_br": "Brazília",
    "country_es": "Špenielsko",
    "country_ar": "Argentína",
    "country_cl": "Čile",
    "country_mx": "Mexiko",
    "country_pt": "Portugalsko",
    "country_dk": "Dánsko",
    "country_hu": "Maďarsko",
    "country_ro": "Rumunsko",
    "country_ua": "Ukrajina",
    "country_nl": "Holandsko",
    "country_py": "Paraguaj",
    "country_fi": "Fínsko",
    "country_no": "Nórsko",
    "country_se": "Švédsko",
    "country_be": "Belgicko",
    "country_co": "Kolumbia",
    "country_jp": "Japonsko",
    "country_pe": "Peru",
    "country_si": "Slovinsko",
    "country_bg": "Bulharsko",
    "country_gr": "Grécko",
    "country_kr": "Kórea",
    "country_hr": "Chorvátsko",
    "country_uy": "Urugvaj",
  */

  // TODO: localize core_country_sk "Slovensko", "Slovakia", "Eslovaquia"
  // TODO: localize core_country_cz "Česko", "Czechia", "Chequia"
  // TODO: localize core_country_de "Nemecko", "Germany", "Alemania"
  // TODO: localize core_country_at "Rakúsko", "Austria", "Austria"
  // TODO: localize core_country_fr "Francúzsko", "France", "Francia"
  // TODO: localize core_country_es "Španielsko", "Spain", "España"
  // TODO: localize core_country_pt "Portugalsko", "Portugal", "Portugal"
  // TODO: localize core_country_uy "Uruguaj", "Uruguay", "Uruguay"
  // TODO: localize core_country_py "Paraguaj", "Paraguay", "Paraguay"
  // TODO: localize core_country_ar "Argentína", "Argentina", "Argentina"
  // TODO: localize core_country_br "Brazília", "Brazil", "Brasil"
  // TODO: localize core_country_cl "Čile", "Chile", "Chile"
  // TODO: localize core_country_co "Kolumbia", "Colombia", "Colombia"
  // TODO: localize core_country_ec "Ekvádor", "Ecuador", "Ecuador"
  // TODO: localize core_country_gt "Guatemala", "Guatemala", "Guatemala"
  // TODO: localize core_country_cr "Kostarika", "Costa Rica", "Costa Rica"

  String get localizedName => "core_country_$code".tr();
}

// eof

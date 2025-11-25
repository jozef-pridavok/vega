import "package:collection/collection.dart";

import "../data_models/geo_point.dart";

/*
select distinct unnest(countries) 
from cards
order by 1

-- 

select distinct "region"
from "Crawler"
order by 1

"ar"
"at"
"au"
"br"
"ca"
"ch"
"cz"
"de"
"es"
"fr"
"gb"
"it"
"mx"
"nl"
"pl"
"ru"
"sk"
"us"

*/

enum Country {
  slovakia,
  czechia,
  uruguay,
  paraguay,
  /*
  poland,
  austria,
  unitedStates,
  france,
  germany,
  russia,
  italia,
  greatBritain,
  switzerland,
  argentina,
  canada,
  denmark,
  hungary,
  romania,
  ukraine,
  spain,
  netherlands,
  australia,
  chile,
  finland,
  norway,
  sweden,
  belgium,
  colombia,
  japan,
  peru,
  slovenia,
  bulgaria,
  greece,
  korea,
  brazil,
  croatia,
  mexico,
  portugal,
  */
}

extension CountryCode on Country {
  static final _countryCodes = {
    Country.slovakia: "sk",
    Country.czechia: "cz",
    Country.uruguay: "uy",
    Country.paraguay: "py",
    /*
    Country.poland: "pl",
    Country.austria: "at",
    Country.unitedStates: "us",
    Country.france: "fr",
    Country.germany: "de",
    Country.russia: "ru",
    Country.italia: "it",
    Country.greatBritain: "gb",
    Country.switzerland: "ch",
    Country.argentina: "ar",
    Country.canada: "ca",
    Country.denmark: "dk",
    Country.hungary: "hu",
    Country.romania: "ro",
    Country.ukraine: "ua",
    Country.spain: "es",
    Country.netherlands: "nl",
    Country.australia: "au",
    Country.chile: "cl",
    Country.finland: "fi",
    Country.norway: "no",
    Country.sweden: "se",
    Country.belgium: "be",
    Country.colombia: "co",
    Country.japan: "jp",
    Country.peru: "pe",
    Country.slovenia: "si",
    Country.bulgaria: "bg",
    Country.greece: "gr",
    Country.korea: "kr",
    Country.brazil: "br",
    Country.croatia: "hr",
    Country.mexico: "mx",
    Country.portugal: "pt",
    */
  };

  String get code => _countryCodes[this]!;

  static Country fromCode(String? code, {Country def = Country.slovakia}) {
    code = code?.toLowerCase();
    return Country.values.firstWhere((r) => r.code.toLowerCase() == code, orElse: () => def);
  }

  static Country? fromCodeOrNull(String? code, {Country def = Country.slovakia}) {
    code = code?.toLowerCase();
    return Country.values.firstWhereOrNull((r) => r.code.toLowerCase() == code);
  }

  static List<Country> fromCodes(List<String>? codes) {
    if (codes == null) return [];
    codes = codes.map((code) => code.toLowerCase()).toList();
    // null if country is not found => remove unknown countries
    return codes.map((code) => fromCodeOrNull(code)).nonNulls.toList();
  }

  static List<Country>? fromCodesOrNull(List<String>? codes) {
    if (codes == null) return null;
    return fromCodes(codes);
  }

  static List<String> toCodes(List<Country>? countries) {
    if (countries == null) return [];
    return countries.map((role) => role.code).toList();
  }

  static List<String>? toCodesOrNull(List<Country>? countries) {
    if (countries == null) return null;
    return toCodes(countries);
  }
}

extension CountryCodes on List<Country> {
  List<String> toCodes() => CountryCode.toCodes(this);
}

/*
extension CountryFlag on Country {
  static final _countryFlags = {
    Country.slovakia: "🇸🇰",
    Country.czechia: "🇨🇿",
    Country.uruguay: "🇺🇾",
    Country.paraguay: "🇵🇾",
    Country.poland: "🇵🇱",
    Country.austria: "🇦🇹",
    Country.unitedStates: "🇺🇸",
    Country.france: "🇫🇷",
    Country.germany: "🇩🇪",
    Country.russia: "🇷🇺",
    Country.italia: "🇮🇹",
    Country.greatBritain: "🇬🇧",
    Country.switzerland: "🇨🇭",
    Country.argentina: "🇦🇷",
    Country.canada: "🇨🇦",
    Country.denmark: "🇩🇰",
    Country.hungary: "🇭🇺",
    Country.romania: "🇷🇴",
    Country.ukraine: "🇺🇦",
    Country.spain: "🇪🇸",
    Country.netherlands: "🇳🇱",
    Country.australia: "🇦🇺",
    Country.chile: "🇨🇱",
    Country.finland: "🇫🇮",
    Country.norway: "🇳🇴",
    Country.sweden: "🇸🇪",
    Country.belgium: "🇧🇪",
    Country.colombia: "🇨🇴",
    Country.japan: "🇯🇵",
    Country.peru: "🇵🇪",
    Country.slovenia: "🇸🇮",
    Country.bulgaria: "🇧🇬",
    Country.greece: "🇬🇷",
    Country.korea: "🇰🇷",
    Country.brazil: "🇧🇷",
    Country.croatia: "🇭🇷",
    Country.mexico: "🇲🇽",
    Country.portugal: "🇵🇹",
  };

  String get flag => _countryFlags[this]!;
}
*/

extension CountryGeoPoint on Country {
  GeoPoint get countryCentroid => centroidForCountry(code);
}

// eof

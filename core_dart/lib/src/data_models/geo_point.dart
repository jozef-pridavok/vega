/*
Latitude and longitude are a pair of numbers (coordinates) used 
to describe a position on the plane of a geographic coordinate system. 
The numbers are in decimal degrees format and range 
from -90 to 90 for latitude and -180 to 180 for longitude.
*/

/*

Dec. places   Dec. degrees  Distance (meters)
0   1.0       110,574.3     111 km
1   0.1       11,057.43     11 km
2   0.01       1,105.74     1 km
3   0.001        110.57    
4   0.0001        11.06   
5   0.00001        1.11    
6   0.000001       0.11     11 cm
7   0.0000001      0.01     1 cm
8   0.00000001    0.001     1 mm

*/

import "dart:math" as math;

import "package:core_dart/core_dart.dart";

class GeoPoint {
  final double latitude, longitude;

  const GeoPoint({this.latitude = 0.0, this.longitude = 0.0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      ((other is GeoPoint) &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude);

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  get isValid => latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;

  static const _zero = GeoPoint(latitude: 0, longitude: 0);
  static const _invalid = GeoPoint(latitude: 999, longitude: 999);

  static GeoPoint? tryParse(dynamic longitude, dynamic latitude) {
    final lon = tryParseDouble(longitude);
    final lat = tryParseDouble(latitude);
    if (lon == null || lat == null) return null;
    return GeoPoint(latitude: lat, longitude: lon);
  }

  factory GeoPoint.zero() => _zero;
  factory GeoPoint.invalid() => _invalid;

  @override
  String toString() => "GeoPoint(lat: $latitude, lon: $longitude)";

  // ---

  /*
  (double, double) roundCoordinates(double lat, double lon, {double radius = 1000}) {
    // Približná konverzia stupňov na metre
    final double metersPerDegree = 111000; // Približne 111 km na stupeň
    // Prepočet na metre
    double x = lon * metersPerDegree * cos(lat * pi / 180);
    double y = lat * metersPerDegree;
    // Zaokrúhlenie
    double xRounded = (x / radius).round() * radius;
    double yRounded = (y / radius).round() * radius;
    // Spätný prepočet na stupne
    double lonRounded = xRounded / (metersPerDegree * cos(lat * pi / 180));
    double latRounded = yRounded / metersPerDegree;
    return (latRounded, lonRounded);
  }
  */

  GeoPoint get coarse => GeoPoint.getCoarse(this);

  // https://stackoverflow.com/questions/8018788/is-there-any-easy-way-to-make-gps-coordinates-coarse/8114147#8114147
  // https://chat.openai.com/g/g-2DQzU5UZl-code-copilot/c/85dc89de-c9b9-404c-ad48-3acd59b5d2da

  static GeoPoint getCoarse(GeoPoint location, {double granularityInMeters = 3 * 1000 /*meters*/}) {
    if (location.latitude == 0 && location.longitude == 0) {
      // Special marker, don't modify.
      return GeoPoint._zero;
    }

    var granularityLat = 0.0;
    var granularityLon = 0.0;

    // Calculate granularityLat
    var angleUpInRadians = 0.0;
    var newLocationUp = _getLocationOffsetBy(location, granularityInMeters, angleUpInRadians);
    granularityLat = (location.latitude - newLocationUp.latitude).abs();

    // Calculate granularityLon
    var angleRightInRadians = math.pi / 2; // 90 degrees in radians
    var newLocationRight = _getLocationOffsetBy(location, granularityInMeters, angleRightInRadians);
    granularityLon = (location.longitude - newLocationRight.longitude).abs();

    var courseLatitude = location.latitude;
    var courseLongitude = location.longitude;

    if (!(granularityLon == 0 || granularityLat == 0)) {
      courseLatitude = (courseLatitude / granularityLat).floor() * granularityLat;
      courseLongitude = (courseLongitude / granularityLon).floor() * granularityLon;
    }

    return GeoPoint(latitude: courseLatitude, longitude: courseLongitude);
  }

  static GeoPoint _getLocationOffsetBy(GeoPoint location, double offsetInMeters, double angleInRadians) {
    var lat1 = _deg2rad(location.latitude);
    var lon1 = _deg2rad(location.longitude);
    var distanceKm = offsetInMeters / 1000;
    var earthRadiusKm = 6371;

    var lat2 = math.asin(math.sin(lat1) * math.cos(distanceKm / earthRadiusKm) +
        math.cos(lat1) * math.sin(distanceKm / earthRadiusKm) * math.cos(angleInRadians));

    var lon2 = lon1 +
        math.atan2(math.sin(angleInRadians) * math.sin(distanceKm / earthRadiusKm) * math.cos(lat1),
            math.cos(distanceKm / earthRadiusKm) - math.sin(lat1) * math.sin(lat2));

    return GeoPoint(latitude: _rad2deg(lat2), longitude: _rad2deg(lon2));
  }

  static double _rad2deg(double radians) {
    return radians * (180.0 / math.pi);
  }

  static double _deg2rad(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}

GeoPoint centroidForCountry(String code, {GeoPoint def = const GeoPoint()}) {
  final result = _countryCentroids.firstWhere(
    (x) => x["code"] == code,
    orElse: () => <String, Object>{},
  );
  if (result["centroid"] is GeoPoint) return result["centroid"] as GeoPoint;
  return def;
}

// https://developers.google.com/public-data/docs/canonical/countries_csv

const _countryCentroids = [
  {
    "code": "ad",
    "centroid": GeoPoint(latitude: 42.546245, longitude: 1.601554),
  },
  {
    "code": "ae",
    "centroid": GeoPoint(latitude: 23.424076, longitude: 53.847818),
  },
  {
    "code": "af",
    "centroid": GeoPoint(latitude: 33.93911, longitude: 67.709953),
  },
  {
    "code": "ag",
    "centroid": GeoPoint(latitude: 17.060816, longitude: -61.796428),
  },
  {
    "code": "ai",
    "centroid": GeoPoint(latitude: 18.220554, longitude: -63.068615),
  },
  {
    "code": "al",
    "centroid": GeoPoint(latitude: 41.153332, longitude: 20.168331),
  },
  {
    "code": "am",
    "centroid": GeoPoint(latitude: 40.069099, longitude: 45.038189),
  },
  {
    "code": "an",
    "centroid": GeoPoint(latitude: 12.226079, longitude: -69.060087),
  },
  {
    "code": "ao",
    "centroid": GeoPoint(latitude: -11.202692, longitude: 17.873887),
  },
  {
    "code": "aq",
    "centroid": GeoPoint(latitude: -75.250973, longitude: -0.071389),
  },
  {
    "code": "ar",
    "centroid": GeoPoint(latitude: -38.416097, longitude: -63.616672),
  },
  {
    "code": "as",
    "centroid": GeoPoint(latitude: -14.270972, longitude: -170.132217),
  },
  {
    "code": "at",
    "centroid": GeoPoint(latitude: 47.516231, longitude: 14.550072),
  },
  {
    "code": "au",
    "centroid": GeoPoint(latitude: -25.274398, longitude: 133.775136),
  },
  {
    "code": "aw",
    "centroid": GeoPoint(latitude: 12.52111, longitude: -69.968338),
  },
  {
    "code": "az",
    "centroid": GeoPoint(latitude: 40.143105, longitude: 47.576927),
  },
  {
    "code": "ba",
    "centroid": GeoPoint(latitude: 43.915886, longitude: 17.679076),
  },
  {
    "code": "bb",
    "centroid": GeoPoint(latitude: 13.193887, longitude: -59.543198),
  },
  {
    "code": "bd",
    "centroid": GeoPoint(latitude: 23.684994, longitude: 90.356331),
  },
  {
    "code": "be",
    "centroid": GeoPoint(latitude: 50.503887, longitude: 4.469936),
  },
  {
    "code": "bf",
    "centroid": GeoPoint(latitude: 12.238333, longitude: -1.561593),
  },
  {
    "code": "bg",
    "centroid": GeoPoint(latitude: 42.733883, longitude: 25.48583),
  },
  {
    "code": "bh",
    "centroid": GeoPoint(latitude: 25.930414, longitude: 50.637772),
  },
  {
    "code": "bi",
    "centroid": GeoPoint(latitude: -3.373056, longitude: 29.918886),
  },
  {
    "code": "bj",
    "centroid": GeoPoint(latitude: 9.30769, longitude: 2.315834),
  },
  {
    "code": "bm",
    "centroid": GeoPoint(latitude: 32.321384, longitude: -64.75737),
  },
  {
    "code": "bn",
    "centroid": GeoPoint(latitude: 4.535277, longitude: 114.727669),
  },
  {
    "code": "bo",
    "centroid": GeoPoint(latitude: -16.290154, longitude: -63.588653),
  },
  {
    "code": "br",
    "centroid": GeoPoint(latitude: -14.235004, longitude: -51.92528),
  },
  {
    "code": "bs",
    "centroid": GeoPoint(latitude: 25.03428, longitude: -77.39628),
  },
  {
    "code": "bt",
    "centroid": GeoPoint(latitude: 27.514162, longitude: 90.433601),
  },
  {
    "code": "bv",
    "centroid": GeoPoint(latitude: -54.423199, longitude: 3.413194),
  },
  {
    "code": "bw",
    "centroid": GeoPoint(latitude: -22.328474, longitude: 24.684866),
  },
  {
    "code": "by",
    "centroid": GeoPoint(latitude: 53.709807, longitude: 27.953389),
  },
  {
    "code": "bz",
    "centroid": GeoPoint(latitude: 17.189877, longitude: -88.49765),
  },
  {
    "code": "ca",
    "centroid": GeoPoint(latitude: 56.130366, longitude: -106.346771),
  },
  {
    "code": "cc",
    "centroid": GeoPoint(latitude: -12.164165, longitude: 96.870956),
  },
  {
    "code": "cd",
    "centroid": GeoPoint(latitude: -4.038333, longitude: 21.758664),
  },
  {
    "code": "cf",
    "centroid": GeoPoint(latitude: 6.611111, longitude: 20.939444),
  },
  {
    "code": "cg",
    "centroid": GeoPoint(latitude: -0.228021, longitude: 15.827659),
  },
  {
    "code": "ch",
    "centroid": GeoPoint(latitude: 46.818188, longitude: 8.227512),
  },
  {
    "code": "ci",
    "centroid": GeoPoint(latitude: 7.539989, longitude: -5.54708),
  },
  {
    "code": "ck",
    "centroid": GeoPoint(latitude: -21.236736, longitude: -159.777671),
  },
  {
    "code": "cl",
    "centroid": GeoPoint(latitude: -35.675147, longitude: -71.542969),
  },
  {
    "code": "cm",
    "centroid": GeoPoint(latitude: 7.369722, longitude: 12.354722),
  },
  {
    "code": "cn",
    "centroid": GeoPoint(latitude: 35.86166, longitude: 104.195397),
  },
  {
    "code": "co",
    "centroid": GeoPoint(latitude: 4.570868, longitude: -74.297333),
  },
  {
    "code": "cr",
    "centroid": GeoPoint(latitude: 9.748917, longitude: -83.753428),
  },
  {
    "code": "cu",
    "centroid": GeoPoint(latitude: 21.521757, longitude: -77.781167),
  },
  {
    "code": "cv",
    "centroid": GeoPoint(latitude: 16.002082, longitude: -24.013197),
  },
  {
    "code": "cx",
    "centroid": GeoPoint(latitude: -10.447525, longitude: 105.690449),
  },
  {
    "code": "cy",
    "centroid": GeoPoint(latitude: 35.126413, longitude: 33.429859),
  },
  {
    "code": "cz",
    "centroid": GeoPoint(latitude: 49.817492, longitude: 15.472962),
  },
  {
    "code": "de",
    "centroid": GeoPoint(latitude: 51.165691, longitude: 10.451526),
  },
  {
    "code": "dj",
    "centroid": GeoPoint(latitude: 11.825138, longitude: 42.590275),
  },
  {
    "code": "dk",
    "centroid": GeoPoint(latitude: 56.26392, longitude: 9.501785),
  },
  {
    "code": "dm",
    "centroid": GeoPoint(latitude: 15.414999, longitude: -61.370976),
  },
  {
    "code": "do",
    "centroid": GeoPoint(latitude: 18.735693, longitude: -70.162651),
  },
  {
    "code": "dz",
    "centroid": GeoPoint(latitude: 28.033886, longitude: 1.659626),
  },
  {
    "code": "ec",
    "centroid": GeoPoint(latitude: -1.831239, longitude: -78.183406),
  },
  {
    "code": "ee",
    "centroid": GeoPoint(latitude: 58.595272, longitude: 25.013607),
  },
  {
    "code": "eg",
    "centroid": GeoPoint(latitude: 26.820553, longitude: 30.802498),
  },
  {
    "code": "eh",
    "centroid": GeoPoint(latitude: 24.215527, longitude: -12.885834),
  },
  {
    "code": "er",
    "centroid": GeoPoint(latitude: 15.179384, longitude: 39.782334),
  },
  {
    "code": "es",
    "centroid": GeoPoint(latitude: 40.463667, longitude: -3.74922),
  },
  {
    "code": "et",
    "centroid": GeoPoint(latitude: 9.145, longitude: 40.489673),
  },
  {
    "code": "fi",
    "centroid": GeoPoint(latitude: 61.92411, longitude: 25.748151),
  },
  {
    "code": "fj",
    "centroid": GeoPoint(latitude: -16.578193, longitude: 179.414413),
  },
  {
    "code": "fk",
    "centroid": GeoPoint(latitude: -51.796253, longitude: -59.523613),
  },
  {
    "code": "fm",
    "centroid": GeoPoint(latitude: 7.425554, longitude: 150.550812),
  },
  {
    "code": "fo",
    "centroid": GeoPoint(latitude: 61.892635, longitude: -6.911806),
  },
  {
    "code": "fr",
    "centroid": GeoPoint(latitude: 46.227638, longitude: 2.213749),
  },
  {
    "code": "ga",
    "centroid": GeoPoint(latitude: -0.803689, longitude: 11.609444),
  },
  {
    "code": "gb",
    "centroid": GeoPoint(latitude: 55.378051, longitude: -3.435973),
  },
  {
    "code": "gd",
    "centroid": GeoPoint(latitude: 12.262776, longitude: -61.604171),
  },
  {
    "code": "ge",
    "centroid": GeoPoint(latitude: 42.315407, longitude: 43.356892),
  },
  {
    "code": "gf",
    "centroid": GeoPoint(latitude: 3.933889, longitude: -53.125782),
  },
  {
    "code": "gg",
    "centroid": GeoPoint(latitude: 49.465691, longitude: -2.585278),
  },
  {
    "code": "gh",
    "centroid": GeoPoint(latitude: 7.946527, longitude: -1.023194),
  },
  {
    "code": "gi",
    "centroid": GeoPoint(latitude: 36.137741, longitude: -5.345374),
  },
  {
    "code": "gl",
    "centroid": GeoPoint(latitude: 71.706936, longitude: -42.604303),
  },
  {
    "code": "gm",
    "centroid": GeoPoint(latitude: 13.443182, longitude: -15.310139),
  },
  {
    "code": "gn",
    "centroid": GeoPoint(latitude: 9.945587, longitude: -9.696645),
  },
  {
    "code": "gp",
    "centroid": GeoPoint(latitude: 16.995971, longitude: -62.067641),
  },
  {
    "code": "gq",
    "centroid": GeoPoint(latitude: 1.650801, longitude: 10.267895),
  },
  {
    "code": "gr",
    "centroid": GeoPoint(latitude: 39.074208, longitude: 21.824312),
  },
  {
    "code": "gs",
    "centroid": GeoPoint(latitude: -54.429579, longitude: -36.587909),
  },
  {
    "code": "gt",
    "centroid": GeoPoint(latitude: 15.783471, longitude: -90.230759),
  },
  {
    "code": "gu",
    "centroid": GeoPoint(latitude: 13.444304, longitude: 144.793731),
  },
  {
    "code": "gw",
    "centroid": GeoPoint(latitude: 11.803749, longitude: -15.180413),
  },
  {
    "code": "gy",
    "centroid": GeoPoint(latitude: 4.860416, longitude: -58.93018),
  },
  {
    "code": "gz",
    "centroid": GeoPoint(latitude: 31.354676, longitude: 34.308825),
  },
  {
    "code": "hk",
    "centroid": GeoPoint(latitude: 22.396428, longitude: 114.109497),
  },
  {
    "code": "hm",
    "centroid": GeoPoint(latitude: -53.08181, longitude: 73.504158),
  },
  {
    "code": "hn",
    "centroid": GeoPoint(latitude: 15.199999, longitude: -86.241905),
  },
  {
    "code": "hr",
    "centroid": GeoPoint(latitude: 45.1, longitude: 44242),
  },
  {
    "code": "ht",
    "centroid": GeoPoint(latitude: 18.971187, longitude: -72.285215),
  },
  {
    "code": "hu",
    "centroid": GeoPoint(latitude: 47.162494, longitude: 19.503304),
  },
  {
    "code": "id",
    "centroid": GeoPoint(latitude: -0.789275, longitude: 113.921327),
  },
  {
    "code": "ie",
    "centroid": GeoPoint(latitude: 53.41291, longitude: -8.24389),
  },
  {
    "code": "il",
    "centroid": GeoPoint(latitude: 31.046051, longitude: 34.851612),
  },
  {
    "code": "im",
    "centroid": GeoPoint(latitude: 54.236107, longitude: -4.548056),
  },
  {
    "code": "in",
    "centroid": GeoPoint(latitude: 20.593684, longitude: 78.96288),
  },
  {
    "code": "io",
    "centroid": GeoPoint(latitude: -6.343194, longitude: 71.876519),
  },
  {
    "code": "iq",
    "centroid": GeoPoint(latitude: 33.223191, longitude: 43.679291),
  },
  {
    "code": "ir",
    "centroid": GeoPoint(latitude: 32.427908, longitude: 53.688046),
  },
  {
    "code": "is",
    "centroid": GeoPoint(latitude: 64.963051, longitude: -19.020835),
  },
  {
    "code": "it",
    "centroid": GeoPoint(latitude: 41.87194, longitude: 12.56738),
  },
  {
    "code": "je",
    "centroid": GeoPoint(latitude: 49.214439, longitude: -2.13125),
  },
  {
    "code": "jm",
    "centroid": GeoPoint(latitude: 18.109581, longitude: -77.297508),
  },
  {
    "code": "jo",
    "centroid": GeoPoint(latitude: 30.585164, longitude: 36.238414),
  },
  {
    "code": "jp",
    "centroid": GeoPoint(latitude: 36.204824, longitude: 138.252924),
  },
  {
    "code": "ke",
    "centroid": GeoPoint(latitude: -0.023559, longitude: 37.906193),
  },
  {
    "code": "kg",
    "centroid": GeoPoint(latitude: 41.20438, longitude: 74.766098),
  },
  {
    "code": "kh",
    "centroid": GeoPoint(latitude: 12.565679, longitude: 104.990963),
  },
  {
    "code": "ki",
    "centroid": GeoPoint(latitude: -3.370417, longitude: -168.734039),
  },
  {
    "code": "km",
    "centroid": GeoPoint(latitude: -11.875001, longitude: 43.872219),
  },
  {
    "code": "kn",
    "centroid": GeoPoint(latitude: 17.357822, longitude: -62.782998),
  },
  {
    "code": "kp",
    "centroid": GeoPoint(latitude: 40.339852, longitude: 127.510093),
  },
  {
    "code": "kr",
    "centroid": GeoPoint(latitude: 35.907757, longitude: 127.766922),
  },
  {
    "code": "kw",
    "centroid": GeoPoint(latitude: 29.31166, longitude: 47.481766),
  },
  {
    "code": "ky",
    "centroid": GeoPoint(latitude: 19.513469, longitude: -80.566956),
  },
  {
    "code": "kz",
    "centroid": GeoPoint(latitude: 48.019573, longitude: 66.923684),
  },
  {
    "code": "la",
    "centroid": GeoPoint(latitude: 19.85627, longitude: 102.495496),
  },
  {
    "code": "lb",
    "centroid": GeoPoint(latitude: 33.854721, longitude: 35.862285),
  },
  {
    "code": "lc",
    "centroid": GeoPoint(latitude: 13.909444, longitude: -60.978893),
  },
  {
    "code": "li",
    "centroid": GeoPoint(latitude: 47.166, longitude: 9.555373),
  },
  {
    "code": "lk",
    "centroid": GeoPoint(latitude: 7.873054, longitude: 80.771797),
  },
  {
    "code": "lr",
    "centroid": GeoPoint(latitude: 6.428055, longitude: -9.429499),
  },
  {
    "code": "ls",
    "centroid": GeoPoint(latitude: -29.609988, longitude: 28.233608),
  },
  {
    "code": "lt",
    "centroid": GeoPoint(latitude: 55.169438, longitude: 23.881275),
  },
  {
    "code": "lu",
    "centroid": GeoPoint(latitude: 49.815273, longitude: 6.129583),
  },
  {
    "code": "lv",
    "centroid": GeoPoint(latitude: 56.879635, longitude: 24.603189),
  },
  {
    "code": "ly",
    "centroid": GeoPoint(latitude: 26.3351, longitude: 17.228331),
  },
  {
    "code": "ma",
    "centroid": GeoPoint(latitude: 31.791702, longitude: -7.09262),
  },
  {
    "code": "mc",
    "centroid": GeoPoint(latitude: 43.750298, longitude: 7.412841),
  },
  {
    "code": "md",
    "centroid": GeoPoint(latitude: 47.411631, longitude: 28.369885),
  },
  {
    "code": "me",
    "centroid": GeoPoint(latitude: 42.708678, longitude: 19.37439),
  },
  {
    "code": "mg",
    "centroid": GeoPoint(latitude: -18.766947, longitude: 46.869107),
  },
  {
    "code": "mh",
    "centroid": GeoPoint(latitude: 7.131474, longitude: 171.184478),
  },
  {
    "code": "mk",
    "centroid": GeoPoint(latitude: 41.608635, longitude: 21.745275),
  },
  {
    "code": "ml",
    "centroid": GeoPoint(latitude: 17.570692, longitude: -3.996166),
  },
  {
    "code": "mm",
    "centroid": GeoPoint(latitude: 21.913965, longitude: 95.956223),
  },
  {
    "code": "mn",
    "centroid": GeoPoint(latitude: 46.862496, longitude: 103.846656),
  },
  {
    "code": "mo",
    "centroid": GeoPoint(latitude: 22.198745, longitude: 113.543873),
  },
  {
    "code": "mp",
    "centroid": GeoPoint(latitude: 17.33083, longitude: 145.38469),
  },
  {
    "code": "mq",
    "centroid": GeoPoint(latitude: 14.641528, longitude: -61.024174),
  },
  {
    "code": "mr",
    "centroid": GeoPoint(latitude: 21.00789, longitude: -10.940835),
  },
  {
    "code": "ms",
    "centroid": GeoPoint(latitude: 16.742498, longitude: -62.187366),
  },
  {
    "code": "mt",
    "centroid": GeoPoint(latitude: 35.937496, longitude: 14.375416),
  },
  {
    "code": "mu",
    "centroid": GeoPoint(latitude: -20.348404, longitude: 57.552152),
  },
  {
    "code": "mv",
    "centroid": GeoPoint(latitude: 3.202778, longitude: 73.22068),
  },
  {
    "code": "mw",
    "centroid": GeoPoint(latitude: -13.254308, longitude: 34.301525),
  },
  {
    "code": "mx",
    "centroid": GeoPoint(latitude: 23.634501, longitude: -102.552784),
  },
  {
    "code": "my",
    "centroid": GeoPoint(latitude: 4.210484, longitude: 101.975766),
  },
  {
    "code": "mz",
    "centroid": GeoPoint(latitude: -18.665695, longitude: 35.529562),
  },
  {
    "code": "na",
    "centroid": GeoPoint(latitude: -22.95764, longitude: 18.49041),
  },
  {
    "code": "nc",
    "centroid": GeoPoint(latitude: -20.904305, longitude: 165.618042),
  },
  {
    "code": "ne",
    "centroid": GeoPoint(latitude: 17.607789, longitude: 8.081666),
  },
  {
    "code": "nf",
    "centroid": GeoPoint(latitude: -29.040835, longitude: 167.954712),
  },
  {
    "code": "ng",
    "centroid": GeoPoint(latitude: 9.081999, longitude: 8.675277),
  },
  {
    "code": "ni",
    "centroid": GeoPoint(latitude: 12.865416, longitude: -85.207229),
  },
  {
    "code": "nl",
    "centroid": GeoPoint(latitude: 52.132633, longitude: 5.291266),
  },
  {
    "code": "no",
    "centroid": GeoPoint(latitude: 60.472024, longitude: 8.468946),
  },
  {
    "code": "np",
    "centroid": GeoPoint(latitude: 28.394857, longitude: 84.124008),
  },
  {
    "code": "nr",
    "centroid": GeoPoint(latitude: -0.522778, longitude: 166.931503),
  },
  {
    "code": "nu",
    "centroid": GeoPoint(latitude: -19.054445, longitude: -169.867233),
  },
  {
    "code": "nz",
    "centroid": GeoPoint(latitude: -40.900557, longitude: 174.885971),
  },
  {
    "code": "om",
    "centroid": GeoPoint(latitude: 21.512583, longitude: 55.923255),
  },
  {
    "code": "pa",
    "centroid": GeoPoint(latitude: 8.537981, longitude: -80.782127),
  },
  {
    "code": "pe",
    "centroid": GeoPoint(latitude: -9.189967, longitude: -75.015152),
  },
  {
    "code": "pf",
    "centroid": GeoPoint(latitude: -17.679742, longitude: -149.406843),
  },
  {
    "code": "pg",
    "centroid": GeoPoint(latitude: -6.314993, longitude: 143.95555),
  },
  {
    "code": "ph",
    "centroid": GeoPoint(latitude: 12.879721, longitude: 121.774017),
  },
  {
    "code": "pk",
    "centroid": GeoPoint(latitude: 30.375321, longitude: 69.345116),
  },
  {
    "code": "pl",
    "centroid": GeoPoint(latitude: 51.919438, longitude: 19.145136),
  },
  {
    "code": "pm",
    "centroid": GeoPoint(latitude: 46.941936, longitude: -56.27111),
  },
  {
    "code": "pn",
    "centroid": GeoPoint(latitude: -24.703615, longitude: -127.439308),
  },
  {
    "code": "pr",
    "centroid": GeoPoint(latitude: 18.220833, longitude: -66.590149),
  },
  {
    "code": "ps",
    "centroid": GeoPoint(latitude: 31.952162, longitude: 35.233154),
  },
  {
    "code": "pt",
    "centroid": GeoPoint(latitude: 39.399872, longitude: -8.224454),
  },
  {
    "code": "pw",
    "centroid": GeoPoint(latitude: 7.51498, longitude: 134.58252),
  },
  {
    "code": "py",
    "centroid": GeoPoint(latitude: -23.442503, longitude: -58.443832),
  },
  {
    "code": "qa",
    "centroid": GeoPoint(latitude: 25.354826, longitude: 51.183884),
  },
  {
    "code": "re",
    "centroid": GeoPoint(latitude: -21.115141, longitude: 55.536384),
  },
  {
    "code": "ro",
    "centroid": GeoPoint(latitude: 45.943161, longitude: 24.96676),
  },
  {
    "code": "rs",
    "centroid": GeoPoint(latitude: 44.016521, longitude: 21.005859),
  },
  {
    "code": "ru",
    "centroid": GeoPoint(latitude: 61.52401, longitude: 105.318756),
  },
  {
    "code": "rw",
    "centroid": GeoPoint(latitude: -1.940278, longitude: 29.873888),
  },
  {
    "code": "sa",
    "centroid": GeoPoint(latitude: 23.885942, longitude: 45.079162),
  },
  {
    "code": "sb",
    "centroid": GeoPoint(latitude: -9.64571, longitude: 160.156194),
  },
  {
    "code": "sc",
    "centroid": GeoPoint(latitude: -4.679574, longitude: 55.491977),
  },
  {
    "code": "sd",
    "centroid": GeoPoint(latitude: 12.862807, longitude: 30.217636),
  },
  {
    "code": "se",
    "centroid": GeoPoint(latitude: 60.128161, longitude: 18.643501),
  },
  {
    "code": "sg",
    "centroid": GeoPoint(latitude: 1.352083, longitude: 103.819836),
  },
  {
    "code": "sh",
    "centroid": GeoPoint(latitude: -24.143474, longitude: -10.030696),
  },
  {
    "code": "si",
    "centroid": GeoPoint(latitude: 46.151241, longitude: 14.995463),
  },
  {
    "code": "sj",
    "centroid": GeoPoint(latitude: 77.553604, longitude: 23.670272),
  },
  {
    "code": "sk",
    "centroid": GeoPoint(latitude: 48.669026, longitude: 19.699024),
  },
  {
    "code": "sl",
    "centroid": GeoPoint(latitude: 8.460555, longitude: -11.779889),
  },
  {
    "code": "sm",
    "centroid": GeoPoint(latitude: 43.94236, longitude: 12.457777),
  },
  {
    "code": "sn",
    "centroid": GeoPoint(latitude: 14.497401, longitude: -14.452362),
  },
  {
    "code": "so",
    "centroid": GeoPoint(latitude: 5.152149, longitude: 46.199616),
  },
  {
    "code": "sr",
    "centroid": GeoPoint(latitude: 3.919305, longitude: -56.027783),
  },
  {
    "code": "st",
    "centroid": GeoPoint(latitude: 0.18636, longitude: 6.613081),
  },
  {
    "code": "sv",
    "centroid": GeoPoint(latitude: 13.794185, longitude: -88.89653),
  },
  {
    "code": "sy",
    "centroid": GeoPoint(latitude: 34.802075, longitude: 38.996815),
  },
  {
    "code": "sz",
    "centroid": GeoPoint(latitude: -26.522503, longitude: 31.465866),
  },
  {
    "code": "tc",
    "centroid": GeoPoint(latitude: 21.694025, longitude: -71.797928),
  },
  {
    "code": "td",
    "centroid": GeoPoint(latitude: 15.454166, longitude: 18.732207),
  },
  {
    "code": "tf",
    "centroid": GeoPoint(latitude: -49.280366, longitude: 69.348557),
  },
  {
    "code": "tg",
    "centroid": GeoPoint(latitude: 8.619543, longitude: 0.824782),
  },
  {
    "code": "th",
    "centroid": GeoPoint(latitude: 15.870032, longitude: 100.992541),
  },
  {
    "code": "tj",
    "centroid": GeoPoint(latitude: 38.861034, longitude: 71.276093),
  },
  {
    "code": "tk",
    "centroid": GeoPoint(latitude: -8.967363, longitude: -171.855881),
  },
  {
    "code": "tl",
    "centroid": GeoPoint(latitude: -8.874217, longitude: 125.727539),
  },
  {
    "code": "tm",
    "centroid": GeoPoint(latitude: 38.969719, longitude: 59.556278),
  },
  {
    "code": "tn",
    "centroid": GeoPoint(latitude: 33.886917, longitude: 9.537499),
  },
  {
    "code": "to",
    "centroid": GeoPoint(latitude: -21.178986, longitude: -175.198242),
  },
  {
    "code": "tr",
    "centroid": GeoPoint(latitude: 38.963745, longitude: 35.243322),
  },
  {
    "code": "tt",
    "centroid": GeoPoint(latitude: 10.691803, longitude: -61.222503),
  },
  {
    "code": "tv",
    "centroid": GeoPoint(latitude: -7.109535, longitude: 177.64933),
  },
  {
    "code": "tw",
    "centroid": GeoPoint(latitude: 23.69781, longitude: 120.960515),
  },
  {
    "code": "tz",
    "centroid": GeoPoint(latitude: -6.369028, longitude: 34.888822),
  },
  {
    "code": "ua",
    "centroid": GeoPoint(latitude: 48.379433, longitude: 31.16558),
  },
  {
    "code": "ug",
    "centroid": GeoPoint(latitude: 1.373333, longitude: 32.290275),
  },
  {
    "code": "us",
    "centroid": GeoPoint(latitude: 37.09024, longitude: -95.712891),
  },
  {
    "code": "uy",
    "centroid": GeoPoint(latitude: -32.522779, longitude: -55.765835),
  },
  {
    "code": "uz",
    "centroid": GeoPoint(latitude: 41.377491, longitude: 64.585262),
  },
  {
    "code": "va",
    "centroid": GeoPoint(latitude: 41.902916, longitude: 12.453389),
  },
  {
    "code": "vc",
    "centroid": GeoPoint(latitude: 12.984305, longitude: -61.287228),
  },
  {
    "code": "ve",
    "centroid": GeoPoint(latitude: 6.42375, longitude: -66.58973),
  },
  {
    "code": "vg",
    "centroid": GeoPoint(latitude: 18.420695, longitude: -64.639968),
  },
  {
    "code": "vi",
    "centroid": GeoPoint(latitude: 18.335765, longitude: -64.896335),
  },
  {
    "code": "vn",
    "centroid": GeoPoint(latitude: 14.058324, longitude: 108.277199),
  },
  {
    "code": "vu",
    "centroid": GeoPoint(latitude: -15.376706, longitude: 166.959158),
  },
  {
    "code": "wf",
    "centroid": GeoPoint(latitude: -13.768752, longitude: -177.156097),
  },
  {
    "code": "ws",
    "centroid": GeoPoint(latitude: -13.759029, longitude: -172.104629),
  },
  {
    "code": "xk",
    "centroid": GeoPoint(latitude: 42.602636, longitude: 20.902977),
  },
  {
    "code": "ye",
    "centroid": GeoPoint(latitude: 15.552727, longitude: 48.516388),
  },
  {
    "code": "yt",
    "centroid": GeoPoint(latitude: -12.8275, longitude: 45.166244),
  },
  {
    "code": "za",
    "centroid": GeoPoint(latitude: -30.559482, longitude: 22.937506),
  },
  {
    "code": "zm",
    "centroid": GeoPoint(latitude: -13.133897, longitude: 27.849332),
  },
  {
    "code": "zw",
    "centroid": GeoPoint(latitude: -19.015438, longitude: 29.154857),
  },
];

// eof


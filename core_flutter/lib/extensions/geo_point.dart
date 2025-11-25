import "package:latlong2/latlong.dart";

import "../core_dart.dart";

extension GeoPoint2LatLng on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLng2GeoPoint on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude: latitude, longitude: longitude);
}

// eof

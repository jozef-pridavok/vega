import "package:core_flutter/core_dart.dart";

extension LocationCopy on Location {
  Location copy() {
    return Location(
      locationId: locationId,
      clientId: clientId,
      type: type,
      rank: rank,
      name: name,
      description: description,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      zip: zip,
      state: state,
      country: country,
      phone: phone,
      email: email,
      website: website,
      latitude: latitude,
      longitude: longitude,
      // TODO: konzulácia s Maťom
      openingHours: openingHours, //OpeningHours(openingHours: Map.from((openingHours).openingHours)),
      openingHoursExceptions:
          openingHoursExceptions, //OpeningHoursExceptions(exceptions: Map.from((openingHoursExceptions).exceptions)),
    );
  }

  Location copyWith({
    String? name,
    String? description,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? zip,
    String? state,
    String? country,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    LocationType? type,
    int? rank,
    OpeningHours? openingHours,
    OpeningHoursExceptions? openingHoursExceptions,
  }) {
    return Location(
      locationId: locationId,
      clientId: clientId,
      type: type ?? this.type,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      description: description ?? this.description,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      state: state ?? this.state,
      country: this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ??
          this.openingHours, // OpeningHours(openingHours: Map.from((openingHours ?? this.openingHours).openingHours)),
      openingHoursExceptions: openingHoursExceptions ?? this.openingHoursExceptions,
      //OpeningHoursExceptions(exceptions: Map.from((openingHoursExceptions ?? this.openingHoursExceptions).exceptions)),
    );
  }
}

// eof

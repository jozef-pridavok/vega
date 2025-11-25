import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class LocationAdapter extends TypeAdapter<Location> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.location;

  @override
  Location read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != LocationAdapter.version) throw Exception("Invalid version: $version");

    final locationId = reader.readString();
    final clientId = reader.readString();
    final type = LocationTypeCode.fromCode(reader.readInt());
    final rank = reader.readInt();
    final name = reader.readString();
    final addressLine1 = reader.readNullableString();
    final addressLine2 = reader.readNullableString();
    final city = reader.readNullableString();
    final zip = reader.readNullableString();
    final state = reader.readNullableString();
    final country = CountryCode.fromCodeOrNull(reader.readNullableString());
    final phone = reader.readNullableString();
    final email = reader.readNullableString();
    final website = reader.readNullableString();
    final openingHours = reader.readNullableMap();
    final openingHoursExceptions = reader.readNullableMap();
    final latitude = reader.readDouble();
    final longitude = reader.readDouble();

    return Location(
      locationId: locationId,
      clientId: clientId,
      type: type,
      rank: rank,
      name: name,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      zip: zip,
      state: state,
      country: country,
      phone: phone,
      email: email,
      website: website,
      openingHours: OpeningHours.fromMapOrNull(openingHours?.asStringMap),
      openingHoursExceptions: OpeningHoursExceptions.fromMapOrNull(openingHoursExceptions?.asStringMap),
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    writer.writeInt(LocationAdapter.version);
    writer.writeString(obj.locationId);
    writer.writeString(obj.clientId);
    writer.writeInt(obj.type.code);
    writer.writeInt(obj.rank);
    writer.writeString(obj.name);
    writer.writeNullableString(obj.addressLine1);
    writer.writeNullableString(obj.addressLine2);
    writer.writeNullableString(obj.city);
    writer.writeNullableString(obj.zip);
    writer.writeNullableString(obj.state);
    writer.writeNullableString(obj.country?.code);
    writer.writeNullableString(obj.phone);
    writer.writeNullableString(obj.email);
    writer.writeNullableString(obj.website);
    writer.writeNullableMap(obj.openingHours?.toMap());
    writer.writeNullableMap(obj.openingHoursExceptions?.toMap());
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}

// eof

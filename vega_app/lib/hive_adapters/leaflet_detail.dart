import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class LeafletDetailAdapter extends TypeAdapter<LeafletDetail> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.leafletDetail;

  @override
  LeafletDetail read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != LeafletDetailAdapter.version) throw Exception("Invalid version: $version");
    final leafletId = reader.readString();
    final clientId = reader.readString();
    final locationId = reader.readNullableString();
    final locationName = reader.readNullableString();
    final locationAddressLine1 = reader.readNullableString();
    final locationAddressLine2 = reader.readNullableString();
    final locationCity = reader.readNullableString();
    final country = reader.readString();
    final name = reader.readString();
    final rank = reader.readInt();
    final validFrom = reader.readInt();
    final validTo = reader.readInt();
    final thumbnail = reader.readNullableString();
    final thumbnailBh = reader.readNullableString();
    final leaflet = reader.readNullableString();
    final pages = reader.readNullableStringList();
    final pagesBh = reader.readNullableStringList();

    return LeafletDetail(
      leafletId: leafletId,
      clientId: clientId,
      locationId: locationId,
      locationName: locationName,
      locationAddressLine1: locationAddressLine1,
      locationAddressLine2: locationAddressLine2,
      locationCity: locationCity,
      country: CountryCode.fromCode(country),
      name: name,
      rank: rank,
      validFrom: IntDate.fromInt(validFrom),
      validTo: IntDate.fromInt(validTo),
      thumbnail: thumbnail,
      thumbnailBh: thumbnailBh,
      leaflet: leaflet,
      pages: pages,
      pagesBh: pagesBh,
    );
  }

  @override
  void write(BinaryWriter writer, LeafletDetail obj) {
    writer.writeInt(LeafletDetailAdapter.version);
    writer.writeString(obj.leafletId);
    writer.writeString(obj.clientId);
    writer.writeNullableString(obj.locationId);
    writer.writeNullableString(obj.locationName);
    writer.writeNullableString(obj.locationAddressLine1);
    writer.writeNullableString(obj.locationAddressLine2);
    writer.writeNullableString(obj.locationCity);
    writer.writeString(obj.country.code);
    writer.writeString(obj.name);
    writer.writeInt(obj.rank);
    writer.writeInt(obj.validFrom.value);
    writer.writeInt(obj.validTo.value);
    writer.writeNullableString(obj.thumbnail);
    writer.writeNullableString(obj.thumbnailBh);
    writer.writeNullableString(obj.leaflet);
    writer.writeNullableStringList(obj.pages);
    writer.writeNullableStringList(obj.pagesBh);
  }
}

// eof

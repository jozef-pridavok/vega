import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class LeafletOverviewAdapter extends TypeAdapter<LeafletOverview> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.leafletOverview;

  @override
  LeafletOverview read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != LeafletOverviewAdapter.version) throw Exception("Invalid version: $version");
    final clientId = reader.readString();
    final clientName = reader.readString();
    final clientLogo = reader.readNullableString();
    final clientLogoBh = reader.readNullableString();
    final country = CountryCode.fromCode(reader.readString());
    final logo = reader.readNullableString();
    final logoBh = reader.readNullableString();
    final color = Color.fromHexOrNull(reader.readNullableString());
    final leaflets = reader.readInt();

    return LeafletOverview(
      clientId: clientId,
      clientName: clientName,
      clientLogo: clientLogo,
      clientLogoBh: clientLogoBh,
      country: country,
      thumbnail: logo,
      thumbnailBh: logoBh,
      color: color,
      leaflets: leaflets,
    );
  }

  @override
  void write(BinaryWriter writer, LeafletOverview obj) {
    writer.writeInt(LeafletOverviewAdapter.version);
    writer.writeString(obj.clientId);
    writer.writeString(obj.clientName);
    writer.writeNullableString(obj.clientLogo);
    writer.writeNullableString(obj.clientLogoBh);
    writer.writeString(obj.country.code);
    writer.writeNullableString(obj.thumbnail);
    writer.writeNullableString(obj.thumbnailBh);
    writer.writeNullableString(obj.color?.toHex());
    writer.writeInt(obj.leaflets);
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class ProgramAdapter extends TypeAdapter<Program> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.program;

  @override
  Program read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != ProgramAdapter.version) throw Exception("Invalid version: $version");
    final programId = reader.readString();
    final clientId = reader.readString();
    final cardId = reader.readString();
    final locationId = reader.readNullableString();
    final type = ProgramType.values[reader.readInt()];
    final name = reader.readString();
    final description = reader.readNullableString();
    final digits = reader.readInt();
    final image = reader.readNullableString();
    final imageBh = reader.readNullableString();
    final countries = reader.readNullableStringList()?.map((e) => CountryCode.fromCode(e)).toList();
    final rank = reader.readInt();
    final validFrom = IntDate.fromInt(reader.readInt());
    final validTo = IntDate.parseInt(reader.readNullableInt());
    final rewards = reader.readJsonArrayOfObjects();

    return Program(
      programId: programId,
      clientId: clientId,
      cardId: cardId,
      locationId: locationId,
      type: type,
      name: name,
      description: description,
      digits: digits,
      image: image,
      imageBh: imageBh,
      countries: countries,
      rank: rank,
      validFrom: validFrom,
      validTo: validTo,
      rewards: rewards.map((e) => Reward.fromMap(e, Convention.camel)).toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Program obj) {
    writer.writeInt(ProgramAdapter.version);
    writer.writeString(obj.programId);
    writer.writeString(obj.clientId);
    writer.writeString(obj.cardId);
    writer.writeNullableString(obj.locationId);
    writer.writeInt(obj.type.index);
    writer.writeString(obj.name);
    writer.writeNullableString(obj.description);
    writer.writeInt(obj.digits);
    writer.writeNullableString(obj.image);
    writer.writeNullableString(obj.imageBh);
    writer.writeNullableStringList(obj.countries?.map((e) => e.code).toList());
    writer.writeInt(obj.rank);
    writer.writeInt(obj.validFrom.value);
    writer.writeNullableInt(obj.validTo?.value);
    writer.writeJsonArrayOfObjects((obj.rewards ?? []).map((e) => e.toMap(Convention.camel)).toList());
  }
}

// eof

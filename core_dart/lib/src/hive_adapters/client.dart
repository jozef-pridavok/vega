import "package:hive/hive.dart";

import "../../core_dart.dart";
import "../../core_hive.dart";

class ClientAdapter extends TypeAdapter<Client> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.client;

  @override
  Client read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != ClientAdapter.version) throw Exception("Invalid version: $version");
    final clientId = reader.readString();
    final name = reader.readString();
    final description = reader.readNullableString();
    final logo = reader.readNullableString();
    final logoBh = reader.readNullableString();
    final color = Color(reader.readInt());
    final blocked = reader.readBool();
    final countries = reader.readNullableStringList()?.map((e) => CountryCode.fromCode(e)).toList();
    final categories = reader.readNullableIntList()?.map((e) => ClientCategoryCode.fromCode(e)).toList();
    final settings = reader.readNullableMap();
    final meta = reader.readNullableMap();

    return Client(
      clientId: clientId,
      name: name,
      description: description,
      logo: logo,
      logoBh: logoBh,
      color: color,
      blocked: blocked,
      countries: countries,
      categories: categories,
      settings: settings,
      meta: meta,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer.writeInt(ClientAdapter.version);
    writer.writeString(obj.clientId);
    writer.writeString(obj.name);
    writer.writeNullableString(obj.description);
    writer.writeNullableString(obj.logo);
    writer.writeNullableString(obj.logoBh);
    writer.writeInt(obj.color.value);
    writer.writeBool(obj.blocked);
    writer.writeNullableStringList(obj.countries?.map((e) => e.code).toList());
    writer.writeNullableIntList(obj.categories?.map((e) => e.code).toList());
    writer.writeNullableMap(obj.settings ?? {});
    writer.writeNullableMap(obj.meta ?? {});
  }
}

// eof

import "package:hive/hive.dart";

import "../../core_extensions.dart";
import "../../core_repositories.dart";
import "../lang.dart";
import "client.dart";
import "date_time.dart";
import "user.dart";

class HiveTypes {
  static const int dateTime = 1;

  static const int user = 16;
  static const int userCard = 30;
  //static const int userCardDetail = 31;
  static const int client = 40;
  static const int location = 45;
  static const int card = 50;
  static const int program = 60;
  static const int leaflet = 70;
  static const int leafletDetail = 71;
  static const int leafletOverview = 72;
  static const int coupon = 80;
}

extension BinaryReaderExtensions on BinaryReader {
  List<JsonObject> readJsonArrayOfObjects() {
    final list = readList();
    return list.map((e) => (e as Map<dynamic, dynamic>).asStringMap).toList();
  }

  List<JsonObject>? readNullableJsonArrayOfObjects() {
    final hasValue = readByte() == 1;
    if (!hasValue) return null;
    final list = readList();
    return list.map((e) => (e as Map<dynamic, dynamic>).asStringMap).toList();
  }

  String? readNullableString() {
    final hasValue = readByte() == 1;
    return hasValue ? readString() : null;
  }

  int? readNullableInt() {
    final hasValue = readByte() == 1;
    return hasValue ? readInt() : null;
  }

  double? readNullableDouble() {
    final hasValue = readByte() == 1;
    return hasValue ? readDouble() : null;
  }

  DateTime? readNullableDateTime() {
    final hasValue = readByte() == 1;
    return hasValue ? DateTime.tryParse(readString()) : null;
  }

  JsonObject? readNullableMap() {
    final hasValue = readByte() == 1;
    return hasValue ? readMap().asStringMap : null;
  }

  List<String>? readNullableStringList() {
    final hasValue = readByte() == 1;
    return hasValue ? readStringList().cast() : null;
  }

  List<int>? readNullableIntList() {
    final hasValue = readByte() == 1;
    return hasValue ? readIntList().cast() : null;
  }
}

extension BinaryWriterExtensions on BinaryWriter {
  void writeJsonArrayOfObjects(List<JsonObject> value) {
    writeList(value);
  }

  void writeNullableString(String? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeString(value);
  }

  void writeNullableInt(int? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeInt(value);
  }

  void writeNullableDouble(double? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeDouble(value);
  }

  void writeNullableDateTime(DateTime? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeString(value.toUtc().toIso8601String());
  }

  void writeDateTime(DateTime value) {
    writeByte(1);
    writeString(value.toUtc().toIso8601String());
  }

  void writeNullableMap(JsonObject? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeMap(value);
  }

  void writeNullableStringList(List<String>? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeStringList(value);
  }

  void writeNullableIntList(List<int>? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeIntList(value);
  }

  void writeNullableJsonArrayOfObjects(List<JsonObject>? value) {
    writeByte(value != null ? 1 : 0);
    if (value == null) return;
    writeJsonArrayOfObjects(value);
  }
}

Future<void> initializeHive({bool registerAdapters = true}) async {
  if (registerAdapters) {
    Hive.registerAdapter(DateTimeAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ClientAdapter());
  }

  await HiveDeviceRepository.init();
  await HiveClientRepository.init();
}

Future<void> resetHive() async {
  await HiveDeviceRepository.reset();
  await HiveClientRepository.reset();
}

// eof

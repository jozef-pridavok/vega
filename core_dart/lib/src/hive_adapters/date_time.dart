import "package:hive/hive.dart";

import "hive.dart";

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final typeId = HiveTypes.dateTime;

  @override
  DateTime read(BinaryReader reader) {
    var micros = reader.readInt();
    var isUtc = reader.readBool();
    return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: isUtc);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.microsecondsSinceEpoch);
    writer.writeBool(obj.isUtc);
  }
}

/*
Hive.initFlutter();
Hive.registerAdapter(DateTimeAdapter(), override: true, internal: true);
*/

// eof

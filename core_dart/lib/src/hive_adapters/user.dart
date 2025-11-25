import "package:core_dart/src/data_models/folder.dart";
import "package:hive/hive.dart";

import "../../core_enums.dart";
import "../data_models/user.dart";
import "hive.dart";

class UserAdapter extends TypeAdapter<User> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.user;

  @override
  User read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != UserAdapter.version) throw Exception("Invalid version: $version");
    final userId = reader.readString();
    final userType = UserTypeCode.fromCode(reader.readInt());
    final clientId = reader.readNullableString();
    final roles = UserRoleCode.fromCodes(reader.readIntList());
    final login = reader.readNullableString();
    final email = reader.readNullableString();
    final nick = reader.readNullableString();
    final gender = GenderCode.fromCodeOrNull(reader.readNullableInt());
    final yob = reader.readNullableInt();
    final language = reader.readNullableString();
    final country = reader.readNullableString();
    final theme = ThemeCode.fromCode(reader.readInt());
    final emailVerified = reader.readBool();
    final blocked = reader.readBool();
    final folders = Map<String, dynamic>.from(reader.readMap());
    final meta = reader.readNullableMap();

    return User(
      userId: userId,
      userType: userType,
      clientId: clientId,
      roles: roles,
      login: login,
      email: email,
      nick: nick,
      gender: gender,
      yob: yob,
      language: language,
      country: country,
      theme: theme,
      emailVerified: emailVerified,
      blocked: blocked,
      folders: Folders.fromMap(folders, Folders.camel),
      meta: meta,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeInt(UserAdapter.version);
    writer.writeString(obj.userId);
    writer.writeInt(obj.userType.code);
    writer.writeNullableString(obj.clientId);
    writer.writeIntList(UserRoleCode.toCodes(obj.roles));
    writer.writeNullableString(obj.login);
    writer.writeNullableString(obj.email);
    writer.writeNullableString(obj.nick);
    writer.writeNullableInt(obj.gender?.code);
    writer.writeNullableInt(obj.yob);
    writer.writeNullableString(obj.language);
    writer.writeNullableString(obj.country);
    writer.writeInt(obj.theme.code);
    writer.writeBool(obj.emailVerified);
    writer.writeBool(obj.blocked);
    writer.writeMap(obj.folders.toMap(Folders.camel));
    writer.writeNullableMap(obj.meta);
  }
}

// eof

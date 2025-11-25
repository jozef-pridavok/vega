// TODO: remove me
/*
import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class UserCardDetailAdapter extends TypeAdapter<UserCardDetail> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.userCardDetail;

  @override
  UserCardDetail read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != UserCardDetailAdapter.version) throw Exception("Invalid version: $version");
    final userCardId = reader.readString();
    final userId = reader.readString();
    final cardId = reader.readNullableString();
    final clientId = reader.readNullableString();
    final codeType = reader.readInt();
    final number = reader.readNullableString();
    final name = reader.readNullableString();
    final notes = reader.readNullableString();
    final logo = reader.readNullableString();
    final logoBh = reader.readNullableString();
    final color = reader.readNullableString();
    final front = reader.readNullableString();
    final frontBh = reader.readNullableString();
    final back = reader.readNullableString();
    final backBh = reader.readNullableString();
    final meta = reader.readNullableMap();
    final eligibleReservationsCount = reader.readInt();
    final reservationsCount = reader.readInt();
    final offersCount = reader.readInt();
    final ordersCount = reader.readInt();
    final receiptsCount = reader.readInt();
    final leafletsCount = reader.readInt();
    final userCoupons = reader.readJsonArrayOfObjects();
    final programs = reader.readJsonArrayOfObjects();

    return UserCardDetail(
      userCardId: userCardId,
      userId: userId,
      cardId: cardId,
      clientId: clientId,
      codeType: CodeTypeCode.fromCode(codeType),
      number: number,
      name: name,
      notes: notes,
      logo: logo,
      logoBh: logoBh,
      color: Color.fromHexOrNull(color),
      front: front,
      frontBh: frontBh,
      back: back,
      backBh: backBh,
      meta: meta,
      eligibleReservationsCount: eligibleReservationsCount,
      reservationsCount: reservationsCount,
      offersCount: offersCount,
      ordersCount: ordersCount,
      receiptsCount: receiptsCount,
      leafletsCount: leafletsCount,
      userCoupons: userCoupons.map((e) => UserCouponOnUserCard.fromMap(e, Convention.camel)).toList(),
      programs: programs.map((e) => ProgramOnUserCard.fromMap(e, Convention.camel)).toList(),
    );
  }

  @override
  void write(BinaryWriter writer, UserCardDetail obj) {
    writer.writeInt(UserCardDetailAdapter.version);
    writer.writeString(obj.userCardId);
    writer.writeString(obj.userId);
    writer.writeNullableString(obj.cardId);
    writer.writeNullableString(obj.clientId);
    writer.writeInt(obj.codeType.code);
    writer.writeNullableString(obj.number);
    writer.writeNullableString(obj.name);
    writer.writeNullableString(obj.notes);
    writer.writeNullableString(obj.logo);
    writer.writeNullableString(obj.logoBh);
    writer.writeNullableString(obj.color?.toHex());
    writer.writeNullableString(obj.front);
    writer.writeNullableString(obj.frontBh);
    writer.writeNullableString(obj.back);
    writer.writeNullableString(obj.backBh);
    writer.writeNullableMap(obj.meta);
    writer.writeInt(obj.eligibleReservationsCount);
    writer.writeInt(obj.reservationsCount);
    writer.writeInt(obj.offersCount);
    writer.writeInt(obj.ordersCount);
    writer.writeInt(obj.receiptsCount);
    writer.writeInt(obj.leafletsCount);
    writer.writeJsonArrayOfObjects(obj.userCoupons.map((e) => e.toMap(Convention.camel)).toList());
    writer.writeJsonArrayOfObjects(obj.programs.map((e) => e.toMap(Convention.camel)).toList());
  }
}
*/
// eof

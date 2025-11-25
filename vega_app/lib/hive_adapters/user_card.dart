import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";
import "package:vega_app/hive_adapters/user_card_versions.dart";

class UserCardAdapter extends TypeAdapter<UserCard> {
  static const version = 3;

  @override
  final int typeId = HiveTypes.userCard;

  @override
  UserCard read(BinaryReader reader) {
    final version = reader.readInt();
    if (version == 1) return readV1(reader);
    if (version == 2) return readV2(reader);

    if (version != UserCardAdapter.version) throw Exception("Invalid version: $version");

    final userCardId = reader.readString();
    final userId = reader.readString();
    final cardId = reader.readNullableString();
    final cardName = reader.readNullableString();
    final clientId = reader.readNullableString();
    final clientName = reader.readNullableString();
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
    final eligibleReservationsCount = reader.readNullableInt();
    final reservationsCount = reader.readNullableInt();
    final offersCount = reader.readNullableInt();
    final ordersCount = reader.readNullableInt();
    final receiptsCount = reader.readNullableInt();
    final leafletsCount = reader.readNullableInt();
    final userCoupons = reader.readNullableJsonArrayOfObjects();
    final programs = reader.readNullableJsonArrayOfObjects();
    final lastProductOrder = reader.readNullableMap();

    final userCard = UserCard(
      userCardId: userCardId,
      userId: userId,
      cardId: cardId,
      cardName: cardName,
      clientId: clientId,
      clientName: clientName,
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
      eligibleReservationsCount: eligibleReservationsCount,
      reservationsCount: reservationsCount,
      offersCount: offersCount,
      ordersCount: ordersCount,
      receiptsCount: receiptsCount,
      leafletsCount: leafletsCount,
      userCoupons: userCoupons?.map((e) => UserCouponOnUserCard.fromMap(e, Convention.camel)).toList(),
      programs: programs?.map((e) => ProgramOnUserCard.fromMap(e, Convention.camel)).toList(),
      lastProductOrder: lastProductOrder != null ? UserOrder.fromMap(lastProductOrder, Convention.camel) : null,
    );

    userCard.syncIsRemote = reader.readBool();
    userCard.syncIsModified = reader.readBool();
    userCard.syncIsActive = reader.readBool();

    return userCard;
  }

  @override
  void write(BinaryWriter writer, UserCard obj) {
    writer.writeInt(UserCardAdapter.version);
    writer.writeString(obj.userCardId);
    writer.writeString(obj.userId);
    writer.writeNullableString(obj.cardId);
    writer.writeNullableString(obj.cardName);
    writer.writeNullableString(obj.clientId);
    writer.writeNullableString(obj.clientName);
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
    //writer.writeNullableMap(obj.meta);
    writer.writeNullableInt(obj.eligibleReservationsCount);
    writer.writeNullableInt(obj.reservationsCount);
    writer.writeNullableInt(obj.offersCount);
    writer.writeNullableInt(obj.ordersCount);
    writer.writeNullableInt(obj.receiptsCount);
    writer.writeNullableInt(obj.leafletsCount);
    writer.writeNullableJsonArrayOfObjects(obj.userCoupons?.map((e) => e.toMap(Convention.camel)).toList());
    writer.writeNullableJsonArrayOfObjects(obj.programs?.map((e) => e.toMap(Convention.camel)).toList());
    writer.writeNullableMap(obj.lastProductOrder?.toMap(Convention.camel));

    writer.writeBool(obj.syncIsRemote);
    writer.writeBool(obj.syncIsModified);
    writer.writeBool(obj.syncIsActive);
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "user_card.dart";

extension UserCardAdapterV1 on UserCardAdapter {
  UserCard readV1(BinaryReader reader) {
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

    final userCard = UserCard(
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
      //meta: meta,
    );

    userCard.syncIsRemote = reader.readBool();
    userCard.syncIsModified = reader.readBool();
    userCard.syncIsActive = reader.readBool();

    return userCard;
  }

  UserCard readV2(BinaryReader reader) {
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
    );

    userCard.syncIsRemote = reader.readBool();
    userCard.syncIsModified = reader.readBool();
    userCard.syncIsActive = reader.readBool();

    return userCard;
  }
}

// eof

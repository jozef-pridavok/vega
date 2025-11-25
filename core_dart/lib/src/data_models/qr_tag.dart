import "package:core_dart/core_dart.dart";

enum QrTagKeys {
  qrTagId,
  clientId,
  programId,
  points,
  usedByUserId,
  usedAt,
  usedByUserNick,
}

class QrTag {
  String qrTagId;
  String clientId;
  String programId;
  int points;
  String? usedByUserId;
  DateTime? usedAt;
  //
  String? usedByUserNick;

  QrTag({
    required this.qrTagId,
    required this.clientId,
    required this.programId,
    required this.points,
    this.usedByUserId,
    this.usedAt,
    //
    this.usedByUserNick,
  });

  static const camel = {
    QrTagKeys.qrTagId: "qrTagId",
    QrTagKeys.clientId: "clientId",
    QrTagKeys.programId: "programId",
    QrTagKeys.points: "points",
    QrTagKeys.usedByUserId: "usedByUserId",
    QrTagKeys.usedAt: "usedAt",
    QrTagKeys.usedByUserNick: "usedByUserNick",
  };

  static const snake = {
    QrTagKeys.qrTagId: "qr_tag_id",
    QrTagKeys.clientId: "client_id",
    QrTagKeys.programId: "program_id",
    QrTagKeys.points: "points",
    QrTagKeys.usedByUserId: "used_by_user_id",
    QrTagKeys.usedAt: "used_at",
    QrTagKeys.usedByUserNick: "used_by_user_nick",
  };

  factory QrTag.fromMap(Map<String, dynamic> map, Map<QrTagKeys, String> mapper) => QrTag(
        qrTagId: map[mapper[QrTagKeys.qrTagId]] as String,
        clientId: map[mapper[QrTagKeys.clientId]] as String,
        programId: map[mapper[QrTagKeys.programId]] as String,
        points: map[mapper[QrTagKeys.points]] as int,
        usedByUserId: map[mapper[QrTagKeys.usedByUserId]] as String?,
        usedAt: tryParseDateTime(map[mapper[QrTagKeys.usedAt]]),
        usedByUserNick: map[mapper[QrTagKeys.usedByUserNick]] as String?,
      );

  Map<String, dynamic> toMap(Map<QrTagKeys, String> mapper) => {
        mapper[QrTagKeys.qrTagId]!: qrTagId,
        mapper[QrTagKeys.clientId]!: clientId,
        mapper[QrTagKeys.programId]!: programId,
        mapper[QrTagKeys.points]!: points,
        if (usedByUserId != null) mapper[QrTagKeys.usedByUserId]!: usedByUserId,
        if (usedAt != null) mapper[QrTagKeys.usedAt]!: usedAt!.toIso8601String(),
        if (usedByUserNick != null) mapper[QrTagKeys.usedByUserNick]!: usedByUserNick,
      };
}

// eof

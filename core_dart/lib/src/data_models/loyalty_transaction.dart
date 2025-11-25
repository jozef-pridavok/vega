import "package:core_dart/core_dart.dart";

enum LoyaltyTransactionKeys {
  loyaltyTransactionId,
  clientId,
  locationId,
  cardId,
  programId,
  programName,
  userId,
  userCardId,
  points,
  digits,
  objectType,
  objectId,
  log,
  date,
}

class LoyaltyTransaction {
  final String loyaltyTransactionId;
  final String clientId;
  final String? locationId;
  final String? cardId;
  final String? programId;
  final String? programName;
  final String? userId;
  final String? userCardId;
  final int points;
  final int digits;
  final LoyaltyTransactionObjectType objectType;
  final String objectId;
  final Map<String, dynamic>? log;
  final DateTime date;

  LoyaltyTransaction({
    required this.loyaltyTransactionId,
    required this.clientId,
    this.locationId,
    this.cardId,
    this.programId,
    this.programName,
    this.userId,
    this.userCardId,
    required this.points,
    this.digits = 0,
    required this.objectType,
    required this.objectId,
    this.log,
    required this.date,
  });

  static const camel = {
    LoyaltyTransactionKeys.loyaltyTransactionId: "loyaltyTransactionId",
    LoyaltyTransactionKeys.clientId: "clientId",
    LoyaltyTransactionKeys.locationId: "locationId",
    LoyaltyTransactionKeys.cardId: "cardId",
    LoyaltyTransactionKeys.programId: "programId",
    LoyaltyTransactionKeys.programName: "programName",
    LoyaltyTransactionKeys.userId: "userId",
    LoyaltyTransactionKeys.userCardId: "userCardId",
    LoyaltyTransactionKeys.points: "points",
    LoyaltyTransactionKeys.digits: "digits",
    LoyaltyTransactionKeys.objectType: "objectType",
    LoyaltyTransactionKeys.objectId: "objectId",
    LoyaltyTransactionKeys.log: "log",
    LoyaltyTransactionKeys.date: "date",
  };

  static const snake = {
    LoyaltyTransactionKeys.loyaltyTransactionId: "loyalty_transaction_id",
    LoyaltyTransactionKeys.clientId: "client_id",
    LoyaltyTransactionKeys.locationId: "location_id",
    LoyaltyTransactionKeys.cardId: "card_id",
    LoyaltyTransactionKeys.programId: "program_id",
    LoyaltyTransactionKeys.programName: "program_name",
    LoyaltyTransactionKeys.userId: "user_id",
    LoyaltyTransactionKeys.userCardId: "user_card_id",
    LoyaltyTransactionKeys.points: "points",
    LoyaltyTransactionKeys.digits: "digits",
    LoyaltyTransactionKeys.objectType: "object_type",
    LoyaltyTransactionKeys.objectId: "object_id",
    LoyaltyTransactionKeys.log: "log",
    LoyaltyTransactionKeys.date: "date",
  };

  factory LoyaltyTransaction.fromMap(Map<String, dynamic> map, Map<LoyaltyTransactionKeys, String> mapper) =>
      LoyaltyTransaction(
        loyaltyTransactionId: map[mapper[LoyaltyTransactionKeys.loyaltyTransactionId]] ?? "",
        clientId: map[mapper[LoyaltyTransactionKeys.clientId]] ?? "",
        locationId: map[mapper[LoyaltyTransactionKeys.locationId]],
        cardId: map[mapper[LoyaltyTransactionKeys.cardId]],
        programId: map[mapper[LoyaltyTransactionKeys.programId]],
        programName: map[mapper[LoyaltyTransactionKeys.programName]],
        userId: map[mapper[LoyaltyTransactionKeys.userId]],
        userCardId: map[mapper[LoyaltyTransactionKeys.userCardId]],
        points: tryParseInt(map[mapper[LoyaltyTransactionKeys.points]]) ?? 0,
        digits: tryParseInt(map[mapper[LoyaltyTransactionKeys.digits]]) ?? 0,
        objectType: LoyaltyTransactionObjectTypeCode.fromCode(map[mapper[LoyaltyTransactionKeys.objectType]] as int),
        objectId: map[mapper[LoyaltyTransactionKeys.objectId]] ?? "",
        log: map[mapper[LoyaltyTransactionKeys.log]],
        date: tryParseDateTime(map[mapper[LoyaltyTransactionKeys.date]]) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap(Map<LoyaltyTransactionKeys, String> mapper) => {
        mapper[LoyaltyTransactionKeys.loyaltyTransactionId]!: loyaltyTransactionId,
        mapper[LoyaltyTransactionKeys.clientId]!: clientId,
        if (cardId != null) mapper[LoyaltyTransactionKeys.cardId]!: cardId,
        if (programId != null) mapper[LoyaltyTransactionKeys.programId]!: programId,
        if (programName != null) mapper[LoyaltyTransactionKeys.programName]!: programName,
        if (userId != null) mapper[LoyaltyTransactionKeys.userId]!: userId,
        if (userCardId != null) mapper[LoyaltyTransactionKeys.userCardId]!: userCardId,
        mapper[LoyaltyTransactionKeys.points]!: points,
        if (digits > 0) mapper[LoyaltyTransactionKeys.digits]!: digits,
        mapper[LoyaltyTransactionKeys.objectType]!: objectType.code,
        mapper[LoyaltyTransactionKeys.objectId]!: objectId,
        if (log != null) mapper[LoyaltyTransactionKeys.log]!: log,
        mapper[LoyaltyTransactionKeys.date]!: date.toUtc().toIso8601String(),
      };
}

// eof

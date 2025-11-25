import "package:core_dart/core_dart.dart";

enum ProgramOnUserCardKeys {
  programId,
  name,
  plural,
  type,
  userPoints,
  digits,
  lastLocationId,
  lastLocationName,
  lastTransactionDate,
}

class ProgramOnUserCard {
  String programId;
  String name;
  Plural plural;
  ProgramType type;
  int userPoints;
  int digits;
  String? lastLocationId;
  String? lastLocationName;
  DateTime? lastTransactionDate;

  ProgramOnUserCard({
    required this.programId,
    required this.name,
    required this.plural,
    required this.type,
    required this.userPoints,
    this.digits = 0,
    this.lastLocationId,
    this.lastLocationName,
    this.lastTransactionDate,
  });

  static const camel = {
    ProgramOnUserCardKeys.programId: "programId",
    ProgramOnUserCardKeys.name: "name",
    ProgramOnUserCardKeys.plural: "plural",
    ProgramOnUserCardKeys.type: "type",
    ProgramOnUserCardKeys.userPoints: "userPoints",
    ProgramOnUserCardKeys.digits: "digits",
    ProgramOnUserCardKeys.lastLocationId: "lastLocationId",
    ProgramOnUserCardKeys.lastLocationName: "lastLocationName",
    ProgramOnUserCardKeys.lastTransactionDate: "lastTransactionDate",
  };

  static const snake = {
    ProgramOnUserCardKeys.programId: "program_id",
    ProgramOnUserCardKeys.name: "name",
    ProgramOnUserCardKeys.plural: "plural",
    ProgramOnUserCardKeys.type: "type",
    ProgramOnUserCardKeys.userPoints: "user_points",
    ProgramOnUserCardKeys.digits: "digits",
    ProgramOnUserCardKeys.lastLocationId: "last_location_id",
    ProgramOnUserCardKeys.lastLocationName: "last_location_name",
    ProgramOnUserCardKeys.lastTransactionDate: "last_transaction_date",
  };

  static ProgramOnUserCard fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProgramOnUserCard.camel : ProgramOnUserCard.snake;
    //final pluralMapper = mapper == camel ? Plural.camel : Plural.snake;
    return ProgramOnUserCard(
      programId: map[mapper[ProgramOnUserCardKeys.programId]!] as String,
      name: map[mapper[ProgramOnUserCardKeys.name]!] as String,
      plural: Plural.fromMap((map[mapper[ProgramOnUserCardKeys.plural]!] as Map).asStringMap, convention),
      type: ProgramTypeCode.fromCode(map[mapper[ProgramOnUserCardKeys.type]!] as int),
      userPoints: map[mapper[ProgramOnUserCardKeys.userPoints]!] as int,
      digits: tryParseInt(map[mapper[ProgramOnUserCardKeys.digits]!]) ?? 0,
      lastLocationId: map[mapper[ProgramOnUserCardKeys.lastLocationId]!] as String?,
      lastLocationName: map[mapper[ProgramOnUserCardKeys.lastLocationName]!] as String?,
      lastTransactionDate: tryParseDateTime(map[mapper[ProgramOnUserCardKeys.lastTransactionDate]!] as String?),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProgramOnUserCard.camel : ProgramOnUserCard.snake;
    return {
      mapper[ProgramOnUserCardKeys.programId]!: programId,
      mapper[ProgramOnUserCardKeys.name]!: name,
      mapper[ProgramOnUserCardKeys.plural]!: plural.toMap(convention),
      mapper[ProgramOnUserCardKeys.type]!: type.code,
      mapper[ProgramOnUserCardKeys.userPoints]!: userPoints,
      if (digits > 0) mapper[ProgramOnUserCardKeys.digits]!: digits,
      if (lastLocationId != null) mapper[ProgramOnUserCardKeys.lastLocationId]!: lastLocationId,
      if (lastLocationName != null) mapper[ProgramOnUserCardKeys.lastLocationName]!: lastLocationName,
      if (lastTransactionDate != null)
        mapper[ProgramOnUserCardKeys.lastTransactionDate]!: lastTransactionDate!.toUtc().toIso8601String(),
    };
  }
}

// eof

import "package:core_dart/core_dart.dart";

enum CardKeys {
  cardId,
  clientId,
  codeType,
  name,
  logo,
  logoBh,
  color,
  rank,
  countries,
  blocked,
  meta,
  updatedAt,
  //
  programNames,
}

class Card {
  String cardId;
  String? clientId;
  CodeType codeType;
  String name;
  String? logo;
  String? logoBh;
  Color color;
  int rank;
  List<Country>? countries;
  bool blocked;
  Map<String, dynamic>? meta;
  DateTime? updatedAt;
  //
  String? programNames;

  Card({
    required this.cardId,
    required this.clientId,
    required this.codeType,
    required this.name,
    this.logo,
    this.logoBh,
    this.color = Palette.white,
    this.rank = 1,
    this.countries,
    this.blocked = false,
    this.meta,
    this.updatedAt,
    //
    this.programNames,
  });

  Card copyWith({
    String? cardId,
    String? clientId,
    CodeType? codeType,
    String? name,
    String? logo,
    String? logoBh,
    Color? color,
    int? rank,
    List<Country>? countries,
    bool? blocked,
    Map<String, dynamic>? meta,
    String? programNames,
  }) =>
      Card(
        cardId: cardId ?? this.cardId,
        clientId: clientId ?? this.clientId,
        codeType: codeType ?? this.codeType,
        name: name ?? this.name,
        logo: logo ?? this.logo,
        logoBh: logoBh ?? this.logoBh,
        color: color ?? this.color,
        rank: rank ?? this.rank,
        countries: countries ?? this.countries,
        blocked: blocked ?? this.blocked,
        meta: meta ?? this.meta,
        programNames: programNames ?? this.programNames,
      );

  static const camel = {
    CardKeys.cardId: "cardId",
    CardKeys.clientId: "clientId",
    CardKeys.codeType: "codeType",
    CardKeys.name: "name",
    CardKeys.logo: "logo",
    CardKeys.logoBh: "logoBh",
    CardKeys.color: "color",
    CardKeys.rank: "rank",
    CardKeys.countries: "countries",
    CardKeys.blocked: "blocked",
    CardKeys.meta: "meta",
    CardKeys.updatedAt: "updatedAt",
    CardKeys.programNames: "programNames",
  };

  static const snake = {
    CardKeys.cardId: "card_id",
    CardKeys.clientId: "client_id",
    CardKeys.codeType: "code_type",
    CardKeys.name: "name",
    CardKeys.logo: "logo",
    CardKeys.logoBh: "logo_bh",
    CardKeys.color: "color",
    CardKeys.rank: "rank",
    CardKeys.countries: "countries",
    CardKeys.blocked: "blocked",
    CardKeys.meta: "meta",
    CardKeys.updatedAt: "updated_at",
    CardKeys.programNames: "program_names",
  };

  factory Card.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Card.camel : Card.snake;
    return Card(
      cardId: map[mapper[CardKeys.cardId]] as String,
      clientId: map[mapper[CardKeys.clientId]] as String?,
      codeType: CodeTypeCode.fromCode(map[mapper[CardKeys.codeType]] as int?),
      name: map[mapper[CardKeys.name]] as String,
      logo: map[mapper[CardKeys.logo]] as String?,
      logoBh: map[mapper[CardKeys.logoBh]] as String?,
      color: Color.fromHexOrNull(map[mapper[CardKeys.color]] as String?) ?? Palette.white,
      rank: map[mapper[CardKeys.rank]] as int? ?? 1,
      countries: CountryCode.fromCodesOrNull((map[mapper[CardKeys.countries]] as List<dynamic>?)?.cast<String>()),
      blocked: map[mapper[CardKeys.blocked]] as bool? ?? false,
      meta: map[mapper[CardKeys.meta]!] as Map<String, dynamic>?,
      updatedAt: tryParseDateTime(map[mapper[CardKeys.updatedAt]]),
      programNames: map[mapper[CardKeys.programNames]] as String?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Card.camel : Card.snake;
    return {
      mapper[CardKeys.cardId]!: cardId,
      if (clientId != null) mapper[CardKeys.clientId]!: clientId,
      mapper[CardKeys.codeType]!: codeType.code,
      mapper[CardKeys.name]!: name,
      if (logo != null) mapper[CardKeys.logo]!: logo,
      if (logoBh != null) mapper[CardKeys.logoBh]!: logoBh,
      mapper[CardKeys.color]!: color.toHex(),
      if (rank != 1) mapper[CardKeys.rank]!: rank,
      if (countries != null) mapper[CardKeys.countries]!: countries!.map((e) => e.code).toList(),
      if (blocked) mapper[CardKeys.blocked]!: blocked,
      if (meta != null) mapper[CardKeys.meta]!: meta,
      if (programNames != null) mapper[CardKeys.programNames]!: programNames,
    };
  }
}

// eof

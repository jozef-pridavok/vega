import "../../core_dart.dart";

enum ProgramKeys {
  programId,
  clientId,
  cardId,
  locationId,
  type,
  name,
  description,
  digits,
  image,
  imageBh,
  countries,
  rank,
  validFrom,
  validTo,
  blocked,
  meta,
  updatedAt,
  //
  rewards,
  plural,
  actions,
  cardName,
}

class Program {
  String programId;
  String clientId;
  String cardId;
  String? locationId;
  ProgramType type;
  String name;
  String? description;
  int digits;
  String? image;
  String? imageBh;
  List<Country>? countries;
  int rank;
  final IntDate validFrom;
  final IntDate? validTo;
  final bool blocked;
  Map<String, dynamic>? meta;
  DateTime? updatedAt;

  List<Reward>? rewards;
  Plural? plural;
  ProgramActions? actions;
  String? cardName;

  Program({
    required this.programId,
    required this.clientId,
    required this.cardId,
    this.locationId,
    required this.type,
    required this.name,
    this.description,
    this.digits = 0,
    this.image,
    this.imageBh,
    this.countries,
    this.rank = 1,
    required this.validFrom,
    this.validTo,
    this.blocked = false,
    this.meta,
    this.updatedAt,
    //
    this.rewards,
    this.plural,
    this.actions,
    this.cardName,
  });

  Program copyWith({
    String? programId,
    String? clientId,
    String? cardId,
    String? locationId,
    ProgramType? type,
    String? name,
    String? description,
    int? digits,
    String? image,
    String? imageBh,
    List<Country>? countries,
    int? rank,
    IntDate? validFrom,
    IntDate? validTo,
    bool? blocked,
    Map<String, dynamic>? meta,
    //
    List<Reward>? rewards,
    Plural? plural,
    ProgramActions? actions,
  }) =>
      Program(
        programId: programId ?? this.programId,
        clientId: clientId ?? this.clientId,
        cardId: cardId ?? this.cardId,
        locationId: locationId ?? this.locationId,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        digits: digits ?? this.digits,
        image: image ?? this.image,
        imageBh: imageBh ?? this.imageBh,
        countries: countries ?? this.countries,
        rank: rank ?? this.rank,
        validFrom: validFrom ?? this.validFrom,
        validTo: validTo ?? this.validTo,
        blocked: blocked ?? this.blocked,
        meta: meta ?? this.meta,
        //
        rewards: rewards ?? this.rewards,
        plural: plural ?? this.plural,
        actions: actions ?? this.actions,
        cardName: cardName,
      );

  static const camel = {
    ProgramKeys.programId: "programId",
    ProgramKeys.clientId: "clientId",
    ProgramKeys.cardId: "cardId",
    ProgramKeys.locationId: "locationId",
    ProgramKeys.type: "type",
    ProgramKeys.name: "name",
    ProgramKeys.description: "description",
    ProgramKeys.digits: "digits",
    ProgramKeys.image: "image",
    ProgramKeys.imageBh: "imageBh",
    ProgramKeys.countries: "countries",
    ProgramKeys.rank: "rank",
    ProgramKeys.validFrom: "validFrom",
    ProgramKeys.validTo: "validTo",
    ProgramKeys.blocked: "blocked",
    ProgramKeys.meta: "meta",
    ProgramKeys.updatedAt: "updatedAt",

    //
    ProgramKeys.rewards: "rewards",
    ProgramKeys.plural: "plural",
    ProgramKeys.actions: "actions",
    ProgramKeys.cardName: "cardName",
  };

  static const snake = {
    ProgramKeys.programId: "program_id",
    ProgramKeys.clientId: "client_id",
    ProgramKeys.cardId: "card_id",
    ProgramKeys.locationId: "location_id",
    ProgramKeys.type: "type",
    ProgramKeys.name: "name",
    ProgramKeys.description: "description",
    ProgramKeys.digits: "digits",
    ProgramKeys.image: "image",
    ProgramKeys.imageBh: "image_bh",
    ProgramKeys.countries: "countries",
    ProgramKeys.rank: "rank",
    ProgramKeys.validFrom: "valid_from",
    ProgramKeys.validTo: "valid_to",
    ProgramKeys.blocked: "blocked",
    ProgramKeys.meta: "meta",
    ProgramKeys.updatedAt: "updated_at",
    //
    ProgramKeys.rewards: "rewards",
    ProgramKeys.plural: "plural",
    ProgramKeys.actions: "actions",
    ProgramKeys.cardName: "card_name",
  };

  factory Program.fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Program.camel : Program.snake;
    return Program(
      programId: map[mapper[ProgramKeys.programId]] as String,
      clientId: map[mapper[ProgramKeys.clientId]] as String,
      cardId: map[mapper[ProgramKeys.cardId]] as String,
      locationId: map[mapper[ProgramKeys.locationId]] as String?,
      type: ProgramTypeCode.fromCode(map[mapper[ProgramKeys.type]] as int),
      name: map[mapper[ProgramKeys.name]] as String,
      description: map[mapper[ProgramKeys.description]] as String?,
      digits: tryParseInt(map[mapper[ProgramKeys.digits]]) ?? 0,
      image: map[mapper[ProgramKeys.image]] as String?,
      imageBh: map[mapper[ProgramKeys.imageBh]] as String?,
      countries:
          CountryCode.fromCodesOrNull(((map[mapper[ProgramKeys.countries]] ?? []) as List<dynamic>).cast<String>()),
      rank: map[mapper[ProgramKeys.rank]] as int? ?? 1,
      validFrom: IntDate.fromInt(map[mapper[ProgramKeys.validFrom]] as int),
      validTo: IntDate.parseInt(map[mapper[ProgramKeys.validTo]] as int?),
      blocked: tryParseBool(map[mapper[ProgramKeys.blocked]]) ?? false,
      meta: map[mapper[ProgramKeys.meta]!] as Map<String, dynamic>?,
      updatedAt: tryParseDateTime(map[mapper[ProgramKeys.updatedAt]]),
      //
      rewards: (map[mapper[ProgramKeys.rewards]] as List<dynamic>?)
              ?.map((e) => (e as Map<dynamic, dynamic>).asStringMap)
              .map((e) => Reward.fromMap(e, convention))
              .toList() ??
          [],
      plural: map[mapper[ProgramKeys.plural]!] is Map && (map[mapper[ProgramKeys.plural]!] as Map).isNotEmpty
          ? Plural.fromMap(map[mapper[ProgramKeys.plural]], convention)
          : null,
      actions: map[mapper[ProgramKeys.actions]] is Map
          ? ProgramActions.fromMap(map[mapper[ProgramKeys.actions]], convention)
          : null,
      cardName: map[mapper[ProgramKeys.cardName]] as String?,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Program.camel : Program.snake;
    return {
      mapper[ProgramKeys.programId]!: programId,
      mapper[ProgramKeys.clientId]!: clientId,
      mapper[ProgramKeys.cardId]!: cardId,
      if (locationId != null) mapper[ProgramKeys.locationId]!: locationId,
      mapper[ProgramKeys.type]!: type.code,
      mapper[ProgramKeys.name]!: name,
      if (description != null) mapper[ProgramKeys.description]!: description,
      if (digits > 0) mapper[ProgramKeys.digits]!: digits,
      if (image != null) mapper[ProgramKeys.image]!: image,
      if (imageBh != null) mapper[ProgramKeys.imageBh]!: imageBh,
      if (countries != null) mapper[ProgramKeys.countries]!: countries!.map((e) => e.code).toList(),
      if (rank != 1) mapper[ProgramKeys.rank]!: rank,
      mapper[ProgramKeys.validFrom]!: validFrom.value,
      if (validTo != null) mapper[ProgramKeys.validTo]!: validTo?.value,
      if (blocked) mapper[ProgramKeys.blocked]!: blocked,
      if (meta != null) mapper[ProgramKeys.meta]!: meta,
      //
      if (rewards != null) mapper[ProgramKeys.rewards]!: rewards!.map((e) => e.toMap(convention)).toList(),
      if (plural != null) mapper[ProgramKeys.plural]!: plural!.toMap(convention),
      if (actions != null) mapper[ProgramKeys.actions]!: actions!.toMap(convention),
      if (cardName != null) mapper[ProgramKeys.cardName]!: cardName,
    };
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Program) return programId == other.programId;
    return false;
  }

  @override
  int get hashCode => programId.hashCode;

  ////////////////////////////////////////////////////////////////////////////////
  // Meta

  static const String keyMetaQrCodeScanning = "qrCodeScanning";
  static const String keyMetaQrCodeScanningRatio = "ratio";

  static const String keyMetaReservations = "reservations";
  static const String keyMetaReservationsRatio = "ratio";

  static const String keyMetaOrders = "orders";
  static const String keyMetaOrdersRatio = "ratio";

  static const String keyMetaPlural = "plural";
  static const String keyMetaPluralZero = "zero";
  static const String keyMetaPluralOne = "one";
  static const String keyMetaPluralTwo = "two";
  static const String keyMetaPluralFew = "few";
  static const String keyMetaPluralMany = "many";
  static const String keyMetaPluralOther = "other";

  static const String keyMetaActions = "actions";
  static const String keyMetaActionsAddition = "addition";
  static const String keyMetaActionsSubtraction = "subtraction";

  Map<dynamic, dynamic> get qrCodeScanning => meta?[keyMetaQrCodeScanning] ?? {};
  double get qrCodeScanningRatio => qrCodeScanning[keyMetaQrCodeScanningRatio] as double? ?? 1.0;
  void setQrCodeScanning({double? ratio}) {
    final qrCodeScanning = {
      if (ratio != null) keyMetaQrCodeScanningRatio: ratio,
    };
    if (qrCodeScanning.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaQrCodeScanning] = {...(meta[keyMetaQrCodeScanning] ?? {}), ...qrCodeScanning};
      this.meta = meta;
    }
  }

  Map<dynamic, dynamic> get reservations => meta?[keyMetaReservations] ?? {};
  double get reservationsRatio => reservations[keyMetaReservationsRatio] as double? ?? 1.0;
  void setReservations({double? ratio}) {
    final reservations = {
      if (ratio != null) keyMetaReservationsRatio: ratio,
    };
    if (reservations.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaReservations] = {...(meta[keyMetaReservations] ?? {}), ...reservations};
      this.meta = meta;
    }
  }

  Map<dynamic, dynamic> get orders => meta?[keyMetaOrders] ?? {};
  double get ordersRatio => orders[keyMetaOrdersRatio] as double? ?? 1.0;
  void setOrders({double? ratio}) {
    final orders = {
      if (ratio != null) keyMetaOrdersRatio: ratio,
    };
    if (orders.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaOrders] = {...(meta[keyMetaOrders] ?? {}), ...orders};
      this.meta = meta;
    }
  }

  void setPlural({Plural? plural}) {
    if (plural != null) {
      final meta = this.meta ?? {};
      meta[keyMetaPlural] = plural.toMap(Convention.camel);
      this.meta = meta;
    }
  }

  void setActions({ProgramActions? actions}) {
    if (actions != null) {
      final meta = this.meta ?? {};
      meta[keyMetaActions] = actions.toMap(Convention.camel);
      this.meta = meta;
    }
  }
}

// eof

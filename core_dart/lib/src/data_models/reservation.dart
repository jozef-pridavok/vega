import "package:core_dart/core_dart.dart";

enum ReservationKeys {
  reservationId,
  clientId,
  programId,
  loyaltyMode,
  name,
  description,
  image,
  imageBh,
  rank,
  blocked,
  meta,
  //
  reservationSlots,
  eligiblePrograms,
  discount,
}

class Reservation {
  String reservationId;
  String clientId;
  String? programId;
  LoyaltyMode loyaltyMode;
  String name;
  String? description;
  String? image;
  String? imageBh;
  int rank;
  bool blocked;
  JsonObject? meta;
  //
  List<ReservationSlot> reservationSlots;
  int? discount;

  Reservation({
    required this.reservationId,
    required this.clientId,
    this.programId,
    required this.loyaltyMode,
    required this.name,
    this.description,
    this.image,
    this.imageBh,
    this.rank = 1,
    this.blocked = false,
    this.meta,
    //
    this.reservationSlots = const [],
    this.discount,
  });

  Reservation copyWith({
    String? reservationId,
    String? clientId,
    String? programId,
    LoyaltyMode? loyaltyMode,
    String? name,
    String? description,
    String? image,
    String? imageBh,
    int? rank,
    bool? blocked,
    JsonObject? meta,
    //
    List<ReservationSlot>? reservationSlots,
    int? discount,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      clientId: clientId ?? this.clientId,
      programId: programId ?? this.programId,
      loyaltyMode: loyaltyMode ?? this.loyaltyMode,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      imageBh: imageBh ?? this.imageBh,
      rank: rank ?? this.rank,
      blocked: blocked ?? this.blocked,
      meta: meta ?? this.meta,
      //
      reservationSlots: reservationSlots ?? this.reservationSlots,
      discount: discount ?? this.discount,
    );
  }

  static const camel = {
    ReservationKeys.reservationId: "reservationId",
    ReservationKeys.clientId: "clientId",
    ReservationKeys.programId: "programId",
    ReservationKeys.loyaltyMode: "loyaltyMode",
    ReservationKeys.name: "name",
    ReservationKeys.description: "description",
    ReservationKeys.image: "image",
    ReservationKeys.imageBh: "imageBh",
    ReservationKeys.rank: "rank",
    ReservationKeys.blocked: "blocked",
    ReservationKeys.meta: "meta",
    ReservationKeys.reservationSlots: "reservationSlots",
    ReservationKeys.discount: "discount",
  };

  static const snake = {
    ReservationKeys.reservationId: "reservation_id",
    ReservationKeys.clientId: "client_id",
    ReservationKeys.programId: "program_id",
    ReservationKeys.loyaltyMode: "loyalty_mode",
    ReservationKeys.name: "name",
    ReservationKeys.description: "description",
    ReservationKeys.image: "image",
    ReservationKeys.imageBh: "image_bh",
    ReservationKeys.rank: "rank",
    ReservationKeys.blocked: "blocked",
    ReservationKeys.meta: "meta",
    ReservationKeys.reservationSlots: "reservation_slots",
    ReservationKeys.discount: "discount",
  };

  static const snake2 = {
    ReservationKeys.reservationId: "reservation_id",
    ReservationKeys.clientId: "client_id",
    ReservationKeys.programId: "program_id",
    ReservationKeys.name: "reservation_name",
    ReservationKeys.description: "reservation_description",
    ReservationKeys.loyaltyMode: "reservation_loyalty_mode",
    ReservationKeys.discount: "reservation_discount",
  };

  static Reservation fromMap(
    Map<String, dynamic> map,
    Map<ReservationKeys, String> mapper, {
    Map<String, dynamic>? reservationSlotsMap,
  }) {
    final reservationSlotsMapper = mapper == camel ? ReservationSlot.camel : ReservationSlot.snake;
    return Reservation(
      reservationId: map[mapper[ReservationKeys.reservationId]] as String,
      clientId: map[mapper[ReservationKeys.clientId]] as String,
      programId: map[mapper[ReservationKeys.programId]] as String?,
      loyaltyMode: LoyaltyModeCode.fromCode(map[mapper[ReservationKeys.loyaltyMode]] as int),
      name: map[mapper[ReservationKeys.name]] as String,
      description: map[mapper[ReservationKeys.description]] as String?,
      image: map[mapper[ReservationKeys.image]] as String?,
      imageBh: map[mapper[ReservationKeys.imageBh]] as String?,
      rank: map[mapper[ReservationKeys.rank]] as int? ?? 1,
      blocked: tryParseBool(map[mapper[ReservationKeys.blocked]]) ?? false,
      meta: map[mapper[ReservationKeys.meta]] as JsonObject?,
      reservationSlots: (reservationSlotsMap?[mapper[ReservationKeys.reservationSlots]] as List<dynamic>?)
              ?.map((e) => (e as Map<dynamic, dynamic>).asStringMap)
              .map((e) => ReservationSlot.fromMap(e, reservationSlotsMapper))
              .toList() ??
          [],
      discount: map[mapper[ReservationKeys.discount]] as int?,
    );
  }

  Map<String, dynamic> toMap(Map<ReservationKeys, String> mapper) {
    final reservationSlotsMapper = mapper == camel ? ReservationSlot.camel : ReservationSlot.snake;
    return {
      mapper[ReservationKeys.reservationId]!: reservationId,
      mapper[ReservationKeys.clientId]!: clientId,
      if (programId != null) mapper[ReservationKeys.programId]!: programId,
      mapper[ReservationKeys.loyaltyMode]!: loyaltyMode.code,
      mapper[ReservationKeys.name]!: name,
      if (description != null) mapper[ReservationKeys.description]!: description,
      if (image != null) mapper[ReservationKeys.image]!: image,
      if (imageBh != null) mapper[ReservationKeys.imageBh]!: imageBh,
      if (rank != 1) mapper[ReservationKeys.rank]!: rank,
      if (blocked) mapper[ReservationKeys.blocked]!: blocked,
      if (meta != null) mapper[ReservationKeys.meta]!: meta,
      if (reservationSlots.isNotEmpty)
        mapper[ReservationKeys.reservationSlots]!:
            reservationSlots.map((e) => e.toMap(reservationSlotsMapper)).toList(),
      if (discount != null) mapper[ReservationKeys.discount]!: discount,
    };
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Reservation) return reservationId == other.reservationId;
    return false;
  }

  @override
  int get hashCode => reservationId.hashCode;
}


// eof

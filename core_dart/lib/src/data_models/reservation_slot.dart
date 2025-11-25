import "../../core_dart.dart";

enum ReservationSlotKeys {
  reservationSlotId,
  clientId,
  reservationId,
  locationId,
  name,
  description,
  image,
  imageBh,
  rank,
  price,
  currency,
  duration,
  color,
  blocked,
  meta,
  //
  deletedAt,
  reservationDates,
  discount,
}

class ReservationSlot {
  String reservationSlotId;
  String clientId;
  String reservationId;
  String? locationId;
  String name;
  String? description;
  String? image;
  String? imageBh;
  int rank;
  int? price;
  Currency? currency;
  int? duration;
  Color color;
  bool blocked;
  JsonObject? meta;
  //
  DateTime? deletedAt;
  List<ReservationDate>? reservationDates;
  int? discount;

  ReservationSlot({
    required this.reservationSlotId,
    required this.clientId,
    required this.reservationId,
    this.locationId,
    required this.name,
    this.description,
    this.image,
    this.imageBh,
    this.rank = 1,
    this.price,
    this.currency,
    this.duration,
    this.color = Palette.white,
    this.blocked = false,
    this.meta,
    //
    this.deletedAt,
    this.reservationDates,
    this.discount,
  });

  ReservationSlot copyWith({
    String? reservationSlotId,
    String? clientId,
    String? reservationId,
    String? locationId,
    String? name,
    String? description,
    String? image,
    String? imageBh,
    int? rank,
    int? price,
    Currency? currency,
    int? duration,
    Color? color,
    bool? blocked,
    JsonObject? meta,
    //
    DateTime? deletedAt,
    List<ReservationDate>? reservationDates,
    int? discount,
  }) =>
      ReservationSlot(
        reservationSlotId: reservationSlotId ?? this.reservationSlotId,
        clientId: clientId ?? this.clientId,
        reservationId: reservationId ?? this.reservationId,
        locationId: locationId ?? this.locationId,
        name: name ?? this.name,
        description: description ?? this.description,
        image: image ?? this.image,
        imageBh: imageBh ?? this.imageBh,
        rank: rank ?? this.rank,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        duration: duration ?? this.duration,
        color: color ?? this.color,
        blocked: blocked ?? this.blocked,
        meta: meta ?? this.meta,
        //
        deletedAt: deletedAt ?? this.deletedAt,
        reservationDates: reservationDates ?? this.reservationDates,
        discount: discount ?? this.discount,
      );

  static const camel = {
    ReservationSlotKeys.reservationSlotId: "reservationSlotId",
    ReservationSlotKeys.clientId: "clientId",
    ReservationSlotKeys.reservationId: "reservationId",
    ReservationSlotKeys.locationId: "locationId",
    ReservationSlotKeys.name: "name",
    ReservationSlotKeys.description: "description",
    ReservationSlotKeys.image: "image",
    ReservationSlotKeys.imageBh: "imageBh",
    ReservationSlotKeys.rank: "rank",
    ReservationSlotKeys.price: "price",
    ReservationSlotKeys.currency: "currency",
    ReservationSlotKeys.duration: "duration",
    ReservationSlotKeys.color: "color",
    ReservationSlotKeys.blocked: "blocked",
    ReservationSlotKeys.meta: "meta",
    ReservationSlotKeys.deletedAt: "deletedAt",
    ReservationSlotKeys.reservationDates: "reservationDates",
    ReservationSlotKeys.discount: "discount",
  };

  static const snake = {
    ReservationSlotKeys.reservationSlotId: "reservation_slot_id",
    ReservationSlotKeys.clientId: "client_id",
    ReservationSlotKeys.reservationId: "reservation_id",
    ReservationSlotKeys.locationId: "location_id",
    ReservationSlotKeys.name: "name",
    ReservationSlotKeys.description: "description",
    ReservationSlotKeys.image: "image",
    ReservationSlotKeys.imageBh: "image_bh",
    ReservationSlotKeys.rank: "rank",
    ReservationSlotKeys.price: "price",
    ReservationSlotKeys.currency: "currency",
    ReservationSlotKeys.duration: "duration",
    ReservationSlotKeys.color: "color",
    ReservationSlotKeys.blocked: "blocked",
    ReservationSlotKeys.meta: "meta",
    ReservationSlotKeys.deletedAt: "deleted_at",
    ReservationSlotKeys.reservationDates: "reservation_dates",
    ReservationSlotKeys.discount: "slot_discount",
  };

  static const snake2 = {
    ReservationSlotKeys.reservationSlotId: "reservation_slot_id",
    ReservationSlotKeys.reservationId: "reservation_id",
    ReservationSlotKeys.clientId: "client_id",
    ReservationSlotKeys.locationId: "location_id",
    ReservationSlotKeys.name: "reservation_slot_name",
    ReservationSlotKeys.description: "reservation_slot_description",
    ReservationSlotKeys.price: "reservation_slot_price",
    ReservationSlotKeys.currency: "reservation_slot_currency",
    ReservationSlotKeys.duration: "reservation_slot_duration",
    ReservationSlotKeys.discount: "slot_discount",
  };

  static ReservationSlot fromMap(
    Map<String, dynamic> map,
    Map<ReservationSlotKeys, String> mapper, {
    Map<String, dynamic>? reservationDatesMap,
  }) {
    final reservationDatesMapper = mapper == camel ? ReservationDate.camel : ReservationDate.snake;
    return ReservationSlot(
      reservationSlotId: map[mapper[ReservationSlotKeys.reservationSlotId]] as String,
      clientId: map[mapper[ReservationSlotKeys.clientId]] as String,
      reservationId: map[mapper[ReservationSlotKeys.reservationId]] as String,
      locationId: map[mapper[ReservationSlotKeys.locationId]] as String?,
      name: map[mapper[ReservationSlotKeys.name]] as String,
      description: map[mapper[ReservationSlotKeys.description]] as String?,
      image: map[mapper[ReservationSlotKeys.image]] as String?,
      imageBh: map[mapper[ReservationSlotKeys.imageBh]] as String?,
      rank: map[mapper[ReservationSlotKeys.rank]] as int? ?? 1,
      price: map[mapper[ReservationSlotKeys.price]] as int?,
      currency: CurrencyCode.fromCodeOrNull(map[mapper[ReservationSlotKeys.currency]] as String?),
      duration: tryParseInt(map[mapper[ReservationSlotKeys.duration]] as int?),
      color: Color.fromHexOrNull(map[mapper[ReservationSlotKeys.color]] as String?) ?? Palette.white,
      blocked: (map[mapper[ReservationSlotKeys.blocked]] ?? false) as bool,
      meta: map[mapper[ReservationSlotKeys.meta]] as JsonObject?,
      deletedAt: tryParseDateTime(map[mapper[ReservationSlotKeys.deletedAt]]),
      reservationDates: (reservationDatesMap?[mapper[ReservationSlotKeys.reservationDates]] as List<dynamic>?)
          ?.map((e) => (e as Map<dynamic, dynamic>).asStringMap)
          .map((e) => ReservationDate.fromMap(e, reservationDatesMapper))
          .toList(),
      discount: map[mapper[ReservationSlotKeys.discount]] as int?,
    );
  }

  Map<String, dynamic> toMap(Map<ReservationSlotKeys, String> mapper) {
    final reservationDatesMapper = mapper == camel ? ReservationDate.camel : ReservationDate.snake;
    return {
      mapper[ReservationSlotKeys.reservationSlotId]!: reservationSlotId,
      mapper[ReservationSlotKeys.clientId]!: clientId,
      mapper[ReservationSlotKeys.reservationId]!: reservationId,
      if (locationId != null) mapper[ReservationSlotKeys.locationId]!: locationId,
      mapper[ReservationSlotKeys.name]!: name,
      if (description != null) mapper[ReservationSlotKeys.description]!: description,
      if (image != null) mapper[ReservationSlotKeys.image]!: image,
      if (imageBh != null) mapper[ReservationSlotKeys.imageBh]!: imageBh,
      if (rank != 1) mapper[ReservationSlotKeys.rank]!: rank,
      if (price != null) mapper[ReservationSlotKeys.price]!: price,
      if (currency != null) mapper[ReservationSlotKeys.currency]!: currency?.code,
      if (duration != null) mapper[ReservationSlotKeys.duration]!: duration,
      mapper[ReservationSlotKeys.color]!: color.toHex(),
      if (blocked) mapper[ReservationSlotKeys.blocked]!: blocked,
      if (meta != null) mapper[ReservationSlotKeys.meta]!: meta,
      if (deletedAt != null) mapper[ReservationSlotKeys.deletedAt]!: deletedAt?.toUtc().toIso8601String(),
      if (reservationDates != null)
        mapper[ReservationSlotKeys.reservationDates]!:
            reservationDates!.map((e) => e.toMap(reservationDatesMapper)).toList(),
      if (discount != null) mapper[ReservationSlotKeys.discount]!: discount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReservationSlot && reservationSlotId == other.reservationSlotId;

  @override
  int get hashCode => reservationSlotId.hashCode;
}


// eof

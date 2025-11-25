import "package:core_dart/core_dart.dart";

enum UserReservationKeys {
  reservationId,
  reservationName,
  reservationDescription,
  reservationLoyaltyMode,
  reservationDiscount,
  programId,
  clientId,
  reservationSlotId,
  reservationSlotName,
  reservationSlotDescription,
  reservationSlotPrice,
  reservationSlotCurrency,
  reservationSlotDuration,
  reservationSlotDiscount,
  locationId,
  locationName,
  locationAddressLine1,
  locationAddressLine2,
  locationZip,
  locationCity,
  locationState,
  reservationDateId,
  reservationDateStatus,
  reservationDateFrom,
  reservationDateTo,
}

class UserReservation {
  final String reservationId;
  final String reservationName;
  final String? reservationDescription;
  final LoyaltyMode reservationLoyaltyMode;
  final int? reservationDiscount;
  final String clientId;
  final String? programId;
  final String reservationSlotId;
  final String reservationSlotName;
  final String? reservationSlotDescription;
  final int? reservationSlotPrice;
  final Currency? reservationSlotCurrency;
  final int? reservationSlotDuration;
  final int? reservationSlotDiscount;
  final String? locationId;
  final String? locationName;
  final String? locationAddressLine1;
  final String? locationAddressLine2;
  final String? locationZip;
  final String? locationCity;
  final String? locationState;
  final ReservationDateStatus reservationDateStatus;
  final String reservationDateId;
  final DateTime reservationDateFrom;
  final DateTime reservationDateTo;

  UserReservation({
    required this.reservationId,
    required this.reservationName,
    this.reservationDescription,
    this.reservationLoyaltyMode = LoyaltyMode.none,
    this.reservationDiscount,
    required this.clientId,
    this.programId,
    required this.reservationSlotId,
    required this.reservationSlotName,
    this.reservationSlotDescription,
    this.reservationSlotPrice,
    this.reservationSlotCurrency,
    this.reservationSlotDuration,
    this.reservationSlotDiscount,
    this.locationId,
    this.locationName,
    this.locationAddressLine1,
    this.locationAddressLine2,
    this.locationZip,
    this.locationCity,
    this.locationState,
    required this.reservationDateId,
    required this.reservationDateStatus,
    required this.reservationDateFrom,
    required this.reservationDateTo,
  });

  factory UserReservation.createNew(
    String clientId, {
    String? reservationId,
    LoyaltyMode? reservationLoyaltyMode,
    int? reservationDiscount,
    String? slotId,
    int? reservationSlotDiscount,
  }) =>
      UserReservation(
        reservationId: reservationId ?? "",
        reservationLoyaltyMode: reservationLoyaltyMode ?? LoyaltyMode.none,
        reservationName: "",
        reservationDiscount: reservationDiscount,
        clientId: clientId,
        reservationSlotId: slotId ?? "",
        reservationSlotName: "",
        reservationSlotDiscount: reservationSlotDiscount,
        reservationDateStatus: ReservationDateStatus.available,
        reservationDateId: "",
        reservationDateFrom: DateTime.now(),
        reservationDateTo: DateTime.now(),
      );

  UserReservation copyWith({
    Reservation? reservation,
    ReservationSlot? reservationSlot,
    ReservationDate? reservationDate,
  }) {
    return UserReservation(
      reservationId: reservationSlot?.reservationId ?? reservationId,
      reservationName: reservation?.name ?? reservationName,
      reservationDescription: reservation?.description ?? reservationDescription,
      reservationLoyaltyMode: reservation?.loyaltyMode ?? reservationLoyaltyMode,
      reservationDiscount: reservation?.discount ?? reservationDiscount,
      clientId: clientId,
      programId: programId,
      reservationSlotId: reservationSlot?.reservationSlotId ?? reservationSlotId,
      reservationSlotName: reservationSlot?.name ?? reservationSlotName,
      reservationSlotDescription: reservationSlot?.description ?? reservationSlotDescription,
      reservationSlotPrice: reservationSlot?.price ?? reservationSlotPrice,
      reservationSlotCurrency: reservationSlot?.currency ?? reservationSlotCurrency,
      reservationSlotDuration: reservationSlot?.duration ?? reservationSlotDuration,
      reservationSlotDiscount: reservationSlot?.discount ?? reservationSlotDiscount,
      locationId: locationId,
      locationName: locationName,
      locationAddressLine1: locationAddressLine1,
      locationAddressLine2: locationAddressLine2,
      locationZip: locationZip,
      locationCity: locationCity,
      locationState: locationState,
      reservationDateId: reservationDate?.reservationDateId ?? reservationDateId,
      reservationDateStatus: reservationDate?.status ?? reservationDateStatus,
      reservationDateFrom: reservationDate?.dateTimeFrom ?? reservationDateFrom,
      reservationDateTo: reservationDate?.dateTimeTo ?? reservationDateTo,
    );
  }

  static const snake = {
    UserReservationKeys.reservationId: "reservation_id",
    UserReservationKeys.reservationName: "reservation_name",
    UserReservationKeys.reservationDescription: "reservation_description",
    //UserReservationKeys.loyaltyMode: "loyalty_mode",
    UserReservationKeys.clientId: "client_id",
    UserReservationKeys.programId: "program_id",
    UserReservationKeys.reservationSlotId: "reservation_slot_id",
    UserReservationKeys.reservationSlotName: "reservation_slot_name",
    UserReservationKeys.reservationSlotDescription: "reservation_slot_description",
    UserReservationKeys.reservationSlotPrice: "reservation_slot_price",
    UserReservationKeys.reservationSlotCurrency: "reservation_slot_currency",
    UserReservationKeys.reservationSlotDuration: "reservation_slot_duration",
    UserReservationKeys.locationId: "location_id",
    UserReservationKeys.locationName: "location_name",
    UserReservationKeys.locationAddressLine1: "location_address_line_1",
    UserReservationKeys.locationAddressLine2: "location_address_line_2",
    UserReservationKeys.locationZip: "location_zip",
    UserReservationKeys.locationCity: "location_city",
    UserReservationKeys.locationState: "location_state",
    UserReservationKeys.reservationDateId: "reservation_date_id",
    UserReservationKeys.reservationDateStatus: "reservation_date_status",
    UserReservationKeys.reservationDateFrom: "reservation_date_from",
    UserReservationKeys.reservationDateTo: "reservation_date_to",
  };

  static const camel = {
    UserReservationKeys.reservationId: "reservationId",
    UserReservationKeys.reservationName: "reservationName",
    UserReservationKeys.reservationDescription: "reservationDescription",
    //UserReservationKeys.loyaltyMode: "loyaltyMode",
    UserReservationKeys.clientId: "clientId",
    UserReservationKeys.programId: "programId",
    UserReservationKeys.reservationSlotId: "reservationSlotId",
    UserReservationKeys.reservationSlotName: "reservationSlotName",
    UserReservationKeys.reservationSlotDescription: "reservationSlotDescription",
    UserReservationKeys.reservationSlotPrice: "reservationSlotPrice",
    UserReservationKeys.reservationSlotCurrency: "reservationSlotCurrency",
    UserReservationKeys.reservationSlotDuration: "reservationSlotDuration",
    UserReservationKeys.locationId: "locationId",
    UserReservationKeys.locationName: "locationName",
    UserReservationKeys.locationAddressLine1: "locationAddressLine1",
    UserReservationKeys.locationAddressLine2: "locationAddressLine2",
    UserReservationKeys.locationZip: "locationZip",
    UserReservationKeys.locationCity: "locationCity",
    UserReservationKeys.locationState: "locationState",
    UserReservationKeys.reservationDateId: "reservationDateId",
    UserReservationKeys.reservationDateStatus: "reservationDateStatus",
    UserReservationKeys.reservationDateFrom: "reservationDateFrom",
    UserReservationKeys.reservationDateTo: "reservationDateTo",
  };

  factory UserReservation.fromMap(Map<String, dynamic> map, Map<UserReservationKeys, String> mapper) {
    return UserReservation(
      reservationId: map[mapper[UserReservationKeys.reservationId]] as String,
      reservationName: map[mapper[UserReservationKeys.reservationName]] as String,
      reservationDescription: map[mapper[UserReservationKeys.reservationDescription]] as String?,
      //loyaltyMode: LoyaltyModeCode.fromCode(map[mapper[UserReservationKeys.loyaltyMode]]),
      clientId: map[mapper[UserReservationKeys.clientId]] as String,
      programId: map[mapper[UserReservationKeys.programId]] as String?,
      reservationSlotId: map[mapper[UserReservationKeys.reservationSlotId]] as String,
      reservationSlotName: map[mapper[UserReservationKeys.reservationSlotName]] as String,
      reservationSlotDescription: map[mapper[UserReservationKeys.reservationSlotDescription]] as String?,
      reservationSlotPrice: tryParseInt(map[mapper[UserReservationKeys.reservationSlotPrice]] as int?),
      reservationSlotCurrency: CurrencyCode.fromCodeOrNull(map[mapper[UserReservationKeys.reservationSlotCurrency]]),
      reservationSlotDuration: tryParseInt(map[mapper[UserReservationKeys.reservationSlotDuration]] as int?),
      locationId: map[mapper[UserReservationKeys.locationId]] as String?,
      locationName: map[mapper[UserReservationKeys.locationName]] as String?,
      locationAddressLine1: map[mapper[UserReservationKeys.locationAddressLine1]] as String?,
      locationAddressLine2: map[mapper[UserReservationKeys.locationAddressLine2]] as String?,
      locationZip: map[mapper[UserReservationKeys.locationZip]] as String?,
      locationCity: map[mapper[UserReservationKeys.locationCity]] as String?,
      locationState: map[mapper[UserReservationKeys.locationState]] as String?,
      reservationDateId: map[mapper[UserReservationKeys.reservationDateId]] as String,
      reservationDateStatus: ReservationDateStatusCode.fromCode(map[mapper[UserReservationKeys.reservationDateStatus]]),
      reservationDateFrom: tryParseDateTime(map[mapper[UserReservationKeys.reservationDateFrom]])!,
      reservationDateTo: tryParseDateTime(map[mapper[UserReservationKeys.reservationDateTo]])!,
    );
  }

  Map<String, dynamic> toMap(Map<UserReservationKeys, String> mapper) {
    return {
      mapper[UserReservationKeys.reservationId]!: reservationId,
      mapper[UserReservationKeys.reservationName]!: reservationName,
      if (reservationDescription != null) mapper[UserReservationKeys.reservationDescription]!: reservationDescription,
      //if (loyaltyMode != LoyaltyMode.none) mapper[UserReservationKeys.loyaltyMode]!: loyaltyMode.code,
      mapper[UserReservationKeys.clientId]!: clientId,
      if (programId != null) mapper[UserReservationKeys.programId]!: programId,
      mapper[UserReservationKeys.reservationSlotId]!: reservationSlotId,
      mapper[UserReservationKeys.reservationSlotName]!: reservationSlotName,
      if (reservationSlotDescription != null)
        mapper[UserReservationKeys.reservationSlotDescription]!: reservationSlotDescription,
      if (reservationSlotPrice != null) mapper[UserReservationKeys.reservationSlotPrice]!: reservationSlotPrice,
      if (reservationSlotCurrency != null)
        mapper[UserReservationKeys.reservationSlotCurrency]!: reservationSlotCurrency!.code,
      if (reservationSlotDuration != null)
        mapper[UserReservationKeys.reservationSlotDuration]!: reservationSlotDuration,
      if (locationId != null) mapper[UserReservationKeys.locationId]!: locationId,
      if (locationName != null) mapper[UserReservationKeys.locationName]!: locationName,
      if (locationAddressLine1 != null) mapper[UserReservationKeys.locationAddressLine1]!: locationAddressLine1,
      if (locationAddressLine2 != null) mapper[UserReservationKeys.locationAddressLine2]!: locationAddressLine2,
      if (locationZip != null) mapper[UserReservationKeys.locationZip]!: locationZip,
      if (locationCity != null) mapper[UserReservationKeys.locationCity]!: locationCity,
      if (locationState != null) mapper[UserReservationKeys.locationState]!: locationState,
      mapper[UserReservationKeys.reservationDateId]!: reservationDateId,
      mapper[UserReservationKeys.reservationDateStatus]!: reservationDateStatus.code,
      mapper[UserReservationKeys.reservationDateFrom]!: reservationDateFrom.toIso8601String(),
      mapper[UserReservationKeys.reservationDateTo]!: reservationDateTo.toIso8601String(),
    };
  }
}

// eof

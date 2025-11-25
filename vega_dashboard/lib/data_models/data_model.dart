import "package:core_flutter/core_dart.dart";

class DataModel {
  static Location createLocation(Client client) {
    final countryCentroid = client.countries?.first.countryCentroid;
    return Location(
      locationId: uuid(),
      clientId: client.clientId,
      type: LocationType.mainBranch,
      name: "",
      country: client.countries?.firstOrNull ?? Country.slovakia,
      longitude: countryCentroid?.longitude ?? 0,
      latitude: countryCentroid?.latitude ?? 0,
    );
  }

  static Card createCard(Client client) {
    final countries = client.countries;
    return Card(
      cardId: uuid(),
      clientId: client.clientId,
      codeType: CodeType.code128,
      name: client.name,
      countries: (countries?.isNotEmpty ?? false) ? [countries!.first] : [],
    );
  }

  static Program createProgram(Client client) => Program(
        programId: uuid(),
        clientId: client.clientId,
        cardId: "",
        name: "",
        type: ProgramType.reach,
        validFrom: IntDate.now().addDays(60),
      );

  static Reward createReward(Program program) => Reward(
        programRewardId: uuid(),
        programId: program.programId,
        name: "",
        points: 1,
        validFrom: IntDate.now(),
      );

  static Leaflet createLeaflet(Client client) => Leaflet(
        leafletId: uuid(),
        clientId: client.clientId,
        country: client.countries?.firstOrNull ?? Country.slovakia,
        name: "",
        validFrom: DateTimeExtensions.startOfNextWeek.toIntDate(),
        validTo: DateTimeExtensions.endOfNextWeek.toIntDate(),
      );

  static Coupon createCoupon(Client client) => Coupon(
        couponId: uuid(),
        clientId: client.clientId,
        name: "",
        type: CouponType.universal,
        validFrom: DateTimeExtensions.startOfNextWeek.toIntDate(),
        validTo: DateTimeExtensions.endOfNextWeek.toIntDate(),
      );

  static Reservation createReservation(Client client) => Reservation(
        reservationId: uuid(),
        clientId: client.clientId,
        name: "",
        loyaltyMode: LoyaltyMode.countSpentMoney,
      );

  static ReservationSlot createReservationSlot(Reservation reservation) => ReservationSlot(
        reservationSlotId: uuid(),
        reservationId: reservation.reservationId,
        clientId: reservation.clientId,
        name: "",
      );

  static Card? _emptyCardInstance;

  static Card emptyCard() => _emptyCardInstance ??= Card(
        cardId: "",
        clientId: "",
        codeType: CodeType.code128,
        name: "",
        countries: [],
        blocked: true,
      );

  static Program? _emptyProgramInstance;

  static Program emptyProgram() => _emptyProgramInstance ??= Program(
        programId: "",
        clientId: "",
        cardId: "",
        type: ProgramType.collect,
        name: "",
        countries: [],
        validFrom: IntDate.fromDate(DateTime.now()),
        blocked: true,
      );

  static Reward? _emptyRewardInstance;

  static Reward emptyReward() => _emptyRewardInstance ??= Reward(
        programRewardId: "",
        programId: "",
        name: "",
        points: 1,
        validFrom: IntDate.fromDate(DateTime.now()),
        validTo: IntDate.fromDate(DateTime.now()),
        blocked: true,
      );

  static Leaflet? _emptyLeafletInstance;

  static Leaflet emptyLeaflet() => _emptyLeafletInstance ??= Leaflet(
        leafletId: "",
        clientId: "",
        country: Country.slovakia,
        name: "",
        validFrom: IntDate.fromDate(DateTime.now()),
        validTo: IntDate.fromDate(DateTime.now()),
        blocked: true,
      );

  static Coupon? _emptyCouponInstance;

  static Coupon emptyCoupon() => _emptyCouponInstance ??= Coupon(
        couponId: "",
        clientId: "",
        name: "",
        type: CouponType.universal,
        validFrom: IntDate.fromDate(DateTime.now()),
        validTo: IntDate.fromDate(DateTime.now()),
        blocked: true,
      );

  static Reservation? _emptyReservationInstance;

  static Reservation emptyReservation() => _emptyReservationInstance ??= Reservation(
        reservationId: "",
        clientId: "",
        name: "",
        loyaltyMode: LoyaltyMode.countSpentMoney,
        blocked: true,
      );

  static ReservationForDashboard? _emptyReservationForDashboard;

  static ReservationForDashboard emptyReservationForDashboard() =>
      _emptyReservationForDashboard ??= ReservationForDashboard(
        reservationId: "",
        reservationSlotId: "",
        reservationDateId: "",
        reservationName: "",
        slotName: "",
        dateTimeFrom: DateTime.now(),
        dateTimeTo: DateTime.now(),
        userId: "",
        color: Palette.transparent,
      );

  static ReservationSlot? _emptyReservationSlotInstance;

  static ReservationSlot emptyReservationSlot() => _emptyReservationSlotInstance ??= ReservationSlot(
        reservationSlotId: "",
        clientId: "",
        name: "",
        reservationId: "",
        blocked: true,
      );

  static UserOrder? _emptyUserOrderInstance;

  static UserOrder emptyUserOrder() => _emptyUserOrderInstance ??= UserOrder(
        orderId: "",
        offerId: "",
        clientId: "",
        userId: "",
        userCardId: "",
        status: ProductOrderStatus.created,
        deliveryType: DeliveryType.delivery,
        userNickname: "",
        createdAt: DateTime.now(),
      );
}

// eof

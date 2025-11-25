import "package:core_flutter/core_dart.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "card/cards.dart";
import "card/cards_api.dart";
import "card/cards_hive.dart";
import "coupon/coupons.dart";
import "coupon/coupons_api.dart";
import "coupon/coupons_hive.dart";
import "leaflet/leaflet_detail.dart";
import "leaflet/leaflet_detail_api.dart";
import "leaflet/leaflet_detail_hive.dart";
import "leaflet/leaflet_overview.dart";
import "leaflet/leaflet_overview_api.dart";
import "leaflet/leaflet_overview_hive.dart";
import "location/location.dart";
import "location/location_api.dart";
import "location/location_hive.dart";
import "order/item.api.dart";
import "order/item.dart";
import "order/offers.dart";
import "order/offers_api.dart";
import "order/order.dart";
import "order/order_api.dart";
import "order/orders.dart";
import "order/orders_api.dart";
import "program/programs.dart";
import "program/programs_api.dart";
import "program/programs_hive.dart";
import "reservation/reservation_dates.dart";
import "reservation/reservation_dates_api.dart";
import "reservation/reservations.dart";
import "reservation/reservations_api.dart";
import "reservation/user_reservations.dart";
import "reservation/user_reservations_api.dart";
import "user/user_address.dart";
import "user/user_address_api.dart";
import "user/user_cards.dart";
import "user/user_cards_api.dart";
import "user/user_cards_hive.dart";

final localCardsRepository = Provider<CardsRepository>(
  (ref) => HiveCardsRepository(),
);

final remoteCardsRepository = Provider<CardsRepository>(
  (ref) => ApiCardsRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final localUserCardsRepository = Provider<UserCardsRepository>(
  (ref) => HiveUserCardsRepository(),
);

final remoteUserCardsRepository = Provider<UserCardsRepository>(
  (ref) => ApiUserCardsRepository(),
);

/*
final localUserCardDetailRepository = Provider<UserCardRepository>(
  (ref) => HiveUserCardRepository(),
);

final remoteUserCardDetailRepository = Provider<UserCardRepository>(
  (ref) => ApiUserCardRepository(),
);
*/

final remoteUserAddressesRepository = Provider<UserAddressRepository>(
  (ref) => ApiUserAddressRepository(),
);

final localProgramsRepository = Provider<ProgramsRepository>(
  (ref) => HiveProgramsRepository(),
);

final remoteProgramsRepository = Provider<ProgramsRepository>(
  (ref) => ApiProgramsRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final localLocationRepository = Provider<LocationRepository>(
  (ref) => HiveLocationRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final remoteLocationRepository = Provider<LocationRepository>(
  (ref) => ApiLocationRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final localCouponsRepository = Provider<CouponsRepository>(
  (ref) => HiveCouponsRepository(),
);

final remoteCouponsRepository = Provider<CouponsRepository>(
  (ref) => ApiCouponsRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

/*
final localLeafletRepository = Provider<LeafletRepository>(
  (ref) => HiveLeafletRepository(),
);

final remoteLeafletRepository = Provider<LeafletRepository>(
  (ref) => ApiLeafletRepository(),
);
*/

final localLeafletOverviewRepository = Provider<LeafletOverviewRepository>(
  (ref) => HiveLeafletOverviewRepository(),
);

final remoteLeafletOverviewRepository = Provider<LeafletOverviewRepository>(
  (ref) => ApiLeafletOverviewRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final localLeafletDetailRepository = Provider<LeafletDetailRepository>(
  (ref) => HiveLeafletDetailRepository(),
);

final remoteLeafletDetailRepository = Provider<LeafletDetailRepository>(
  (ref) => ApiLeafletDetailRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final remoteUserReservationsRepository = Provider<UserReservationsRepository>(
  (ref) => ApiUserReservationsRepository(),
);

final remoteReservationsRepository = Provider<ReservationsRepository>(
  (ref) => ApiReservationsRepository(),
);

final remoteReservationDatesRepository = Provider<ReservationDatesRepository>(
  (ref) => ApiReservationDatesRepository(),
);

final remoteOrdersRepository = Provider<OrdersRepository>(
  (ref) => ApiOrdersRepository(),
);

final remoteOrderRepository = Provider<OrderRepository>(
  (ref) => ApiOrderRepository(),
);

final remoteOffersRepository = Provider<OffersRepository>(
  (ref) => ApiOffersRepository(),
);

final remoteItemRepository = Provider<ItemRepository>(
  (ref) => ApiItemRepository(),
);

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/providers.dart";
import "account/change_password.dart";
import "account/delete.dart";
import "account/register.dart";
import "card/cards.dart";
import "card/top_cards.dart";
import "client/client.dart";
import "leaflet/leaflet_detail.dart";
import "location/location.dart";
import "order/cart.dart";
import "order/item.dart";
import "order/offer.dart";
import "order/offers.dart";
import "order/orders.dart";
import "program/program.dart";
import "promo/category_coupons.dart";
import "promo/coupon.dart";
import "promo/promo.dart";
import "promo/take_coupon.dart";
import "reservation/reservation_dates.dart";
import "reservation/reservations.dart";
import "reservation/user_reservation_editor.dart";
import "reservation/user_reservations.dart";
import "user/address_editor.dart";
import "user/addresses.dart";
import "user/editor.dart";
import "user/scan_code.dart";
import "user/user_card.dart";
import "user/user_cards.dart";
import "user_location.dart";

final incrementProvider = StateProvider<int>((ref) => 0);

final startupLogic = StateNotifierProvider<StartupNotifier, StartupState>(
  (ref) => StartupNotifier(
    deviceRepository: ref.read(deviceRepository),
    userRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final loginLogic = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(
    deviceRepository: ref.read(deviceRepository),
    userRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final registerLogic = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(
    device: ref.read(deviceRepository),
    users: ref.read(remoteUserRepository),
  ),
);

final logoutLogic = StateNotifierProvider<LogoutNotifier, LogoutState>(
  (ref) => LogoutNotifier(
    deviceRepository: ref.read(deviceRepository),
    userRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final deleteAccountLogic = StateNotifierProvider<DeleteAccountNotifier, DeleteAccountState>(
  (ref) => DeleteAccountNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteUser: ref.read(remoteUserRepository),
  ),
);

final changePasswordLogic = StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>(
  (ref) => ChangePasswordNotifier(
    remoteUser: ref.read(remoteUserRepository),
  ),
);

final userLocationLogic = StateNotifierProvider<UserLocationNotifier, UserLocationState>(
  (ref) => UserLocationNotifier(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final userAddressesLogic = StateNotifierProvider<UserAddressesNotifier, UserAddressesState>(
  (ref) => UserAddressesNotifier(
    remoteAddresses: ref.read(remoteUserAddressesRepository),
  ),
);

final userAddressEditorLogic = StateNotifierProvider<UserAddressEditorNotifier, UserAddressState>(
  (ref) => UserAddressEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteAddresses: ref.read(remoteUserAddressesRepository),
  ),
);

final cardsLogic = StateNotifierProvider<CardsNotifier, CardsState>(
  (ref) => CardsNotifier(
    deviceRepository: ref.read(deviceRepository),
    localCardsRepository: ref.read(localCardsRepository),
    remoteCardsRepository: ref.read(remoteCardsRepository),
  ),
);

final topCardsLogic = StateNotifierProvider<TopCardsNotifier, TopCardsState>(
  (ref) => TopCardsNotifier(
    cardsRepository: ref.read(remoteCardsRepository),
  ),
);

final scanCodeLogic = StateNotifierProvider<ScanCodeNotifier, ScanQrCodeState>(
  (ref) => ScanCodeNotifier(
    userCards: ref.read(remoteUserCardsRepository),
    programs: ref.read(remoteProgramsRepository),
  ),
);

final userCardsLogic = StateNotifierProvider<UserCardsNotifier, UserCardsState>(
  (ref) => UserCardsNotifier(
    device: ref.read(deviceRepository),
    localUserCards: ref.read(localUserCardsRepository),
    remoteUserCards: ref.read(remoteUserCardsRepository),
  ),
);

final userCardLogic = StateNotifierProvider.family<UserCardNotifier, UserCardState, String>(
  (ref, userCardId) => UserCardNotifier(
    userCardId,
    localRepository: ref.read(localUserCardsRepository),
    remoteRepository: ref.read(remoteUserCardsRepository),
  ),
);

final userCardUpdateLogic = StateNotifierProvider.family<EditUserCardNotifier, EditUserCardState, UserCard>(
  (ref, userCard) => EditUserCardNotifier(
    userCard,
    remote: ref.read(remoteUserCardsRepository),
    local: ref.read(localUserCardsRepository),
  ),
);

final userLogic = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteUserRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final userUpdateLogic = StateNotifierProvider<UserUpdateNotifier, UserUpdateState>(
  (ref) => UserUpdateNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteUserRepository: ref.read(remoteUserRepository),
  ),
);

final programLogic = StateNotifierProvider.family<ProgramNotifier, ProgramState, String>(
  (ref, programId) => ProgramNotifier(
    programId,
    remoteRepository: ref.read(remoteProgramsRepository),
    localRepository: ref.read(localProgramsRepository),
  ),
);

final clientLogic = StateNotifierProvider.family<ClientNotifier, ClientState, String>(
  (ref, clientId) => ClientNotifier(
    clientId,
    remoteClients: ref.read(remoteClientRepository),
    localClients: ref.read(localClientRepository),
    remoteLocations: ref.read(remoteLocationRepository),
    localLocations: ref.read(localLocationRepository),
  ),
);

final promoLogic = StateNotifierProvider<PromoNotifier, PromoState>(
  (ref) => PromoNotifier(
    deviceRepository: ref.read(deviceRepository),
    localCoupons: ref.read(localCouponsRepository),
    remoteCoupons: ref.read(remoteCouponsRepository),
    localLeaflets: ref.read(localLeafletOverviewRepository),
    remoteLeaflets: ref.read(remoteLeafletOverviewRepository),
  ),
);

final couponsByCategoryLogic =
    StateNotifierProvider.family<CategoryCouponsNotifier, CategoryCouponsState, ClientCategory>(
  (ref, category) => CategoryCouponsNotifier(
    category,
    remoteRepository: ref.read(remoteCouponsRepository),
  ),
);

final couponLogic = StateNotifierProvider.family<CouponNotifier, CouponState, String>(
  (ref, userCouponId) => CouponNotifier(
    userCouponId,
    localCoupons: ref.read(localCouponsRepository),
    remoteCoupons: ref.read(remoteCouponsRepository),
  ),
);

final takeCouponLogic = StateNotifierProvider<TakeCouponNotifier, TakeCouponState>(
  (ref) => TakeCouponNotifier(
    repository: ref.read(remoteCouponsRepository),
  ),
);

final leafletDetailLogic = StateNotifierProvider.family<LeafletDetailNotifier, LeafletDetailState, String>(
  (ref, clientId) => LeafletDetailNotifier(
    clientId,
    localRepository: ref.read(localLeafletDetailRepository),
    remoteRepository: ref.read(remoteLeafletDetailRepository),
  ),
);

final locationLogic = StateNotifierProvider.family<LocationNotifier, LocationState, String>(
  (ref, locationId) => LocationNotifier(
    locationId,
    remoteRepository: ref.read(remoteLocationRepository),
    localRepository: ref.read(localLocationRepository),
  ),
);

final userReservationsLogic = StateNotifierProvider.family<UserReservationsNotifier, UserReservationsState, String>(
  (ref, clientId) => UserReservationsNotifier(
    clientId,
    userReservationsRepository: ref.read(remoteUserReservationsRepository),
  ),
);

final reservationEditorLogic = StateNotifierProvider<UserReservationEditorNotifier, UserReservationEditorState>(
  (ref) => UserReservationEditorNotifier(
    remoteRepository: ref.read(remoteUserReservationsRepository),
  ),
);

final reservationsLogic = StateNotifierProvider.family<ReservationsNotifier, ReservationsState, String>(
  (ref, clientId) => ReservationsNotifier(
    clientId,
    reservationsRepository: ref.read(remoteReservationsRepository),
  ),
);

final reservationDatesLogic = StateNotifierProvider<ReservationDatesNotifier, ReservationDatesState>(
  (ref) => ReservationDatesNotifier(
    reservationDatesRepository: ref.read(remoteReservationDatesRepository),
  ),
);

final ordersLogic = StateNotifierProvider.family<OrdersNotifier, OrdersState, String>(
  (ref, clientId) => OrdersNotifier(
    clientId,
    ordersRepository: ref.read(remoteOrdersRepository),
  ),
);

final offersLogic = StateNotifierProvider.family<OffersNotifier, OffersState, String>(
  (ref, clientId) => OffersNotifier(
    clientId,
    offersRepository: ref.read(remoteOffersRepository),
  ),
);

final offerLogic = StateNotifierProvider.family<OfferNotifier, OfferState, String>(
  (ref, offerId) => OfferNotifier(
    offerId,
    deviceRepository: ref.read(deviceRepository),
    offersRepository: ref.read(remoteOffersRepository),
  ),
);

final cartLogic = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(
    deviceRepository: ref.read(deviceRepository),
    offersRepository: ref.read(remoteOffersRepository),
    orderRepository: ref.read(remoteOrderRepository),
  ),
);

final itemLogic = StateNotifierProvider.family<ItemNotifier, ItemState, String>(
  (ref, itemId) => ItemNotifier(
    itemId,
    itemRepository: ref.read(remoteItemRepository),
  ),
);

// eof

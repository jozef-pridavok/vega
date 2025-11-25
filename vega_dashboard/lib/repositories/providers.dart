import "package:flutter_riverpod/flutter_riverpod.dart";

import "card.dart";
import "card_api.dart";
import "client.dart";
import "client_api.dart";
import "client_card.dart";
import "client_card_api.dart";
import "client_payment.dart";
import "client_payment_api.dart";
import "client_payment_provider.dart";
import "client_payment_provider_api.dart";
import "client_user_cards.dart";
import "client_user_cards_api.dart";
import "client_user_coupons.dart";
import "client_user_coupons_api.dart";
import "client_users.dart";
import "client_users_api.dart";
import "coupon.dart";
import "coupon_api.dart";
import "currency.dart";
import "currency_api.dart";
import "dashboard.dart";
import "dashboard_api.dart";
import "leaflet.dart";
import "leaflet_api.dart";
import "location.dart";
import "location_api.dart";
import "logs.dart";
import "logs_api.dart";
import "product_item.dart";
import "product_item_api.dart";
import "product_item_modification.dart";
import "product_item_modification_api.dart";
import "product_item_option.dart";
import "product_item_option_api.dart";
import "product_offer.dart";
import "product_offer_api.dart";
import "product_order.dart";
import "product_order_api.dart";
import "product_section.dart";
import "product_section_api.dart";
import "program.dart";
import "program_actions.dart";
import "program_actions_api.dart";
import "program_api.dart";
import "program_reward.dart";
import "program_reward_api.dart";
import "qr_tag.dart";
import "qr_tag_api.dart";
import "reservation.dart";
import "reservation_api.dart";
import "reservation_date.dart";
import "reservation_date_api.dart";
import "reservation_slot.dart";
import "reservation_slot_api.dart";
import "seller_client.dart";
import "seller_client_api.dart";
import "seller_payment.dart";
import "seller_payment_api.dart";
import "seller_template.dart";
import "seller_template_api.dart";
import "user.dart";
import "user_api.dart";
import "user_card.dart";
import "user_card_api.dart";

final logsRepository = Provider<LogsRepository>(
  (ref) => ApiLogsRepository(),
);

final dashboardRepository = Provider<DashboardRepository>(
  (ref) => ApiDashboardRepository(),
);

final clientRepository = Provider<ClientRepository>(
  (ref) => ApiClientRepository(),
);

final couponRepository = Provider<CouponRepository>(
  (ref) => ApiCouponRepository(),
);

final userCardRepository = Provider<UserCardRepository>(
  (ref) => ApiUserCardRepository(),
);

final programActionRepository = Provider<ProgramActionRepository>(
  (ref) => ApiProgramActionRepository(),
);

final leafletRepository = Provider<LeafletsRepository>(
  (ref) => ApiLeafletRepository(),
);

final locationRepository = Provider<LocationsRepository>(
  (ref) => ApiLocationRepository(),
);

final clientPaymentRepository = Provider<ClientPaymentRepository>(
  (ref) => ApiClientPaymentRepository(),
);

final sellerPaymentRepository = Provider<SellerPaymentRepository>(
  (ref) => ApiSellerPaymentRepository(),
);

final currencyRepository = Provider<CurrencyRepository>(
  (ref) => ApiCurrencyRepository(),
);

final cardRepository = Provider<CardRepository>(
  (ref) => ApiCardRepository(),
);

final programRepository = Provider<ProgramRepository>(
  (ref) => ApiProgramRepository(),
);

final rewardRepository = Provider<RewardRepository>(
  (ref) => ApiProgramRewardRepository(),
);

final reservationRepository = Provider<ReservationRepository>(
  (ref) => ApiReservationRepository(),
);

final reservationSlotRepository = Provider<ReservationSlotRepository>(
  (ref) => ApiReservationSlotRepository(),
);

final reservationDateRepository = Provider<ReservationDateRepository>(
  (ref) => ApiReservationDateRepository(),
);

final clientUserCardsRepository = Provider<ClientUserCardsRepository>(
  (ref) => ApiClientUserCardsRepository(),
);

final clientPaymentProvidersRepository = Provider<ClientPaymentProviderRepository>(
  (ref) => ApiClientPaymentProviderRepository(),
);

final sellerClientRepository = Provider<SellerClientRepository>(
  (ref) => ApiSellerClientRepository(),
);

final clientUserRepository = Provider<ClientUserRepository>(
  (ref) => ApiClientUserRepository(),
);

final clientCardRepository = Provider<ClientCardRepository>(
  (ref) => ApiClientCardRepository(),
);

final qrTagRepository = Provider<QrTagRepository>(
  (ref) => ApiQrTagRepository(),
);

final userRepository = Provider<UserRepository>(
  (ref) => ApiUserRepository(),
);

final productOfferRepository = Provider<ProductOfferRepository>(
  (ref) => ApiProductOfferRepository(),
);

final productSectionRepository = Provider<ProductSectionRepository>(
  (ref) => ApiProductSectionRepository(),
);

final productItemRepository = Provider<ProductItemRepository>(
  (ref) => ApiProductItemRepository(),
);

final productItemModificationRepository = Provider<ProductItemModificationRepository>(
  (ref) => ApiProductItemModificationRepository(),
);

final productItemOptionRepository = Provider<ProductItemOptionRepository>(
  (ref) => ApiProductItemOptionRepository(),
);

final productOrderRepository = Provider<ProductOrderRepository>(
  (ref) => ApiProductOrderRepository(),
);

final sellerTemplateRepository = Provider<SellerTemplateRepository>(
  (ref) => ApiSellerTemplateRepository(),
);

final clientUserCouponsRepository = Provider<ClientUserCouponsRepository>(
  (ref) => ApiClientUserCouponsRepository(),
);

// eof

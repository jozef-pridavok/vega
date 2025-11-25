import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_card.dart";
import "../repositories/client_payment.dart";
import "../repositories/coupon.dart";
import "../repositories/leaflet.dart";
import "../repositories/product_offer.dart";
import "../repositories/product_order.dart";
import "../repositories/program.dart";
import "../repositories/providers.dart";
import "../repositories/qr_tag.dart";
import "../repositories/reservation.dart";
import "../repositories/reservation_slot.dart";
import "../repositories/seller_client.dart";
import "../repositories/seller_payment.dart";
import "../screens/dialog.dart";
import "client_card_editor.dart";
import "client_card_patch.dart";
import "client_cards.dart";
import "client_payment_calc.dart";
import "client_payment_pay.dart";
import "client_payment_providers.dart";
import "client_payments.dart";
import "client_report.dart";
import "client_settings.dart";
import "client_user.dart";
import "client_user_card_transactions.dart";
import "client_user_cards.dart";
import "client_user_coupons.dart";
import "client_user_editor.dart";
import "client_user_patch.dart";
import "client_users.dart";
import "coupon_code.dart";
import "coupon_editor.dart";
import "coupon_patch.dart";
import "coupons.dart";
import "dashboard.dart";
import "developer_translations.dart";
import "issue_reward.dart";
import "issue_user_card.dart";
import "issue_user_coupon.dart";
import "leaflet_editor.dart";
import "leaflet_patch.dart";
import "leaflets.dart";
import "location_editor.dart";
import "location_patch.dart";
import "locations.dart";
import "logs.dart";
import "notifications.dart";
import "product_item_editor.dart";
import "product_item_modification_editor.dart";
import "product_item_modification_patch.dart";
import "product_item_modifications.dart";
import "product_item_option_editor.dart";
import "product_item_options.dart";
import "product_item_patch.dart";
import "product_items.dart";
import "product_offer_editor.dart";
import "product_offer_patch.dart";
import "product_offers.dart";
import "product_order_items.dart";
import "product_order_patch.dart";
import "product_orders.dart";
import "product_section_editor.dart";
import "product_section_patch.dart";
import "product_sections.dart";
import "program_action.dart";
import "program_editor.dart";
import "program_patch.dart";
import "program_reward_editor.dart";
import "program_reward_patch.dart";
import "program_rewards.dart";
import "programs.dart";
import "qr_tags.dart";
import "qr_tags_editor.dart";
import "redeem_user_coupon.dart";
import "reservation_date_editor.dart";
import "reservation_dates.dart";
import "reservation_editor.dart";
import "reservation_for_dashboard.dart";
import "reservation_patch.dart";
import "reservation_slot_editor.dart";
import "reservation_slot_patch.dart";
import "reservation_slots.dart";
import "reservations.dart";
import "seller_client.dart";
import "seller_client_editor.dart";
import "seller_client_patch.dart";
import "seller_client_payments.dart";
import "seller_payment_request.dart";
import "seller_payments.dart";
import "send_client_message_to_user.dart";

final waitDialogProvider = StateNotifierProvider<WaitDialogNotifier, String>(
  (ref) => WaitDialogNotifier(),
);

final logsLogic = StateNotifierProvider<LogsNotifier, LogsState>(
  (ref) => LogsNotifier(
    deviceRepository: ref.read(deviceRepository),
    logsRepository: ref.read(logsRepository),
  ),
);

final userLogic = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteUserRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final notificationsLogic = StateNotifierProvider<NotificationsNotifier, List<Notification>>(
  (ref) => NotificationsNotifier(),
);

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

final logoutLogic = StateNotifierProvider<LogoutNotifier, LogoutState>(
  (ref) => LogoutNotifier(
    deviceRepository: ref.read(deviceRepository),
    userRepository: ref.read(remoteUserRepository),
    clientRepository: ref.read(remoteClientRepository),
  ),
);

final userUpdateLogic = StateNotifierProvider<UserUpdateNotifier, UserUpdateState>(
  (ref) => UserUpdateNotifier(
    deviceRepository: ref.read(deviceRepository),
    remoteUserRepository: ref.read(remoteUserRepository),
  ),
);

final dashboardLogic = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(
    deviceRepository: ref.read(deviceRepository),
    dashboardRepository: ref.read(dashboardRepository),
  ),
);

final issueUserCardLogic = StateNotifierProvider<IssueUserCardNotifier, IssueUserCardState>(
  (ref) => IssueUserCardNotifier(userCardRepository: ref.read(userCardRepository)),
);

final issueCouponLogic = StateNotifierProvider<IssueCouponNotifier, IssueCouponState>(
  (ref) => IssueCouponNotifier(couponRepository: ref.read(couponRepository)),
);

final redeemCouponLogic = StateNotifierProvider<RedeemCouponNotifier, RedeemCouponState>(
  (ref) => RedeemCouponNotifier(couponRepository: ref.read(couponRepository)),
);

final programActionLogic = StateNotifierProvider<ProgramActionNotifier, ProgramActionState>(
  (ref) => ProgramActionNotifier(programAction: ref.read(programActionRepository)),
);

final issueRewardLogic = StateNotifierProvider<IssueRewardNotifier, IssueRewardState>(
  (ref) => IssueRewardNotifier(programAction: ref.read(programActionRepository)),
);

final activeCouponsLogic = StateNotifierProvider<CouponsNotifier, CouponsState>(
  (ref) => CouponsNotifier(
    CouponRepositoryFilter.active,
    couponRepository: ref.read(couponRepository),
  ),
);

final preparedCouponsLogic = StateNotifierProvider<CouponsNotifier, CouponsState>(
  (ref) => CouponsNotifier(
    CouponRepositoryFilter.prepared,
    couponRepository: ref.read(couponRepository),
  ),
);

final finishedCouponsLogic = StateNotifierProvider<CouponsNotifier, CouponsState>(
  (ref) => CouponsNotifier(
    CouponRepositoryFilter.finished,
    couponRepository: ref.read(couponRepository),
  ),
);

final archivedCouponsLogic = StateNotifierProvider<CouponsNotifier, CouponsState>(
  (ref) => CouponsNotifier(
    CouponRepositoryFilter.archived,
    couponRepository: ref.read(couponRepository),
  ),
);

final couponEditorLogic = StateNotifierProvider<CouponEditorNotifier, CouponEditorState>(
  (ref) => CouponEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    couponRepository: ref.read(couponRepository),
  ),
);

final couponPatchLogic = StateNotifierProvider<CouponPatchNotifier, CouponPatchState>(
  (ref) => CouponPatchNotifier(
    couponRepository: ref.read(couponRepository),
  ),
);

final leafletEditorLogic = StateNotifierProvider<LeafletEditorNotifier, LeafletEditorState>(
  (ref) => LeafletEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    leafletRepository: ref.read(leafletRepository),
  ),
);

final leafletPatchLogic = StateNotifierProvider<LeafletPatchNotifier, LeafletPatchState>(
  (ref) => LeafletPatchNotifier(
    deviceRepository: ref.read(deviceRepository),
    leafletRepository: ref.read(leafletRepository),
  ),
);

final activeLeafletsLogic = StateNotifierProvider<LeafletsNotifier, LeafletsState>(
  (ref) => LeafletsNotifier(
    LeafletRepositoryFilter.active,
    leafletRepository: ref.read(leafletRepository),
  ),
);

final preparedLeafletsLogic = StateNotifierProvider<LeafletsNotifier, LeafletsState>(
  (ref) => LeafletsNotifier(
    LeafletRepositoryFilter.prepared,
    leafletRepository: ref.read(leafletRepository),
  ),
);

final finishedLeafletsLogic = StateNotifierProvider<LeafletsNotifier, LeafletsState>(
  (ref) => LeafletsNotifier(
    LeafletRepositoryFilter.finished,
    leafletRepository: ref.read(leafletRepository),
  ),
);

final couponCodesGeneratorLogic = StateNotifierProvider<CouponCodesGeneratorNotifier, CouponCodesGeneratorState>(
  (ref) => CouponCodesGeneratorNotifier(),
);

final locationsLogic = StateNotifierProvider<LocationsNotifier, LocationsState>(
  (ref) => LocationsNotifier(
    locationRepository: ref.read(locationRepository),
  ),
);

final locationEditorLogic = StateNotifierProvider<LocationEditorNotifier, LocationEditorState>(
  (ref) => LocationEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    locationRepository: ref.read(locationRepository),
  ),
);

final locationPatchLogic = StateNotifierProvider<LocationPatchNotifier, LocationPatchState>(
  (ref) => LocationPatchNotifier(
    locationRepository: ref.read(locationRepository),
  ),
);

final clientSettingsLogic = StateNotifierProvider<ClientSettingsNotifier, ClientSettingsState>(
  (ref) => ClientSettingsNotifier(
    clientRepository: ref.read(clientRepository),
  ),
);

final clientPaymentsUnpaid = StateNotifierProvider<ClientPaymentsNotifier, ClientPaymentsState>(
  (ref) => ClientPaymentsNotifier(
    ClientPaymentRepositoryFilter.unpaid,
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final clientPaymentsLastThreeMonthsLogic = StateNotifierProvider<ClientPaymentsNotifier, ClientPaymentsState>(
  (ref) => ClientPaymentsNotifier(
    ClientPaymentRepositoryFilter.lastThreeMonths,
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final clientPaymentsLastYearLogic = StateNotifierProvider<ClientPaymentsNotifier, ClientPaymentsState>(
  (ref) => ClientPaymentsNotifier(
    ClientPaymentRepositoryFilter.lastYear,
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final clientPaymentCalcLogic = StateNotifierProvider<ClientPaymentCalcNotifier, ClientPaymentCalcState>(
  (ref) => ClientPaymentCalcNotifier(
    currencyRepository: ref.read(currencyRepository),
  ),
);

final clientPaymentLogic = StateNotifierProvider<ClientPaymentNotifier, ClientPaymentState>(
  (ref) => ClientPaymentNotifier(
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final sellerPaymentsLastThreeMonthsLogic = StateNotifierProvider<SellerPaymentsNotifier, SellerPaymentsState>(
  (ref) => SellerPaymentsNotifier(
    SellerPaymentRepositoryFilter.lastThreeMonths,
    paymentRepository: ref.read(sellerPaymentRepository),
  ),
);

final sellerPaymentsLastYearLogic = StateNotifierProvider<SellerPaymentsNotifier, SellerPaymentsState>(
  (ref) => SellerPaymentsNotifier(
    SellerPaymentRepositoryFilter.lastYear,
    paymentRepository: ref.read(sellerPaymentRepository),
  ),
);

final sellerPaymentsUnpaidLogic = StateNotifierProvider<SellerPaymentsNotifier, SellerPaymentsState>(
  (ref) => SellerPaymentsNotifier(
    SellerPaymentRepositoryFilter.onlyUnpaid,
    paymentRepository: ref.read(sellerPaymentRepository),
  ),
);

final sellerPaymentsReadyForRequestLogic =
    StateNotifierProvider<SellerClientPaymentsNotifier, SellerClientPaymentsState>(
  (ref) => SellerClientPaymentsNotifier(
    SellerPaymentRepositoryClientFilter.onlyReadyForRequest,
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final sellerPaymentsWaitingForClientLogic =
    StateNotifierProvider<SellerClientPaymentsNotifier, SellerClientPaymentsState>(
  (ref) => SellerClientPaymentsNotifier(
    SellerPaymentRepositoryClientFilter.onlyWaitingForClient,
    paymentRepository: ref.read(clientPaymentRepository),
  ),
);

final sellerPaymentRequestLogic = StateNotifierProvider<SellerPaymentRequestNotifier, SellerPaymentRequestState>(
  (ref) => SellerPaymentRequestNotifier(
    paymentRepository: ref.read(sellerPaymentRepository),
  ),
);

final activeProgramsLogic = StateNotifierProvider<ProgramsNotifier, ProgramsState>(
  (ref) => ProgramsNotifier(
    ProgramRepositoryFilter.active,
    programRepository: ref.read(programRepository),
  ),
);

final preparedProgramsLogic = StateNotifierProvider<ProgramsNotifier, ProgramsState>(
  (ref) => ProgramsNotifier(
    ProgramRepositoryFilter.prepared,
    programRepository: ref.read(programRepository),
  ),
);

final finishedProgramsLogic = StateNotifierProvider<ProgramsNotifier, ProgramsState>(
  (ref) => ProgramsNotifier(
    ProgramRepositoryFilter.finished,
    programRepository: ref.read(programRepository),
  ),
);

final archivedProgramsLogic = StateNotifierProvider<ProgramsNotifier, ProgramsState>(
  (ref) => ProgramsNotifier(
    ProgramRepositoryFilter.archived,
    programRepository: ref.read(programRepository),
  ),
);

final programEditorLogic = StateNotifierProvider<ProgramEditorNotifier, ProgramEditorState>(
  (ref) => ProgramEditorNotifier(
    programRepository: ref.read(programRepository),
    deviceRepository: ref.read(deviceRepository),
  ),
);

final programPatchLogic = StateNotifierProvider<ProgramPatchNotifier, ProgramPatchState>(
  (ref) => ProgramPatchNotifier(
    programRepository: ref.read(programRepository),
  ),
);

final rewardsLogic = StateNotifierProvider.family<RewardsNotifier, RewardsState, Program>(
  (ref, program) => RewardsNotifier(
    program,
    rewardRepository: ref.read(rewardRepository),
  ),
);

final rewardEditorLogic = StateNotifierProvider<RewardEditorNotifier, RewardEditorState>(
  (ref) => RewardEditorNotifier(
    rewardRepository: ref.read(rewardRepository),
  ),
);

final rewardPatchLogic = StateNotifierProvider<RewardPatchNotifier, RewardPatchState>(
  (ref) => RewardPatchNotifier(
    repository: ref.read(rewardRepository),
  ),
);

final activeReservationsLogic = StateNotifierProvider<ReservationsNotifier, ReservationsState>(
  (ref) => ReservationsNotifier(
    ReservationRepositoryFilter.active,
    reservationRepository: ref.read(reservationRepository),
  ),
);

final archivedReservationsLogic = StateNotifierProvider<ReservationsNotifier, ReservationsState>(
  (ref) => ReservationsNotifier(
    ReservationRepositoryFilter.archived,
    reservationRepository: ref.read(reservationRepository),
  ),
);

final reservationEditorLogic = StateNotifierProvider<ReservationEditorNotifier, ReservationEditorState>(
  (ref) => ReservationEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    reservationRepository: ref.read(reservationRepository),
  ),
);

final reservationPatchLogic = StateNotifierProvider<ReservationPatchNotifier, ReservationPatchState>(
  (ref) => ReservationPatchNotifier(
    reservationRepository: ref.read(reservationRepository),
  ),
);

final reservationForDashboardLogic =
    StateNotifierProvider<ReservationForDashboardNotifier, ReservationForDashboardState>(
  (ref) => ReservationForDashboardNotifier(
    dates: ref.read(reservationDateRepository),
  ),
);

final activeReservationsSlotLogic = StateNotifierProvider<ReservationSlotsNotifier, ReservationSlotsState>(
  (ref) => ReservationSlotsNotifier(
    ReservationSlotRepositoryFilter.active,
    slotRepository: ref.read(reservationSlotRepository),
  ),
);

final archivedReservationsSlotLogic = StateNotifierProvider<ReservationSlotsNotifier, ReservationSlotsState>(
  (ref) => ReservationSlotsNotifier(
    ReservationSlotRepositoryFilter.archived,
    slotRepository: ref.read(reservationSlotRepository),
  ),
);

final reservationSlotEditorLogic = StateNotifierProvider<ReservationSlotEditorNotifier, ReservationSlotEditorState>(
  (ref) => ReservationSlotEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    reservationSlotRepository: ref.read(reservationSlotRepository),
  ),
);

final slotPatchLogic = StateNotifierProvider<ReservationSlotPatchNotifier, ReservationSlotPatchState>(
  (ref) => ReservationSlotPatchNotifier(
    reservationSlotRepository: ref.read(reservationSlotRepository),
  ),
);

final reservationDatesLogic = StateNotifierProvider<ReservationDatesNotifier, ReservationDatesState>(
  (ref) => ReservationDatesNotifier(
    //reservationRepository: ref.read(reservationRepository),
    //slotRepository: ref.read(reservationSlotRepository),
    dateRepository: ref.read(reservationDateRepository),
  ),
);

final reservationDateEditorLogic = StateNotifierProvider<ReservationDateEditorNotifier, ReservationDateEditorState>(
  (ref) => ReservationDateEditorNotifier(
    dateRepository: ref.read(reservationDateRepository),
  ),
);

final clientUserCardsLogic = StateNotifierProvider<ClientUserCardsNotifier, ClientUserCardsState>(
  (ref) => ClientUserCardsNotifier(
    userCardsRepository: ref.read(clientUserCardsRepository),
  ),
);

final sendMessageToUserLogic = StateNotifierProvider<SendClientMessageToUserNotifier, SentClientMessageToUserState>(
  (ref) => SendClientMessageToUserNotifier(
    userRepository: ref.read(userRepository),
  ),
);

/*
final sendMessageToClientLogic = StateNotifierProvider<SendMessageToUserNotifier, SendMessageToUserState>(
  (ref) => SendClientMessageToUserNotifier(
    userRepository: ref.read(userRepository),
  ),
);
*/

final clientUserCardTransactionsLogic =
    StateNotifierProvider<ClientUserCardTransactionsNotifier, ClientUserCardTransactionsState>(
  (ref) => ClientUserCardTransactionsNotifier(
    userCardsRepository: ref.read(clientUserCardsRepository),
  ),
);

final clientPaymentProvidersLogic = StateNotifierProvider<ClientPaymentProvidersNotifier, ClientPaymentProvidersState>(
  (ref) => ClientPaymentProvidersNotifier(
    providerRepository: ref.read(clientPaymentProvidersRepository),
  ),
);

final activeSellerClientsLogic = StateNotifierProvider<SellerClientsNotifier, SellerClientsState>(
  (ref) => SellerClientsNotifier(
    SellerClientRepositoryFilter.active,
    sellerClientRepository: ref.read(sellerClientRepository),
  ),
);

final archivedSellerClientsLogic = StateNotifierProvider<SellerClientsNotifier, SellerClientsState>(
  (ref) => SellerClientsNotifier(
    SellerClientRepositoryFilter.archived,
    sellerClientRepository: ref.read(sellerClientRepository),
  ),
);

final sellerClientEditorLogic = StateNotifierProvider<SellerClientEditorNotifier, SellerClientEditorState>(
  (ref) => SellerClientEditorNotifier(
    sellerClientRepository: ref.read(sellerClientRepository),
    sellerTemplateRepository: ref.read(sellerTemplateRepository),
  ),
);

final sellerClientPatchLogic = StateNotifierProvider<SellerClientPatchNotifier, SellerClientPatchState>(
  (ref) => SellerClientPatchNotifier(
    sellerClientRepository: ref.read(sellerClientRepository),
  ),
);

final clientUsersLogic = StateNotifierProvider.family<ClientUsersNotifier, ClientUsersState, String>(
  (ref, clientId) => ClientUsersNotifier(
    clientId,
    clientUsersRepository: ref.read(clientUserRepository),
  ),
);

final clientUserLogic = StateNotifierProvider.family<ClientUserNotifier, ClientUserState, String>(
  (ref, userId) => ClientUserNotifier(
    userId,
    userRepository: ref.read(userRepository),
    clientUsersRepository: ref.read(clientUserRepository),
  ),
);

final clientUserEditorLogic = StateNotifierProvider<ClientUserEditorNotifier, ClientUserEditorState>(
  (ref) => ClientUserEditorNotifier(
    clientUserRepository: ref.read(clientUserRepository),
  ),
);

final clientUserPatchLogic = StateNotifierProvider<ClientUserPatchNotifier, ClientUserPatchState>(
  (ref) => ClientUserPatchNotifier(
    clientUserRepository: ref.read(clientUserRepository),
  ),
);

final activeClientCardsLogic = StateNotifierProvider<ClientCardsNotifier, ClientCardsState>(
  (ref) => ClientCardsNotifier(
    ClientCardRepositoryFilter.active,
    clientCardRepository: ref.read(clientCardRepository),
  ),
);

final archivedClientCardsLogic = StateNotifierProvider<ClientCardsNotifier, ClientCardsState>(
  (ref) => ClientCardsNotifier(
    ClientCardRepositoryFilter.archived,
    clientCardRepository: ref.read(clientCardRepository),
  ),
);

final clientCardEditorLogic = StateNotifierProvider<ClientCardEditorNotifier, ClientCardEditorState>(
  (ref) => ClientCardEditorNotifier(
    deviceRepository: ref.read(deviceRepository),
    cardRepository: ref.read(clientCardRepository),
  ),
);

final clientCardPatchLogic = StateNotifierProvider<ClientCardPatchNotifier, ClientCardPatchState>(
  (ref) => ClientCardPatchNotifier(
    repository: ref.read(clientCardRepository),
  ),
);

final unusedQrTagsLogic = StateNotifierProvider<QrTagsNotifier, QrTagsState>(
  (ref) => QrTagsNotifier(
    QrTagRepositoryFilter.unused,
    qrTagRepository: ref.read(qrTagRepository),
  ),
);

final usedQrTagsLogic = StateNotifierProvider<QrTagsNotifier, QrTagsState>(
  (ref) => QrTagsNotifier(
    QrTagRepositoryFilter.used,
    qrTagRepository: ref.read(qrTagRepository),
  ),
);

final printQrTagsLogic = StateNotifierProvider<QrTagsEditorNotifier, QrTagsEditorState>(
  (ref) => QrTagsEditorNotifier(
    qrTagRepository: ref.read(qrTagRepository),
  ),
);

final activeProductOffersLogic = StateNotifierProvider<ProductOffersNotifier, ProductOffersState>(
  (ref) => ProductOffersNotifier(
    ProductOfferRepositoryFilter.active,
    productOfferRepository: ref.read(productOfferRepository),
  ),
);

final archivedProductOffersLogic = StateNotifierProvider<ProductOffersNotifier, ProductOffersState>(
  (ref) => ProductOffersNotifier(
    ProductOfferRepositoryFilter.archived,
    productOfferRepository: ref.read(productOfferRepository),
  ),
);

final productOfferPatchLogic = StateNotifierProvider<ProductOfferPatchNotifier, ProductOfferPatchState>(
  (ref) => ProductOfferPatchNotifier(
    productOfferRepository: ref.read(productOfferRepository),
  ),
);

final productOfferEditorLogic = StateNotifierProvider<ProductOfferEditorNotifier, ProductOfferEditorState>(
  (ref) => ProductOfferEditorNotifier(
    productOfferRepository: ref.read(productOfferRepository),
  ),
);

final productItemsLogic = StateNotifierProvider<ProductItemsNotifier, ProductItemsState>(
  (ref) => ProductItemsNotifier(
    productItemRepository: ref.read(productItemRepository),
  ),
);

final productItemPatchLogic = StateNotifierProvider<ProductItemPatchNotifier, ProductItemPatchState>(
  (ref) => ProductItemPatchNotifier(
    productItemRepository: ref.read(productItemRepository),
  ),
);

final productItemEditorLogic = StateNotifierProvider<ProductItemEditorNotifier, ProductItemEditorState>(
  (ref) => ProductItemEditorNotifier(
    productItemRepository: ref.read(productItemRepository),
  ),
);

final productSectionPatchLogic = StateNotifierProvider<ProductSectionPatchNotifier, ProductSectionPatchState>(
  (ref) => ProductSectionPatchNotifier(
    productSectionRepository: ref.read(productSectionRepository),
  ),
);

final productSectionsLogic = StateNotifierProvider<ProductSectionsNotifier, ProductSectionsState>(
  (ref) => ProductSectionsNotifier(
    productSectionRepository: ref.read(productSectionRepository),
  ),
);

final productSectionEditorLogic = StateNotifierProvider<ProductSectionEditorNotifier, ProductSectionEditorState>(
  (ref) => ProductSectionEditorNotifier(
    productSectionRepository: ref.read(productSectionRepository),
  ),
);

final productItemModificationsLogic =
    StateNotifierProvider.family<ProductItemModificationsNotifier, ProductItemModificationsState, String>(
  (ref, productItemId) => ProductItemModificationsNotifier(
    productItemId,
    productItemModificationRepository: ref.read(productItemModificationRepository),
  ),
);

final productItemOptionsLogic =
    StateNotifierProvider.family<ProductItemOptionsNotifier, ProductItemOptionsState, String>(
  (ref, productItemId) => ProductItemOptionsNotifier(
    productItemId,
    productItemOptionRepository: ref.read(productItemOptionRepository),
  ),
);

final productItemModificationEditorLogic =
    StateNotifierProvider<ProductItemModificationEditorNotifier, ProductItemModificationEditorState>(
  (ref) => ProductItemModificationEditorNotifier(
    modificationRepository: ref.read(productItemModificationRepository),
  ),
);

final productItemModificationPatchLogic =
    StateNotifierProvider<ProductItemModificationPatchNotifier, ProductItemModificationPatchState>(
  (ref) => ProductItemModificationPatchNotifier(
    productItemModificationRepository: ref.read(productItemModificationRepository),
  ),
);

final productItemOptionEditorLogic =
    StateNotifierProvider<ProductItemOptionEditorNotifier, ProductItemOptionEditorState>(
  (ref) => ProductItemOptionEditorNotifier(
    productItemOptionRepository: ref.read(productItemOptionRepository),
  ),
);

final activeProductOrdersLogic = StateNotifierProvider<ProductOrdersNotifier, ProductOrdersState>(
  (ref) => ProductOrdersNotifier(
    ProductOrderRepositoryFilter.active,
    productOrderRepository: ref.read(productOrderRepository),
  ),
);

final closedProductOrdersLogic = StateNotifierProvider<ProductOrdersNotifier, ProductOrdersState>(
  (ref) => ProductOrdersNotifier(
    ProductOrderRepositoryFilter.closed,
    productOrderRepository: ref.read(productOrderRepository),
  ),
);

final productOrderPatchLogic = StateNotifierProvider<ProductOrderPatchNotifier, ProductOrderPatchState>(
  (ref) => ProductOrderPatchNotifier(
    productOrderRepository: ref.read(productOrderRepository),
  ),
);

final productOrderItemsLogic = StateNotifierProvider.family<ProductOrderItemsNotifier, ProductOrderItemsState, String>(
  (ref, productOrderId) => ProductOrderItemsNotifier(
    productOrderId,
    productOrderRepository: ref.read(productOrderRepository),
  ),
);

final clientUserCouponsLogic = StateNotifierProvider<ClientUserCouponsNotifier, ClientUserCouponsState>(
  (ref) => ClientUserCouponsNotifier(
    userCouponsRepository: ref.read(clientUserCouponsRepository),
  ),
);

final translationsLogic = StateNotifierProvider<TranslationNotifier, TranslationState>(
  (ref) => TranslationNotifier(),
);

final clientReportLogic = StateNotifierProvider.family<ClientReportNotifier, ClientReportState, String>(
  (ref, setId) => ClientReportNotifier(
    setId,
    deviceRepository: ref.read(deviceRepository),
    dashboardRepository: ref.read(dashboardRepository),
  ),
);

// eof

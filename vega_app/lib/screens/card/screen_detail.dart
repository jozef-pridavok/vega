import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../caches.dart";
import "../../states/providers.dart";
import "../../states/user/user_card.dart";
import "../../strings.dart";
import "../../widgets/user_card_code.dart";
import "../../widgets/user_card_logo.dart";
import "../screen_app.dart";
import "button_more.dart";
import "screen_card_code.dart";
import "screen_client.dart";
import "screen_edit_note.dart";
import "screen_orders.dart";
import "screen_program.dart";
import "screen_reservations.dart";
import "screen_user_coupon.dart";

class DetailScreen extends AppScreen {
  final UserCard userCard;
  const DetailScreen(this.userCard, {super.key});

  @override
  createState() => _DetailState();
}

class _DetailState extends AppScreenState<DetailScreen> {
  String get _userCardId => widget.userCard.userCardId;
  String? get _clientId => widget.userCard.clientId;

  //@override
  //void initState() {
  //  super.initState();
  //  Future.microtask(() => ref.read(userCardLogic(_userCardId).notifier).load());
  //}

  //@override
  //void onGainedVisibility() {
  //  super.onGainedVisibility();
  //  delayedStateRefresh(() => ref.read(userCardLogic(_userCardId).notifier).refreshOnBackground());
  //}

  @override
  bool onPushNotification(PushNotification message) {
    if (message["clientId"] != _clientId) return false;
    final action = message.actionType;
    if (action == null || !action.isCardDetail) return super.onPushNotification(message);
    if (action.isUserCoupon || action.isProgram) ref.read(userCardLogic(_userCardId).notifier).refreshOnBackground();
    if (action.isReservation && _clientId != null) ref.read(userReservationsLogic(_clientId!).notifier).refresh();
    return true;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final userCard = cast<UserCardLoaded>(ref.watch(userCardLogic(_userCardId)))?.userCard ?? widget.userCard;
    return VegaAppBar(
      title: userCard.name,
      titleWidget: SizedBox(
        height: kToolbarHeight,
        child: Padding(padding: const EdgeInsets.all(8.0), child: UserCardLogo(userCard, shadow: false)),
      ),
      actions: [
        MoreButton(userCard),
        const MoleculeItemHorizontalSpace(), // HalfHorizontalSpacer(),
      ],
    );
  }

  String _orderStatusText(BuildContext context, UserCard userCard) {
    final lang = context.locale.languageCode;
    final lastProductOrder = userCard.lastProductOrder;
    if (lastProductOrder == null) return "";

    final date = formatDate(lang, lastProductOrder.createdAt);

    final currency = lastProductOrder.totalPriceCurrency;
    final price = lastProductOrder.totalPrice;
    String? formattedPrice;
    if (currency != null && price != null) {
      formattedPrice = currency.formatSymbol(price);
      return "$date - $formattedPrice - ${lastProductOrder.status.localizedName}";
    }

    return date ?? lastProductOrder.status.localizedName;
  }

  @override
  Widget buildBody(BuildContext context) {
    final userCard = cast<UserCardLoaded>(ref.watch(userCardLogic(_userCardId)))?.userCard ?? widget.userCard;
    final hasCoupons = userCard.userCoupons?.isNotEmpty ?? false;
    final hasPrograms = userCard.programs?.isNotEmpty ?? false;
    final hasReservations = (userCard.eligibleReservationsCount ?? 0) > 0;
    final hasOffers = (userCard.offersCount ?? 0) > 0;
    final hasOrders = (userCard.ordersCount ?? 0) > 0;
    final clientName = userCard.clientName ?? userCard.cardName ?? userCard.name ?? "";
    return PullToRefresh(
      onRefresh: () {
        ref.read(userCardLogic(_userCardId).notifier).refresh();
        if (_clientId != null) ref.read(offersLogic(_clientId!).notifier).refresh();
      },
      child: ListView(
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.slideUp(CardCodeScreen(userCard)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeCardLoyaltyBig(
                title: userCard.name,
                label: userCard.number?.formattedVegaNumber() ?? "",
                labelAlignment: CrossAxisAlignment.center,
                image: UserCardCode(userCard),
                imageAspectRatio: 3,
                showSeparator: true,
              ),
            ),
          ),
          const MoleculeItemSpace(),
          if (hasCoupons) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(header: LangKeys.cardDetailRowYourCoupons.tr()),
            ),
            _Coupons(userCard),
            const MoleculeItemSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(header: LangKeys.cardDetailRowOtherServices.tr()),
            ),
          ],
          if (hasPrograms) ...[
            ...userCard.programs!.map((e) => _ProgramRow(userCard: userCard, program: e)),
          ],
          if (hasReservations) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(
                icon: AtomIcons.reservation,
                title: LangKeys.cardDetailRowReservations.tr(),
                label: LangKeys.labelUserReservations.plural(userCard.reservationsCount ?? 0),
                actionIcon: AtomIcons.itemDetail,
                onAction: () => context.push(ReservationsScreen(userCard)),
              ),
            ),
          ],
          if (F().isInternal && (hasOrders || hasOffers))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(
                icon: AtomIcons.shoppingCard,
                title: LangKeys.cardDetailRowOffers.tr(),
                //label: userCard != null ? _orderStatusText(context, userCard) : "-",
                label: _orderStatusText(context, userCard),
                actionIcon: AtomIcons.itemDetail,
                onAction: () => context.push(OrdersScreen(userCard)),
              ),
            ),
          //
          if (_clientId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(
                icon: AtomIcons.about,
                title: clientName,
                label: LangKeys.cardDetailRowContact.tr(),
                actionIcon: AtomIcons.itemDetail,
                onAction: () => context.push(ClientInfoScreen(_clientId!, clientName)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
            child: MoleculeItemBasic(
              icon: AtomIcons.list,
              title: LangKeys.cardDetailRowNotes.tr(),
              label: (userCard.notes?.isEmpty ?? true) ? LangKeys.labelNoNotes.tr() : userCard.notes,
              actionIcon: AtomIcons.itemDetail,
              onAction: () {
                context.push(EditNoteScreen(userCard, false));
              },
            ),
          ),
          if (F().isDev && kDebugMode) ...[
            const MoleculeItemSpace(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemSeparator(),
            ),
            const MoleculeItemSpace(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(header: "Debug"),
            ),
            GestureDetector(
              onTap: () => {
                Clipboard.setData(ClipboardData(text: _userCardId)),
                ref.read(toastLogic.notifier).info("UserCardId copied to clipboard"),
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                child: MoleculeItemBasic(icon: AtomIcons.about, title: "User card id", label: userCard.userCardId),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(icon: AtomIcons.about, title: "Card id", label: userCard.cardId),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(icon: AtomIcons.about, title: "Client id", label: userCard.clientId),
            ),
            if (_clientId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                child: MoleculeItemBasic(icon: AtomIcons.about, title: "Client name", label: clientName),
              ),
            ],
            GestureDetector(
              onTap: () => {
                Clipboard.setData(ClipboardData(text: userCard.logo ?? "")),
                toastInfo("Logo url copied to clipboard"),
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                child: MoleculeItemBasic(icon: AtomIcons.about, title: "Logo", label: userCard.logo),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemBasic(
                  icon: AtomIcons.about,
                  title: "Card type",
                  label: "${userCard.codeType.name} (${userCard.codeType.code})"),
            ),
          ]
        ],
      ),
    );
  }
}

class _Coupons extends StatelessWidget {
  final UserCard userCard;

  const _Coupons(this.userCard);

  @override
  Widget build(BuildContext context) {
    //final userCard =
    //    cast<UserCardLoaded>(ref.watch(userCardLogic(this.userCard.userCardId)))?.userCard ?? this.userCard;
    final userCoupons = userCard.userCoupons ?? [];
    final count = userCoupons.length;
    if (count == 0) return const SizedBox();
    return PageViewEx(
      physics: vegaScrollPhysic,
      padEnds: count == 1,
      controller: PageController(viewportFraction: count == 1 ? 0.9 : 0.8),
      children: userCoupons.map((e) => _Coupon(userCard, e)).toList(),
    );
  }
}

class _Coupon extends StatelessWidget {
  final UserCard userCard;
  final UserCouponOnUserCard userCoupon;

  const _Coupon(this.userCard, this.userCoupon);

  @override
  Widget build(BuildContext context) {
    final image = userCoupon.image;
    final imageBh = userCoupon.imageBh;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(UserCouponScreen(userCard, userCoupon)),
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: MoleculeCardLoyaltyMedium(
          //key: ValueKey(userCoupon.userCouponId),
          label: userCoupon.name,
          image: image != null
              ? CachedImage(
                  config: Caches.couponImage,
                  url: image,
                  blurHash: imageBh,
                  errorBuilder: (_, __, ___) => SvgAsset.logo(),
                )
              : null,
          logo: UserCardLogo(userCard, shadow: false),
        ),
      ),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  final UserCard userCard;
  final ProgramOnUserCard program;

  const _ProgramRow({required this.userCard, required this.program});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: MoleculeItemBasic(
        title: program.name,
        label: formatAmount(context.locale.languageCode, program.plural, program.userPoints, digits: program.digits),
        icon: AtomIcons.heart,
        actionIcon: AtomIcons.itemDetail,
        onAction: () => context.push(ProgramScreen(userCard, program)),
      ),
    );
  }
}

// eof

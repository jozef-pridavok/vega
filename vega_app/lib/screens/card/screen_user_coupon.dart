import "dart:async";

import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/card/screen_order_confirm.dart";

import "../../caches.dart";
import "../../states/promo/coupon.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/coupon_detail.dart";
import "../../widgets/user_card_logo.dart";
import "../../widgets/user_identity.dart";
import "../screen_app.dart";
import "screen_new_reservation.dart";

class UserCouponScreen extends AppScreen {
  final UserCard userCard;
  final UserCouponOnUserCard userCoupon;
  const UserCouponScreen(this.userCard, this.userCoupon, {super.key});

  @override
  createState() => _UserCouponState();
}

class _UserCouponState extends AppScreenState<UserCouponScreen> {
  UserCard get _userCard => widget.userCard;
  UserCouponOnUserCard get _userCoupon => widget.userCoupon;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(couponLogic(_userCoupon.couponId).notifier).load());
  }

  @override
  bool onPushNotification(PushNotification message) {
    final action = message.actionType;
    if (action == ActionType.userCouponRedeemed && message["clientId"] == _userCard.clientId) {
      hapticHeavy();
      ref.read(userCardLogic(_userCard.userCardId).notifier).refresh();
      return true;
    }
    return super.onPushNotification(message);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: _userCoupon.name);

  void _listenToCouponLogic(BuildContext context) {
    ref.listen<CouponState>(couponLogic(_userCoupon.couponId), (previous, next) {
      if (next is CouponLoaded) {
        final coupon = next.coupon;
        // TODO: logika - pozri nižšie
        if (coupon.type == CouponType.reservation) {
          ref.read(reservationsLogic(coupon.clientId).notifier).load();
        }
        if (coupon.type == CouponType.product) {
          //ref.read(reservationsLogic(coupon.clientId).notifier).load();
        }
        //setState(() => _userCoupon.coupon = next.coupon);
      } else if (next is CouponFailed) {
        delayedStateRefresh(() => ref.read(couponLogic(_userCoupon.couponId).notifier).reset());
        //Future.delayed(stateRefreshDuration, () => ref.read(couponLogic(_userCoupon.couponId).notifier).reset());
        //ref.read(toastLogic.notifier).warning(LangKeys.operationFailed.tr());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToCouponLogic(context);
    final image = _userCoupon.image;
    final imageBh = _userCoupon.imageBh;
    final description = _userCoupon.description;
    final coupon = cast<CouponLoaded>(ref.watch(couponLogic(_userCoupon.couponId)))?.coupon;
    return PullToRefresh(
      onRefresh: () => ref.read(couponLogic(_userCoupon.couponId).notifier).refresh(),
      child: SingleChildScrollView(
        //physics: vegaScrollPhysic,
        child: Padding(
          padding: const EdgeInsets.only(
            left: moleculeScreenPadding,
            right: moleculeScreenPadding,
            top: moleculeScreenPadding / 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MoleculeCardLoyaltyMedium(
                label: _userCoupon.name,
                image: image != null ? CachedImage(config: Caches.couponImage, url: image, blurHash: imageBh) : null,
                logo: UserCardLogo(_userCard, shadow: false),
              ),
              const MoleculeItemSpace(),
              if (description?.isNotEmpty ?? false) ...[
                _userCoupon.description.text,
                const MoleculeItemSpace(),
              ],
              _ProcessCoupon(_userCard, _userCoupon),
              const MoleculeItemSpace(),
              if (coupon != null) ...[
                CouponDetailWidget(coupon),
                //_Detail(userCard: _userCard, userCoupon: _userCoupon),
                const MoleculeItemSpace(),
              ],
              if (F().isDev && kDebugMode) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemSeparator(),
                ),
                const MoleculeItemSpace(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemTitle(header: "Debug"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemBasic(
                    title: "User coupon id",
                    label: _userCoupon.userCouponId,
                    onAction: () => Clipboard.setData(ClipboardData(text: _userCoupon.userCouponId)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemBasic(
                    title: "Coupon id",
                    label: _userCoupon.couponId,
                    onAction: () => Clipboard.setData(ClipboardData(text: _userCoupon.couponId)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemBasic(
                    title: "Valid to",
                    label: _userCoupon.validTo?.toDate().toIso8601String() ?? "forever",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                  child: MoleculeItemBasic(title: "Code", label: _userCoupon.code ?? "-"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessCoupon extends ConsumerWidget {
  final UserCard userCard;
  final UserCouponOnUserCard userCoupon;
  //String get _clientId => userCard.clientId!;
  String get _couponId => userCoupon.couponId;

  const _ProcessCoupon(this.userCard, this.userCoupon);

  void _showReservation(BuildContext context, WidgetRef ref, Coupon coupon) {
    //ref.read(couponLogic(_couponId).notifier).reset();
    ref.read(reservationsLogic(coupon.clientId).notifier).load();
    context.popPush(EditReservationScreen(
      clientId: coupon.clientId,
      cardId: userCard.cardId,
      userCardId: userCard.userCardId,
      userCouponId: userCoupon.userCouponId,
      coupon: coupon,
    ));
  }

  void _showOrder(BuildContext context, WidgetRef ref, Coupon coupon) {
    context.popPush(const OrderConfirmScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final coupon = ref.watch(couponLogic(_couponId));
    //final reservations = ref.watch(reservationsLogic(_clientId));
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonRedeemCoupon.tr(),
      onTap: () {
        if (userCoupon.type == CouponType.reservation) {
          // TODO: logika toto je asi zbytocne, lebo couponLogic by mal byť loaded
          final coupon = cast<CouponLoaded>(ref.read(couponLogic(_couponId)));
          if (coupon != null)
            _showReservation(context, ref, coupon.coupon);
          else {
            ref.read(couponLogic(_couponId).notifier).load();
          }
          return;
        } else if (userCoupon.type == CouponType.product) {
          final coupon = cast<CouponLoaded>(ref.read(couponLogic(_couponId)));
          if (coupon != null)
            _showOrder(context, ref, coupon.coupon);
          else {
            ref.read(couponLogic(_couponId).notifier).load();
          }
          return;
        }
        _showCouponCode(context, ref);
      },
    );
  }

  Future<void> _showCouponCode(BuildContext context, WidgetRef ref) async {
    final userCouponId = userCoupon.userCouponId;
    final qrCode = F().qrBuilder.generateUserCouponIdentity(userCouponId);
    await modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenCouponIdTitle.tr()),
          const MoleculeItemSpace(),
          Consumer(builder: (context, ref, _) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrCodeWidget(value: qrCode),
                ),
              ),
            );
          }),
          const MoleculeItemSpace(),
          LangKeys.screenCouponIdDescription.tr().text.alignCenter.color(ref.scheme.content),
          const MoleculeItemSpace(),
        ],
      ),
    );
    unawaited(ref.read(userCardLogic(userCard.userCardId).notifier).refresh());
  }
}

// eof

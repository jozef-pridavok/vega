import "dart:convert";

import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/promo/screen_coupon_on_map.dart";
import "package:vega_app/states/promo/take_coupon.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";
import "package:vega_app/widgets/coupon.dart";

import "../../states/promo/coupon.dart";
import "../../widgets/coupon_detail.dart";
import "../card/screen_detail.dart";
import "../screen_app.dart";

class CouponDetail extends AppScreen {
  final Coupon coupon;

  const CouponDetail(this.coupon, {super.key});

  @override
  createState() => _CouponDetailState();
}

class _CouponDetailState extends AppScreenState<CouponDetail> {
  late Coupon _coupon;
  String get _couponId => _coupon.couponId;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: _coupon.name);

  @override
  void initState() {
    super.initState();
    _coupon = widget.coupon;
    Future.microtask(() => ref.read(takeCouponLogic.notifier).reset());
  }

  void _listenToCouponLogic(BuildContext context) {
    ref.listen<CouponState>(couponLogic(_couponId), (previous, next) {
      if (next is CouponLoaded) {
        setState(() => _coupon = next.coupon);
      } else if (next is CouponFailed) {
        Future.delayed(stateRefreshDuration, () => ref.read(couponLogic(_couponId).notifier).reset());
        ref.read(toastLogic.notifier).warning(LangKeys.operationFailed.tr());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToCouponLogic(context);
    final description = _coupon.description;
    final location = formatAddress(_coupon.locationAddressLine1, _coupon.locationAddressLine2, _coupon.locationCity);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(couponLogic(_couponId).notifier).refresh(),
        child: ListView(
          //physics: vegaScrollPhysic,
          children: [
            CouponWidget(_coupon),
            const MoleculeItemSpace(),
            if (description?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                child: description.text.color(ref.scheme.content),
              ),
              const MoleculeItemSpace(),
            ],
            CouponDetailWidget(_coupon),
            const MoleculeItemSpace(),
            if (location != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                child: MoleculeItemBasic(
                  title: LangKeys.screenCouponOpenMap.tr(),
                  label: location,
                  actionIcon: AtomIcons.location,
                  onAction: () => _coupon.locationId != null ? context.push(CouponOnMapScreen(_coupon)) : null,
                ),
              ),
              const MoleculeItemSpace(),
            ],
            if (true && F().isDev && kDebugMode) ...[
              const MoleculeItemSeparator(),
              const MoleculeItemSpace(),
              const MoleculeItemTitle(header: "Debug"),
              MoleculeItemBasic(
                title: "Coupon id",
                label: _coupon.couponId,
                onAction: () => Clipboard.setData(ClipboardData(text: _coupon.couponId)),
              ),
              MoleculeItemBasic(
                title: "Client name",
                label: _coupon.clientName ?? "null",
                onAction: () => Clipboard.setData(ClipboardData(text: _coupon.clientId)),
              ),
              MoleculeItemBasic(title: "Type", label: _coupon.type.localizedName),
              MoleculeItemBasic(title: "Code", label: _coupon.code ?? "-"),
              if (_coupon.type == CouponType.array)
                MoleculeItemBasic(
                  title: "Codes (${_coupon.codes?.length ?? 0})",
                  label: _coupon.codes?.join(", ") ?? "-",
                ),
              if (_coupon.type == CouponType.reservation) ...[
                MoleculeItemBasic(
                  title: "Reservation id",
                  label: _coupon.reservation?.reservationId ?? "null",
                ),
                MoleculeItemBasic(
                  title: "Slot id",
                  label: _coupon.reservation?.slotId ?? "null",
                ),
                MoleculeItemBasic(
                  title: "Days",
                  label: _coupon.reservation?.days.map((e) => e.code).join(", ") ?? "null",
                ),
                MoleculeItemBasic(
                  title: "Time",
                  label:
                      "From: ${_coupon.reservation?.from.toString() ?? "null"}, To: ${_coupon.reservation?.to.toString() ?? "null"}",
                ),
              ],
              if (_coupon.type == CouponType.product)
                MoleculeItemBasic(
                  title: "Meta",
                  label: jsonEncode(_coupon.order?.toMap()),
                ),
              const MoleculeItemSpace(),
            ],
            _TakeCouponButton(_coupon),
            _ShowUserCardDetailButton(_coupon),
            const MoleculeItemSpace(),
            //],
          ],
        ),
      ),
    );
  }
}

class _TakeCouponButton extends ConsumerWidget {
  final Coupon coupon;

  const _TakeCouponButton(this.coupon);

  void _listenToTakeCouponState(BuildContext context, WidgetRef ref) {
    ref.listen(takeCouponLogic, (previous, next) {
      if (next is TakeCouponFailed) {
        final error = next.error;
        Future.delayed(stateRefreshDuration, () => ref.read(takeCouponLogic.notifier).reset());
        final messageKeys = {
          errorMoreObjectsFound: LangKeys.toastUserAlreadyHasCoupon,
          errorObjectNotFound: LangKeys.toastCouponNotFound,
        };
        ref.read(toastLogic.notifier).error((messageKeys[error] ?? LangKeys.operationFailed).tr());
      }
      if (next is TakeCouponSucceed) {
        //Future.delayed(stateRefreshDuration, () => ref.read(takeCouponLogic.notifier).reset());
        //ref.read(takeCouponLogic.notifier).reset();
        final userCardId = next.userCardId;
        ref.read(userCardsLogic.notifier).refresh();
        ref.read(userCardLogic(userCardId).notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToTakeCouponState(context, ref);
    final takeCouponState = ref.watch(takeCouponLogic);
    if (takeCouponState is TakeCouponSucceed) return const SizedBox();
    return MoleculeActionButton(
      title: LangKeys.screenCouponButtonTake.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: takeCouponState.buttonState,
      onPressed: () => ref.read(takeCouponLogic.notifier).take(coupon),
    );
  }
}

class _ShowUserCardDetailButton extends ConsumerWidget {
  final Coupon coupon;

  const _ShowUserCardDetailButton(this.coupon);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final takeCoupon = cast<TakeCouponSucceed>(ref.watch(takeCouponLogic));
    if (takeCoupon == null) return const SizedBox();
    final userCardId = takeCoupon.userCardId;
    //final userCard = ref.watch(userCardLogic(userCardId));
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonShowCard.tr(),
      //successTitle: LangKeys.operationSuccessful.tr(),
      //failTitle: LangKeys.operationFailed.tr(),
      //buttonState: userCard.buttonState,
      //onPressed: userCard is UserCardLoaded ? () => context.replace(DetailScreen(userCard.userCard)) : null,
      onTap: () {
        final userCard = UserCard(
          userCardId: userCardId,
          clientId: coupon.clientId,
          userId: "",
          codeType: CodeType.ean13,
        );
        context.replace(DetailScreen(userCard));
      },
    );
  }
}
// eof

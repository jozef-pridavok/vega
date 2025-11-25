import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/location/location.dart";
import "package:vega_app/states/providers.dart";

import "../../states/promo/promo.dart";
import "../../strings.dart";
import "../../widgets/coupon.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";

class CouponsOnMapScreen extends AppScreen {
  const CouponsOnMapScreen({super.key});

  @override
  bool get useSafeArea => false;

  @override
  createState() => _CouponsOnMapState();
}

class _CouponsOnMapState extends AppScreenState<CouponsOnMapScreen> {
  @override
  void initState() {
    super.initState();
    //Future.microtask(() => ref.read(locationLogic(_locationId).notifier).load());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenTitleCoupons.tr());

  @override
  Widget buildBody(BuildContext context) {
    final status = ref.watch(promoLogic);
    if (status is PromoSucceed) {
      return const _Body();
    } else if (status is LocationFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          promoLogic,
          onReload: () => ref.read(promoLogic.notifier).refresh(),
        ),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  Coupon? _coupon;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(promoLogic) as PromoSucceed;
    return Stack(
      children: [
        MapWidget<Coupon>(
          objects: status.nearestCoupons,
          getGeoPoint: (coupon) => cast<Coupon>(coupon)?.locationPoint ?? GeoPoint.invalid(),
          selectedObject: _coupon,
          onMarkerTap: (object) {
            setState(() => _coupon = _coupon == object ? null : object);
          },
        ),
        if (_coupon != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(moleculeScreenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CouponWidget(_coupon!, key: ValueKey(_coupon!)), const MoleculeItemSpace()],
              ),
            ),
          ),
      ],
    );
  }
}

// eof

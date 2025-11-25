import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/location/location.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/widgets/coupon.dart";

import "../../widgets/status_error.dart";
import "../screen_app.dart";

class CouponOnMapScreen extends AppScreen {
  final Coupon coupon;

  const CouponOnMapScreen(this.coupon, {super.key});

  @override
  bool get useSafeArea => false;

  @override
  createState() => _CouponOnMapState();
}

class _CouponOnMapState extends AppScreenState<CouponOnMapScreen> {
  Coupon get _coupon => widget.coupon;
  String get _locationId => _coupon.locationId!;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(locationLogic(_locationId).notifier).load());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: _coupon.name);

  @override
  Widget buildBody(BuildContext context) {
    final status = ref.watch(locationLogic(_locationId));
    if (status is LocationSucceed) {
      return _Body(_coupon);
    } else if (status is LocationFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          locationLogic(_locationId),
          onReload: () => ref.read(locationLogic(_locationId).notifier).refresh(),
        ),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _Body extends ConsumerStatefulWidget {
  final Coupon coupon;

  const _Body(this.coupon);

  @override
  createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  Coupon get _coupon => widget.coupon;
  String get _locationId => _coupon.locationId!;

  bool _showCoupon = true;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(locationLogic(_locationId)) as LocationSucceed;
    return Stack(
      children: [
        MapWidget<Coupon>(
          objects: [_coupon],
          getGeoPoint: (coupon) => status.location.geoPoint,
          selectedObject: _showCoupon ? _coupon : null,
          onMarkerTap: (object) => setState(() => _showCoupon = !_showCoupon),
        ),
        if (_showCoupon)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(moleculeScreenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CouponWidget(_coupon), const MoleculeItemSpace()],
              ),
            ),
          ),
      ],
    );
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "coupon_image.dart";
import "coupon_logo.dart";

class CouponWidget extends StatelessWidget {
  final Coupon coupon;

  const CouponWidget(this.coupon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding / 2),
      child: MoleculeCardLoyaltyMedium(
        key: ValueKey(coupon.couponId),
        label: coupon.name,
        image: CouponImage(coupon),
        logo: CouponLogo(coupon, shadow: false),
      ),
    );
  }
}

// eof

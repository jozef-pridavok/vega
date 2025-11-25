import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../caches.dart";

class CouponLogo extends ConsumerWidget {
  final Coupon coupon;
  final bool shadow;

  const CouponLogo(this.coupon, {this.shadow = true, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculusCardGrid1(
      backgroundColor: ref.scheme.paperCard,
      shadow: shadow,
      imageUrl: coupon.clientLogo ?? "",
      imageCache: Caches.clientLogo,
    );
  }
}

// eof

import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/caches.dart";

class CouponImage extends ConsumerWidget {
  final Coupon coupon;

  const CouponImage(this.coupon, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = coupon.image;
    final imageBh = coupon.imageBh;
    return image == null
        ? Container(color: ref.scheme.content10)
        : CachedImage(
            config: Caches.couponImage,
            url: image,
            blurHash: imageBh,
            errorBuilder: (_, __, ___) => Container(
              color: ref.scheme.content10,
              child: false && F().isDev
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Clipboard.setData(ClipboardData(text: image)),
                      child: image.micro.alignCenter.color(ref.scheme.content),
                    )
                  : SvgAsset.logo(),
            ),
          );
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../strings.dart";

class CouponDetailWidget extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailWidget(this.coupon, {super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.languageCode;
    final discount = coupon.discount;
    final validTo = formatIntDate(lang, coupon.validTo);
    final location = formatAddress(coupon.locationAddressLine1, coupon.locationAddressLine2, coupon.locationCity);
    final reservationDays = coupon.reservation?.days.map((e) => e.localizedName).join(", ");
    final reservationTimes = formatIntDayMinutesRange(lang, coupon.reservation?.from, coupon.reservation?.to);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MoleculeCardLoyaltyBig(
        title: LangKeys.screenCouponDetail.tr(),
        showSeparator: true,
        child: Column(
          children: [
            if (discount?.isNotEmpty ?? false) ...[
              MoleculeTableRow(label: LangKeys.screenCouponDiscount.tr(), value: discount),
              const SizedBox(height: 16),
            ],
            if (validTo?.isNotEmpty ?? false) ...[
              MoleculeTableRow(label: LangKeys.screenCouponValidTo.tr(), value: validTo),
              const SizedBox(height: 16),
            ],
            if (location?.isNotEmpty ?? false) ...[
              MoleculeTableRow(label: LangKeys.screenCouponAddress.tr(), value: location),
              const SizedBox(height: 16),
            ],
            if (coupon.type == CouponType.reservation) ...{
              if (reservationDays?.isNotEmpty ?? false) ...[
                MoleculeTableRow(label: LangKeys.labelDays.tr(), value: reservationDays),
                const SizedBox(height: 16),
              ],
              if (reservationTimes?.isNotEmpty ?? false) ...[
                MoleculeTableRow(label: LangKeys.labelTime.tr(), value: reservationTimes),
                const SizedBox(height: 16),
              ],
            }
          ],
        ),
      ),
    );
  }
}

// eof

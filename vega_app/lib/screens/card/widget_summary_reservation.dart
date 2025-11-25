import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../strings.dart";

class UserReservationSummaryWidget extends ConsumerWidget {
  final UserReservation reservation;

  const UserReservationSummaryWidget({super.key, required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.languageCode;
    final currency = reservation.reservationSlotCurrency;
    final price = reservation.reservationSlotPrice;
    final discount = reservation.reservationSlotDiscount ?? reservation.reservationDiscount;
    int? discountedPrice;
    if (discount != null && price != null) {
      discountedPrice = (price * (1.0 - (discount / 100.0))).round();
    }
    final dateTime = reservation.reservationDateFrom.toLocal();
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paper),
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoleculeItemTitle(header: reservation.reservationSlotName),
          const SizedBox(height: 16),
          const MoleculeItemSeparator(),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.labelState.tr(),
            value: reservation.reservationDateStatus.localizedName,
          ),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.screenReservationLocation.tr(),
            value: formatAddress(
                reservation.locationAddressLine1, reservation.locationAddressLine2, reservation.locationCity),
          ),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.labelDate.tr(),
            value: formatDate(context.languageCode, dateTime),
          ),
          const SizedBox(height: 16),
          MoleculeTableRow(
            label: LangKeys.labelTime.tr(),
            value: formatTime(context.languageCode, dateTime),
          ),
          if (currency != null && price != null) ...[
            const SizedBox(height: 16),
            MoleculeTableRow(
              label: LangKeys.labelPrice.tr(),
              value: currency.formatSymbol(price, lang),
            ),
            if (discountedPrice != null) ...[
              const SizedBox(height: 16),
              MoleculeTableRow(
                // localize to slovak, english, spanish
                label: LangKeys.labelCreditDiscount.tr(),
                value: "-${NumberFormat.percentPattern().format(discount! / 100.0)}",
              ),
              const SizedBox(height: 16),
              MoleculeTableRow(
                label: LangKeys.labelCreditDiscountPrice.tr(),
                value: currency.formatSymbol(discountedPrice, lang),
              ),
            ],
          ],
          if ((reservation.reservationSlotDescription?.isNotEmpty) ?? false) ...[
            const SizedBox(height: 16),
            reservation.reservationSlotDescription!.label.alignLeft.color(ref.scheme.content),
          ],
        ],
      ),
    );
  }
}

// eof

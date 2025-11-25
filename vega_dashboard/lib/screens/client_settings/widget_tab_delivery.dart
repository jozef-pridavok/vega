import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../strings.dart";
import "screen_settings.dart";

extension DeliveryClientSettings on ClientSettingsScreenState {
  Widget buildDeliveryDefaultLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[3],
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LangKeys.labelClientFeeForDelivery.tr().label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildDeliveryFee()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LangKeys.labelClientFeeForPickup.tr().label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildPickupFee()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryFee() {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      controller: deliveryFeeController,
      suffixText: currency.code,
      maxLines: 1,
      validator: (val) => (val?.isNotEmpty ?? false) && !((currency.parse(val, locale) ?? -1) > currency.expand(1))
          ? LangKeys.validationPriceInvalidFormat.tr()
          : null,
      onChanged: (value) => notifyUnsaved(notificationTag),
    );
  }

  Widget _buildPickupFee() {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      controller: pickupFeeController,
      suffixText: currency.code,
      maxLines: 1,
      validator: (val) => (val?.isNotEmpty ?? false) && !((currency.parse(val, locale) ?? -1) > currency.expand(1))
          ? LangKeys.validationPriceInvalidFormat.tr()
          : null,
      onChanged: (value) => notifyUnsaved(notificationTag),
    );
  }
}

// eof

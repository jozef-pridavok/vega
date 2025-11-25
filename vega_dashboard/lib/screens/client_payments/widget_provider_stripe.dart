import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_stripe/flutter_stripe.dart";
import "package:vega_dashboard/screens/screen_app.dart";

import "../../states/client_payment_calc.dart";
import "../../states/client_payment_pay.dart";
import "../../states/providers.dart";
import "../../strings.dart";

class StripeWidget extends ConsumerStatefulWidget {
  final ClientPaymentProvider provider;
  final ClientPayment payment;

  StripeWidget(this.provider, this.payment, {super.key});

  @override
  createState() => _StripeWidgetState();
}

class _StripeWidgetState extends ConsumerState<StripeWidget> {
  final _controller = CardEditController();

  ClientPaymentProvider get _provider => widget.provider;
  ClientPayment get _payment => widget.payment;

  @override
  void initState() {
    super.initState();
    Future(() => ref.read(clientPaymentCalcLogic.notifier).calculate(_provider, _payment));
  }

  @override
  Widget build(BuildContext context) {
    final calcStatus = ref.watch(clientPaymentCalcLogic);
    Price? totalPrice;
    if ((calcStatus is ClientPaymentSucceed) && calcStatus.isSame(_provider, _payment)) {
      totalPrice = Price(calcStatus.totalPriceInProviderCurrency, _provider.currency);
    }
    final payState = ref.watch(clientPaymentLogic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MoleculeItemTitle(header: LangKeys.sectionEnterYourCardDetails.tr()),
        const MoleculeItemSpace(),
        LangKeys.labelWeDoNotStoreYourCard.tr().text,
        const MoleculeItemSpace(),
        CardField(controller: _controller),
        const MoleculeItemSpace(),
        Center(
          child: MoleculeActionButton(
            title: LangKeys.buttonPay.tr(),
            successTitle: LangKeys.operationSuccessful.tr(),
            failTitle: LangKeys.operationFailed.tr(),
            buttonState: payState.buttonState,
            onPressed: () {
              if (totalPrice == null) {
                toastError(LangKeys.clientPaymentLabelProviderNeedToCalculate.tr());
                return;
              }
              ref.read(clientPaymentLogic.notifier).pay(_provider, _payment, totalPrice);
            },
          ),
        )
      ],
    );
  }
}

// eof

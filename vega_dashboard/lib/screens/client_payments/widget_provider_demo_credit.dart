import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/screens/screen_app.dart";

import "../../states/client_payment_calc.dart";
import "../../states/client_payment_pay.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";

class DemoCreditWidget extends ConsumerStatefulWidget {
  final ClientPaymentProvider provider;
  final ClientPayment payment;

  DemoCreditWidget(this.provider, this.payment, {super.key});

  @override
  createState() => _CreditWidgetState();
}

class _CreditWidgetState extends ConsumerState<DemoCreditWidget> {
  ClientPaymentProvider get _provider => widget.provider;
  ClientPayment get _payment => widget.payment;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userLogic.notifier).refresh());
    Future(() => ref.read(clientPaymentCalcLogic.notifier).calculate(_provider, _payment));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userLogic);
    final lang = context.languageCode;
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    final currency = client.licenseCurrency;
    final credit = client.demoCredit;
    final calcStatus = ref.watch(clientPaymentCalcLogic);
    Price? totalPrice;
    if ((calcStatus is ClientPaymentSucceed) && calcStatus.isSame(_provider, _payment)) {
      totalPrice = Price(calcStatus.totalPriceInProviderCurrency, _provider.currency);
    }
    final payState = ref.watch(clientPaymentLogic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MoleculeItemTitle(header: LangKeys.sectionPayByDemoCredit.tr()),
        const MoleculeItemSpace(),
        LangKeys.labelYourCredit.tr().text,
        const MoleculeItemSpace(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            currency.formatSymbol(credit, lang).h1.alignCenter,
            const SizedBox(width: 8),
            VegaRefreshButton(
              onPressed: () => ref.read(userLogic.notifier).refresh(),
              isRotating: ref.watch(userLogic) is UserLoading,
            ),
          ],
        ),
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

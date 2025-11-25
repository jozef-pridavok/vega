import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../enums/translated_client_payment_status.dart";
import "../../states/client_payment_calc.dart";
import "../../states/client_payment_pay.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "widget_provider_demo_credit.dart";
import "widget_provider_stripe.dart";

class ClientPaymentPayScreen extends VegaScreen {
  final List<ClientPaymentProvider> providers;
  final ClientPayment payment;
  const ClientPaymentPayScreen(this.providers, this.payment, {super.key});

  @override
  createState() => _ClientPaymentPayScreenState();
}

class _ClientPaymentPayScreenState extends VegaScreenState<ClientPaymentPayScreen> with SingleTickerProviderStateMixin {
  List<ClientPaymentProvider> get _providers => widget.providers;
  ClientPayment get _payment => widget.payment;

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: _providers.length, vsync: this);
    _controller.addListener(() => _onTabIndexChanged(_controller.index));
    Future.microtask(() {
      final payState = cast<ClientPaymentInProgress>(ref.read(clientPaymentLogic));
      if (payState != null) return;
      ref.read(clientPaymentLogic.notifier).reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClientPayment.tr();

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final locale = context.locale.languageCode;
    final isPaid = _payment.status == ClientPaymentStatus.paid;
    final isNotPaid = !isPaid;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: NestedScrollView(
        //physics: vegaScrollPhysic,
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Flexible(
                    child: MoleculeInput(
                      title: LangKeys.labelPeriod.tr(),
                      initialValue: formatIntMonth(locale, _payment.period),
                      readOnly: true,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Flexible(
                    child: MoleculeInput(
                      title: LangKeys.labelStatus.tr(),
                      initialValue: _payment.status.localizedName,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: const MoleculeItemSpace()),
            ...(_payment.items ?? {})
                .keys
                .map((key) {
                  final value = _payment.items![key];
                  String displayValue = value.toString();
                  if (value is JsonObject) {
                    final price = Price.tryFromMap(value);
                    if (price != null) displayValue = price.formatSymbol(locale);
                  }
                  return [
                    SliverToBoxAdapter(
                      child: MoleculeTableRow(label: key, value: displayValue),
                    ),
                    SliverToBoxAdapter(child: const MoleculeItemSpace()),
                  ];
                })
                .flattened
                .cast<Widget>(),
            if (isNotPaid)
              SliverToBoxAdapter(
                child: MoleculeTabs(
                  controller: _controller,
                  tabs: _providers.map((provider) => Tab(text: provider.name)).toList(),
                ),
              ),
          ];
        },
        body: isNotPaid
            ? TabBarView(
                controller: _controller,
                children: _providers.map((e) => _ProviderTab(e, _payment)).toList(),
              )
            : SizedBox(),
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ClientPaymentState>(clientPaymentLogic, (previous, next) {
      if (next is ClientPaymentFinished) {
        ref.read(clientPaymentLogic.notifier).reset();
        context.pop();
      } else if (next is ClientPaymentFailed) {
        toastError(next.error.message);
        Future.delayed(stateRefreshDuration, () => ref.read(clientPaymentLogic.notifier).reset());
      }
    });
  }

  void _onTabIndexChanged(int index) {}
}

class _ProviderTab extends ConsumerStatefulWidget {
  final ClientPaymentProvider provider;
  final ClientPayment payment;
  const _ProviderTab(this.provider, this.payment);

  @override
  createState() => _ProviderTabState();
}

class _ProviderTabState extends ConsumerState<_ProviderTab> {
  ClientPaymentProvider get _provider => widget.provider;
  ClientPayment get _payment => widget.payment;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientPaymentCalcLogic.notifier).calculate(_provider, _payment));
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final vegaPriceDisplay = _payment.currency.formatSymbol(_payment.totalPrice, locale);
    final fixedPrice = _provider.fixedPrice;
    final fixedPriceDisplay = fixedPrice != 0 ? _provider.currency.formatSymbol(fixedPrice, locale) : "";
    final percentage = _provider.percentage;
    final percentageDisplay = percentage != 0 ? _formatPercentage(locale) : "";

    final calcStatus = ref.watch(clientPaymentCalcLogic);

    final isCalculating = (calcStatus is ClientPaymentCalculating) && calcStatus.isSame(_provider, _payment);

    final infoMessage = isCalculating
        ? LangKeys.clientPaymentLabelProviderCalculating.tr()
        : LangKeys.clientPaymentLabelProviderNeedToCalculate.tr();

    final canRefresh = (calcStatus is ClientPaymentCalcInitial) ||
        (calcStatus is ClientPaymentCalcFailed) ||
        (calcStatus is ClientPaymentSucceed && !calcStatus.isSameCurrency);

    final totalPriceDisplay = (calcStatus is ClientPaymentSucceed) && calcStatus.isSame(_provider, _payment)
        ? calcStatus.formatBothPrice(locale)
        : infoMessage;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.sectionPaymentPricingBreakdown.tr()),
          const MoleculeItemSpace(),
          MoleculeTableRow(label: LangKeys.clientPaymentVegaPrice.tr(), value: vegaPriceDisplay),
          const MoleculeItemSpace(),
          if (fixedPriceDisplay.isNotEmpty) ...[
            MoleculeTableRow(label: LangKeys.clientPaymentLabelProviderFixedPrice.tr(), value: fixedPriceDisplay),
            const MoleculeItemSpace(),
          ],
          if (percentageDisplay.isNotEmpty) ...[
            MoleculeTableRow(
              label: LangKeys.clientPaymentLabelProviderPercentage.tr(args: [
                NumberFormat.decimalPercentPattern(locale: locale, decimalDigits: 2).format(percentage / 10000.0)
              ]),
              value: percentageDisplay,
            ),
            const MoleculeItemSpace(),
          ],
          MoleculeTableRow(
            label: LangKeys.labelTotalPrice.tr(),
            value: totalPriceDisplay,
            iconValue: canRefresh ? AtomIcons.refresh : null,
            onIconValueTap:
                canRefresh ? () => ref.read(clientPaymentCalcLogic.notifier).calculate(_provider, _payment) : null,
          ),
          _Provider(_provider, _payment),
        ],
      ),
    );
  }

  String _formatPercentage(String locale) {
    final percentage = _provider.percentage;
    final value = _payment.pricing * (percentage / 10000.0);
    return _payment.currency.formatSymbol(value.round(), locale);
  }
}

class _Provider extends ConsumerStatefulWidget {
  final ClientPaymentProvider provider;
  final ClientPayment payment;
  const _Provider(this.provider, this.payment);

  @override
  createState() => _ProviderState();
}

class _ProviderState extends ConsumerState<_Provider> {
  ClientPaymentProvider get _provider => widget.provider;
  ClientPayment get _payment => widget.payment;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientPaymentCalcLogic.notifier).calculate(_provider, _payment));
  }

  @override
  Widget build(BuildContext context) {
    final hasWidget = [ClientPaymentProviderType.stripe, ClientPaymentProviderType.demoCredit].contains(_provider.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasWidget) ...[
          const MoleculeItemSpace(),
          const MoleculeItemSeparator(),
          const MoleculeItemSpace(),
        ],
        if (_provider.type == ClientPaymentProviderType.stripe) StripeWidget(_provider, _payment),
        if (_provider.type == ClientPaymentProviderType.demoCredit) DemoCreditWidget(_provider, _payment),
        if (hasWidget) ...[
          const MoleculeItemSpace(),
        ],
      ],
    );
  }
}

// eof

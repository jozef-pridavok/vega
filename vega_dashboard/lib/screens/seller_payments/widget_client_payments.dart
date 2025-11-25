import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../enums/translated_client_payment_status.dart";
import "../../repositories/client_payment.dart";
import "../../states/providers.dart";
import "../../states/seller_client_payments.dart";
import "../../states/seller_payment_request.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

extension SellerPaymentRepositoryClientFilterLogic on SellerPaymentRepositoryClientFilter {
  static final _map = {
    SellerPaymentRepositoryClientFilter.onlyReadyForRequest: sellerPaymentsReadyForRequestLogic,
    SellerPaymentRepositoryClientFilter.onlyWaitingForClient: sellerPaymentsWaitingForClientLogic,
  };

  StateNotifierProvider<SellerClientPaymentsNotifier, SellerClientPaymentsState> get logic => _map[this]!;
}

class ClientPaymentsWidget extends ConsumerStatefulWidget {
  final SellerPaymentRepositoryClientFilter filter;
  ClientPaymentsWidget(this.filter, {super.key});

  @override
  createState() => _ClientPaymentsWidgetWidgetState();
}

class _ClientPaymentsWidgetWidgetState extends ConsumerState<ClientPaymentsWidget> {
  SellerPaymentRepositoryClientFilter get _filter => widget.filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(_filter.logic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    if (_filter == SellerPaymentRepositoryClientFilter.onlyReadyForRequest) {
      ref.listen(sellerPaymentRequestLogic, (previous, next) {
        if (next is SellerPaymentRequestSucceed)
          Future(() => ref.read(sellerPaymentsReadyForRequestLogic.notifier).reload());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final stateWidgetMap = <Type, Widget>{
      SellerClientPaymentsFailed: StateErrorWidget(
        _filter.logic,
        onReload: () => ref.read(_filter.logic.notifier).reload(),
      ),
      SellerClientPaymentsSucceed: _GridWidget(_filter),
      SellerClientPaymentsRefreshing: _GridWidget(_filter),
    };
    final state = ref.watch(_filter.logic);
    return stateWidgetMap[state.runtimeType] ?? const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final SellerPaymentRepositoryClientFilter filter;
  const _GridWidget(this.filter);

  static const _columnChecked = "checked";
  static const _columnPeriod = "period";
  static const _columnClient = "client";
  static const _columnClientStatus = "clientStatus";
  //static const _columnClientBasicFee = "clientBasicFee";
  //static const _columnClientActiveCards = "clientActiveCards";
  //static const _columnClientActiveCardsPrice = "clientActiveCardsPrice";
  //static const _columnClientTotalPrice = "clientTotalPrice";
  static const _columnClientPrice = "clientPrice";
  static const _columnYourEarnings = "yourEarnings";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(filter.logic) as SellerClientPaymentsSucceed;
    final payments = succeed.payments;
    return PullToRefresh(
      onRefresh: () => ref.read(filter.logic.notifier).reload(),
      child: DataGrid<ClientPayment>(
        rows: payments,
        columns: [
          if (filter == SellerPaymentRepositoryClientFilter.onlyReadyForRequest)
            DataGridColumn(name: _columnChecked, label: "", width: 40),
          DataGridColumn(name: _columnPeriod, label: LangKeys.columnPeriod.tr()),
          DataGridColumn(name: _columnClient, label: LangKeys.columnClient.tr()),
          DataGridColumn(name: _columnClientStatus, label: LangKeys.columnClientStatus.tr()),
          /*
          DataGridColumn(
            name: _columnClientBasicFee,
            label: LangKeys.columnPaymentBasicFee.tr(),
            alignment: Alignment.centerRight,
          ),
          DataGridColumn(
            name: _columnClientActiveCards,
            label: LangKeys.columnActiveCards.tr(),
            alignment: Alignment.centerRight,
          ),
          DataGridColumn(
            name: _columnClientActiveCardsPrice,
            label: LangKeys.columnActiveCardsPrice.tr(),
            alignment: Alignment.centerRight,
          ),
          DataGridColumn(
            name: _columnClientTotalPrice,
            label: LangKeys.columnTotal.tr(),
            alignment: Alignment.centerRight,
          ),
          */
          DataGridColumn(
              name: _columnClientPrice, label: LangKeys.columnClientPayment.tr(), alignment: Alignment.centerRight),
          DataGridColumn(
              name: _columnYourEarnings, label: LangKeys.columnYourEarnings.tr(), alignment: Alignment.centerRight),
        ],
        onBuildCell: (column, coupon) => _buildCell(context, ref, column, coupon),
        onRowTapUp: (column, data, details) => ref.read(filter.logic.notifier).toggle(data),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ClientPayment payment) {
    final locale = context.locale.languageCode;
    if (column == _columnChecked && filter == SellerPaymentRepositoryClientFilter.onlyReadyForRequest) {
      return VegaIcon(
        name: (ref.read(filter.logic) as SellerClientPaymentsSucceed).isSelected(payment)
            ? AtomIcons.checkboxOn
            : AtomIcons.checkboxOff,
      );
    }
    if (column == _columnPeriod) return formatIntMonth(locale, payment.period).text.color(ref.scheme.content);
    if (column == _columnClient) return (payment.clientName ?? "").text.color(ref.scheme.content);
    if (column == _columnClientStatus) return payment.status.localizedName.text.color(ref.scheme.content);
    if (column == _columnClientPrice) {
      final clientPrice = payment.currency.formatSymbol(payment.base, locale);
      return clientPrice.text.color(ref.scheme.content);
    }
    if (column == _columnYourEarnings) {
      final share = payment.sellerShare ?? 0;
      final earnings = ((payment.base + (payment.activeCards * payment.pricing)) * share / 10000.0).round();
      final yourEarnings = payment.currency.formatSymbol(
        earnings,
        locale,
      );
      final yourShare = formatBasisPoint(locale, payment.sellerShare ?? 0, decimalDigits: 2);
      return "$yourEarnings ($yourShare)".text.color(ref.scheme.content);
    }
    return "?".text.color(ref.scheme.content);
    /*
    final clientActiveCardsPrice = payment.currency.formatSymbol(payment.activeCards * payment.pricing, locale);
    final clientTotalPrice =
        payment.currency.formatSymbol(payment.base + (payment.activeCards * payment.pricing), locale);
    final yourEarnings = payment.currency.formatSymbol(
      ((payment.base + (payment.activeCards * payment.pricing)) * payment.sellerShare! / 10000.0).floor(),
      locale,
    );
    final yourShare = formatBasisPoint(locale, payment.sellerShare ?? 0, decimalDigits: 2);
    final columnMap = <String, Widget>{
      if (filter == SellerPaymentRepositoryClientFilter.onlyReadyForRequest)
        _columnChecked: VegaIcon(
          name: (ref.read(filter.logic) as SellerClientPaymentsSucceed).isSelected(payment)
              ? AtomIcons.checkboxOn
              : AtomIcons.checkboxOff,
        ),
      _columnPeriod: formatIntMonth(locale, payment.period).text.color(ref.scheme.content),
      _columnClient: (payment.clientName ?? "").text.color(ref.scheme.content),
      _columnClientStatus: payment.status.localizedName.text.color(ref.scheme.content),
      _columnClientBasicFee: payment.currency.formatSymbol(payment.base, locale).text.color(ref.scheme.content),
      _columnClientActiveCards: payment.activeCards.toString().text.color(ref.scheme.content),
      _columnClientActiveCardsPrice: clientActiveCardsPrice.text.color(ref.scheme.content),
      _columnClientTotalPrice: clientTotalPrice.text.color(ref.scheme.content),
      _columnYourEarnings: "$yourEarnings ($yourShare)".text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
    */
  }
}

// eof

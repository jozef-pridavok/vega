import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../enums/translated_client_payment_status.dart";
import "../../repositories/client_payment.dart";
import "../../states/client_payment_pay.dart";
import "../../states/client_payments.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "screen_pay.dart";

extension ClientPaymentRepositoryFilterLogic on ClientPaymentRepositoryFilter {
  static final _map = {
    ClientPaymentRepositoryFilter.unpaid: clientPaymentsUnpaid,
    ClientPaymentRepositoryFilter.lastThreeMonths: clientPaymentsLastThreeMonthsLogic,
    ClientPaymentRepositoryFilter.lastYear: clientPaymentsLastYearLogic,
  };

  StateNotifierProvider<ClientPaymentsNotifier, ClientPaymentsState> get logic => _map[this]!;
}

class ClientPaymentsWidget extends ConsumerStatefulWidget {
  final ClientPaymentRepositoryFilter filter;
  ClientPaymentsWidget(this.filter, {super.key});

  @override
  createState() => _ClientPaymentsWidgetWidgetState();
}

class _ClientPaymentsWidgetWidgetState extends ConsumerState<ClientPaymentsWidget> {
  ClientPaymentRepositoryFilter get _filter => widget.filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(_filter.logic.notifier).load());
  }

  void _listenToPayLogic() {
    if (_filter != ClientPaymentRepositoryFilter.unpaid) return;
    ref.listen(clientPaymentLogic, (previous, next) {
      if (next is ClientPaymentFinished) {
        ref.read(dashboardLogic.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToPayLogic();
    final stateWidgetMap = <Type, Widget>{
      ClientPaymentsFailed: StateErrorWidget(
        _filter.logic,
        onReload: () => ref.read(_filter.logic.notifier).reload(),
      ),
      ClientPaymentsSucceed: _GridWidget(_filter),
      ClientPaymentsRefreshing: _GridWidget(_filter),
    };
    final state = ref.watch(_filter.logic);
    return stateWidgetMap[state.runtimeType] ?? const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final ClientPaymentRepositoryFilter filter;
  const _GridWidget(this.filter);

  static const _columnPeriod = "period";
  static const _columnStatus = "status";
  static const _columnSum = "sum";
  static const _columnDueTo = "dueTo";
  static const _columnSeller = "seller";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(filter.logic) as ClientPaymentsSucceed;
    final payments = succeed.payments;
    return PullToRefresh(
      onRefresh: () => ref.read(filter.logic.notifier).reload(),
      child: DataGrid<ClientPayment>(
        rows: payments,
        columns: [
          if (!isMobile || filter != ClientPaymentRepositoryFilter.unpaid)
            DataGridColumn(name: _columnPeriod, label: LangKeys.columnPeriod.tr(), width: 100),
          if (filter == ClientPaymentRepositoryFilter.unpaid)
            DataGridColumn(name: _columnDueTo, label: LangKeys.columnDueTo.tr(), width: 120),
          DataGridColumn(name: _columnStatus, label: LangKeys.columnStatus.tr()),
          DataGridColumn(name: _columnSum, label: LangKeys.columnPrice.tr()),
          //DataGridColumn(name: _columnActiveCards, label: LangKeys.columnActiveCards.tr()),
          //DataGridColumn(name: _columnPricing, label: LangKeys.columnPrice.tr()),
          if (!isMobile) DataGridColumn(name: _columnSeller, label: LangKeys.columnSeller.tr()),
        ],
        onBuildCell: (column, payment) => _buildCell(context, ref, isMobile, column, payment),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, succeed, data, details),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, bool isMobile, String column, ClientPayment payment) {
    final locale = context.locale.languageCode;
    if (column == _columnPeriod) return formatIntMonth(locale, payment.period).text.color(ref.scheme.content);
    if (column == _columnDueTo) return formatDate(locale, payment.dueDate.toDate()).text.color(ref.scheme.content);
    if (column == _columnStatus) return payment.status.localizedName.text.color(ref.scheme.content);
    if (column == _columnSeller) return payment.sellerInfo.text.color(ref.scheme.content);
    if (column == _columnSum) {
      final currency = payment.currency;
      final totalPrice = payment.base + payment.activeCards * payment.pricing;
      if (isMobile) return currency.formatSymbol(totalPrice, locale).textBold.color(ref.scheme.content);
      final formula =
          "${currency.formatSymbol(payment.base, locale)} + (${payment.activeCards} × ${currency.formatSymbol(payment.pricing, locale)}) = ";
      return Wrap(children: [
        formula.text.color(ref.scheme.content),
        currency.formatSymbol(totalPrice, locale).textBold.color(ref.scheme.content),
      ]);
    }
    return "?".text.color(ref.scheme.content);
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ClientPaymentsSucceed succeed,
    ClientPayment payment,
    TapUpDetails details,
  ) {
    if (payment.status == ClientPaymentStatus.paid) return;
    final locale = context.locale.languageCode;
    final period = formatIntMonth(locale, payment.period);
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: period,
      items: [
        PopupMenuItem(
          child: MoleculeItemBasic(
            title: LangKeys.operationPay.tr(),
            icon: AtomIcons.about,
            onAction: () {
              context.pop();
              context.push(ClientPaymentPayScreen(succeed.providers, payment));
            },
          ),
        ),
      ],
    );
  }
}

// eof

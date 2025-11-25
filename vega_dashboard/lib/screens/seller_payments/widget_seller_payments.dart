import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../enums/translated_seller_payment_status.dart";
import "../../repositories/seller_payment.dart";
import "../../states/providers.dart";
import "../../states/seller_payment_request.dart";
import "../../states/seller_payments.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

extension SellerPaymentRepositoryFilterLogic on SellerPaymentRepositoryFilter {
  static final _map = {
    SellerPaymentRepositoryFilter.lastThreeMonths: sellerPaymentsLastThreeMonthsLogic,
    SellerPaymentRepositoryFilter.lastYear: sellerPaymentsLastYearLogic,
    SellerPaymentRepositoryFilter.onlyUnpaid: sellerPaymentsUnpaidLogic,
  };

  StateNotifierProvider<SellerPaymentsNotifier, SellerPaymentsState> get logic => _map[this]!;
}

class SellerPaymentsWidget extends ConsumerStatefulWidget {
  final SellerPaymentRepositoryFilter filter;
  SellerPaymentsWidget(this.filter, {super.key});

  @override
  createState() => _SellerPaymentsWidgetWidgetState();
}

class _SellerPaymentsWidgetWidgetState extends ConsumerState<SellerPaymentsWidget> {
  SellerPaymentRepositoryFilter get _filter => widget.filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(_filter.logic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    if (_filter == SellerPaymentRepositoryFilter.onlyUnpaid) {
      ref.listen(sellerPaymentRequestLogic, (previous, next) {
        if (next is SellerPaymentRequestSucceed) Future(() => ref.read(sellerPaymentsUnpaidLogic.notifier).reload());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final stateWidgetMap = <Type, Widget>{
      SellerPaymentsFailed: StateErrorWidget(
        _filter.logic,
        onReload: () => ref.read(_filter.logic.notifier).reload(),
      ),
      SellerPaymentsSucceed: _GridWidget(_filter),
      SellerPaymentsRefreshing: _GridWidget(_filter),
    };
    final state = ref.watch(_filter.logic);
    return stateWidgetMap[state.runtimeType] ?? const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final SellerPaymentRepositoryFilter filter;
  const _GridWidget(this.filter);

  static const _columnInvoice = "invoice";
  static const _columnClient = "client";
  static const _columnTotalPrice = "totalPrice";
  static const _columnShare = "share";
  static const _columnStatus = "status";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(filter.logic) as SellerPaymentsSucceed;
    final payments = succeed.payments;
    return PullToRefresh(
      onRefresh: () => ref.read(filter.logic.notifier).reload(),
      child: DataGrid<SellerPayment>(
        rows: payments,
        columns: [
          DataGridColumn(name: _columnInvoice, label: LangKeys.columnInvoiceNumber.tr()),
          DataGridColumn(name: _columnClient, label: LangKeys.columnClient.tr()),
          DataGridColumn(name: _columnShare, label: LangKeys.columnShare.tr()),
          DataGridColumn(name: _columnTotalPrice, label: LangKeys.columnTotal.tr()),
          DataGridColumn(name: _columnStatus, label: LangKeys.columnStatus.tr()),
        ],
        onBuildCell: (column, coupon) => _buildCell(context, ref, column, coupon),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, SellerPayment payment) {
    final locale = context.locale.languageCode;
    final columnMap = <String, Widget>{
      _columnInvoice: payment.sellerInvoice.text.color(ref.scheme.content),
      _columnClient: payment.clientName.text.color(ref.scheme.content),
      _columnShare: formatBasisPoint(locale, payment.sellerShare).text.color(ref.scheme.content),
      _columnTotalPrice: payment.totalCurrency.formatSymbol(payment.totalPrice, locale).text.color(ref.scheme.content),
      _columnStatus: payment.status.localizedName.toString().text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }
}

// eof

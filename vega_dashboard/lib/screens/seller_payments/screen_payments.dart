import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../repositories/client_payment.dart";
import "../../repositories/seller_payment.dart";
import "../../states/providers.dart";
import "../../states/seller_client_payments.dart";
import "../../states/seller_payment_request.dart";
import "../../strings.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";
import "widget_client_payments.dart";
import "widget_request_payment.dart";
import "widget_seller_payments.dart";

class SellerPaymentsScreen extends VegaScreen {
  const SellerPaymentsScreen({super.showDrawer, super.key});

  @override
  createState() => _SellerPaymentsState();
}

class _SellerPaymentsState extends VegaScreenState<SellerPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    _controller = TabController(initialIndex: _currentIndex, length: 5, vsync: this);
    _controller.addListener(() => setState(() => _currentIndex = _controller.index));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenSalesTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final readyForPayment = cast<SellerClientPaymentsSucceed>(ref.watch(sellerPaymentsReadyForRequestLogic));
    final requestingState = ref.watch(sellerPaymentRequestLogic);
    return [
      NotificationsWidget(),
      if (_currentIndex == 3 && (readyForPayment?.hasSelected ?? false)) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: MoleculeActionButton(
            title: LangKeys.screenSalesButtonRequestPayment.tr(),
            successTitle: LangKeys.operationSuccessful.tr(),
            failTitle: LangKeys.operationFailed.tr(),
            buttonState: requestingState.buttonState,
            onPressed: () async => _requestPayment(),
          ),
        ),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.screenSalesTabLastThreeMonths.tr()),
            Tab(text: LangKeys.screenSalesTabLastYear.tr()),
            Tab(text: LangKeys.screenSalesTabUnpaid.tr()),
            Tab(text: LangKeys.screenSalesTabReadyForRequest.tr()),
            Tab(text: LangKeys.screenSalesTabWaitingForClient.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                SellerPaymentsWidget(SellerPaymentRepositoryFilter.lastThreeMonths),
                SellerPaymentsWidget(SellerPaymentRepositoryFilter.lastYear),
                SellerPaymentsWidget(SellerPaymentRepositoryFilter.onlyUnpaid),
                ClientPaymentsWidget(SellerPaymentRepositoryClientFilter.onlyReadyForRequest),
                ClientPaymentsWidget(SellerPaymentRepositoryClientFilter.onlyWaitingForClient),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(sellerPaymentRequestLogic, (previous, next) {
      final failed = cast<SellerPaymentRequestFailed>(next);
      if (failed != null) toastCoreError(failed.error);
      final succeed = next is SellerPaymentRequestSucceed;
      if (failed != null || succeed)
        Future.delayed(stateRefreshDuration, () => ref.read(sellerPaymentRequestLogic.notifier).reset());
    });
  }

  void _requestPayment() async {
    final succeed = cast<SellerClientPaymentsSucceed>(ref.read(sellerPaymentsReadyForRequestLogic));
    final selected = succeed?.selected ?? [];
    //final dueDate = selected.map((e) => e.dueDate).reduce(
    //      (value, element) => value.value > element.value ? value : element,
    //    );

    final data = await _showRequestPaymentDialog();
    if (data == null) return;
    final invoiceNumber = data.$1;
    final dueDate = data.$2;

    ref.read(sellerPaymentRequestLogic.notifier).requestPayment(selected, invoiceNumber, dueDate);
  }

  Future<(String, IntDate)?> _showRequestPaymentDialog() async {
    // TODO: layout
    final isMobile = kDebugMode && ref.watch(layoutLogic).isMobile;
    return isMobile
        ? showModalBottomSheet<(String, IntDate)?>(
            context: context,
            isScrollControlled: true,
            shape: moleculeBottomSheetBorder,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.66,
                  minChildSize: 0.66,
                  maxChildSize: 0.90,
                  builder: (context, scrollController) => const RequestPaymentWidget(),
                ),
              );
            },
          )
        : showDialog<(String, IntDate)?>(
            context: context,
            builder: (context) => AlertDialog(
              title: LangKeys.screenTitleFinishSellerPaymentRequest.tr().text,
              content: const RequestPaymentWidget(),
            ),
          );
  }
}

// eof

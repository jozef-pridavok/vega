import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_dashboard/repositories/client_payment.dart";

import "../../states/client_payment_pay.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "widget_payments.dart";

class ClientPaymentsScreen extends VegaScreen {
  const ClientPaymentsScreen({super.showDrawer, super.key});

  @override
  createState() => _ClientPaymentsScreenState();
}

class _ClientPaymentsScreenState extends VegaScreenState<ClientPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 3, vsync: this);
    _controller.addListener(() => _onTabIndexChanged(_controller.index));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  getTitle() => LangKeys.screenClientPayments.tr();

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.screenClientPaymentsUnpaid.tr()),
            Tab(text: LangKeys.screenClientPaymentsTabLast3Months.tr()),
            Tab(text: LangKeys.screenClientPaymentsTabLastYear.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                ClientPaymentsWidget(ClientPaymentRepositoryFilter.unpaid),
                ClientPaymentsWidget(ClientPaymentRepositoryFilter.lastThreeMonths),
                ClientPaymentsWidget(ClientPaymentRepositoryFilter.lastYear),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(ClientPaymentRepositoryFilter.unpaid.logic, (previous, next) {
      //if ((next is ClientPaymentsSucceed) && next.payments.isEmpty) {
      //  Future.microtask(() => _controller.animateTo(1));
      //}
    });
    ref.listen(clientPaymentLogic, (previous, next) {
      if (next is ClientPaymentFinished) {
        toastInfo(LangKeys.toastClientPaymentSucceed.tr());
        ref.read(ClientPaymentRepositoryFilter.unpaid.logic.notifier).reload();
      }
    });
  }

  void _onTabIndexChanged(int index) {}
}

// eof

import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../screens/coupons/screen_edit.dart";
import "../../states/coupons.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "widget_active_coupons.dart";
import "widget_archived_coupons.dart";
import "widget_finished_coupons.dart";
import "widget_prepared_coupons.dart";

class CouponsScreen extends VegaScreen {
  const CouponsScreen({super.showDrawer, super.key});

  @override
  createState() => _CouponsState();
}

class _CouponsState extends VegaScreenState<CouponsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenCouponTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeCoupons = ref.watch(activeCouponsLogic);
    final preparedCoupons = ref.watch(preparedCouponsLogic);
    final finishedCoupons = ref.watch(finishedCouponsLogic);
    final archivedCoupons = ref.watch(archivedCouponsLogic);
    final isRefreshing =
        [activeCoupons, preparedCoupons, finishedCoupons, archivedCoupons].any((state) => state is CouponsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          _controller.animateTo(1);
          ref.read(couponEditorLogic.notifier).create();
          context.push(ScreenCouponEdit());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeCouponsLogic.notifier).refresh();
          ref.read(preparedCouponsLogic.notifier).refresh();
          ref.read(finishedCouponsLogic.notifier).refresh();
          ref.read(archivedCouponsLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabPrepared.tr()),
            Tab(text: LangKeys.tabFinished.tr()),
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: const [ActiveCoupons(), PreparedCoupons(), FinishedCoupons(), ArchivedCoupons()],
            ),
          ),
        ],
      ),
    );
  }
}

// eof

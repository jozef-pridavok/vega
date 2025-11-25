import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../reports/dashboard_statistic.dart";
import "../../states/dashboard.dart";
import "../../states/issue_reward.dart";
import "../../states/issue_user_card.dart";
import "../../states/issue_user_coupon.dart";
import "../../states/product_offers.dart";
import "../../states/product_orders.dart";
import "../../states/program_action.dart";
import "../../states/providers.dart";
import "../../states/redeem_user_coupon.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "../splash.dart";
import "actions_pos.dart";
import "dashboard_desktop.dart";
import "dashboard_mobile.dart";

class DashboardScreen extends VegaScreen {
  const DashboardScreen({super.showDrawer, super.key});

  @override
  createState() => _DashboardScreenState();
}

class _DashboardScreenState extends VegaScreenState<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      ref.read(dashboardLogic.notifier).refresh();
    });

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client?;
    if (client == null) return;

    if (client.licenseModuleReservations)
      Future(() {
        final reservationsState = ref.read(activeReservationsLogic);
        if (reservationsState is ReservationsInitial) {
          ref.read(activeReservationsLogic.notifier).load();
        }
      });

    if (client.licenseModuleOrders)
      Future(() {
        final offersState = ref.read(activeProductOffersLogic);
        if (offersState is ProductOffersInitial) {
          ref.read(activeProductOffersLogic.notifier).load();
        }
        Future(() {
          final ordersState = ref.read(activeProductOrdersLogic);
          if (ordersState is ProductOrdersInitial) {
            ref.read(activeProductOrdersLogic.notifier).load();
          }
        });
      });
  }

  @override
  String? getTitle() => LangKeys.screenDashboardTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final state = ref.watch(dashboardLogic);
    final refreshing = state.runtimeType == DashboardRefreshing;
    return [
      //if (isMobile)
      //  IconButton(
      //    icon: VegaIcon(name: AtomIcons.trendingUp),
      //    onPressed: () {},
      //  ),
      if (state is DashboardSucceed) ...[
        IconButton(
          icon: const VegaIcon(name: AtomIcons.camera),
          onPressed: () => state.posUniversalCamera(context, ref),
        ),
      ],
      VegaRefreshButton(
        onPressed: () {
          ref.read(dashboardLogic.notifier).refresh();
          ref.read(clientReportLogic(DashboardStatistic.reportId).notifier).refresh(set: DashboardStatistic.report());
        },
        isRotating: refreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToIssueCouponLogic(context);
    _listenToRedeemCouponLogic(context);
    _listenToIssueUserCardLogic(context);
    _listenToProgramActionLogic(context);
    _listenToIssueRewardLogic(context);
    final dashboardState = ref.watch(dashboardLogic);
    final isMobile = ref.watch(layoutLogic).isMobile;
    if (dashboardState is DashboardSucceed)
      return isMobile ? const DashboardMobile() : const DashboardDesktop();
    else if (dashboardState is DashboardFailed)
      return StateErrorWidget(
        dashboardLogic,
        onReload: () => ref.read(dashboardLogic.notifier).refresh(),
        getIcon: (error) => error == errorNoClientId ? AtomIcons.user : null,
        getButtonAction: (error, context, ref) {
          // broken logout?
          if (error == errorNoClientId) {
            ref.read(loginLogic.notifier).reset();
            final device = ref.read(deviceRepository);
            // TODO: tu by som mal zachovať deviceToken a isWizardShowed
            device.clearAll();
            context.replace(const SplashScreen(), popAll: true);
            return;
          }
          ref.read(dashboardLogic.notifier).refresh();
        },
      );
    else
      return const CenteredWaitIndicator();
  }

  void _listenToIssueCouponLogic(BuildContext context) {
    ref.listen(issueCouponLogic, (previous, next) {
      if (next is IssueCouponSucceed) {
        toastInfo(LangKeys.toastCouponIssued.tr());
        ref.read(issueCouponLogic.notifier).reset();
        updateWaitDialog(context, ref, LangKeys.toastCouponIssued.tr());
        Future.delayed(stateRefreshDuration, () => closeWaitDialog(context, ref));
      } else if (next is IssueCouponFailed) {
        ref.read(issueCouponLogic.notifier).reset();
        toastError(next.error?.toString() ?? LangKeys.operationFailed.tr());
        closeWaitDialog(context, ref);
      }
    });
  }

  void _listenToRedeemCouponLogic(BuildContext context) {
    ref.listen(redeemCouponLogic, (previous, next) {
      if (next is RedeemCouponSucceed) {
        toastInfo(LangKeys.toastCouponRedeemed.tr());
        ref.read(redeemCouponLogic.notifier).reset();
        updateWaitDialog(context, ref, LangKeys.toastCouponRedeemed.tr());
        Future.delayed(stateRefreshDuration, () => closeWaitDialog(context, ref));
      } else if (next is RedeemCouponFailed) {
        ref.read(redeemCouponLogic.notifier).reset();
        closeWaitDialog(context, ref);
        final code = next.error?.code;
        if (code == errorBrokenLogic.code) {
          toastError(LangKeys.toastCouponHasNotBeenRedeemed.tr());
        } else
          toastError(next.error?.toString() ?? LangKeys.operationFailed.tr());
      }
    });
  }

  void _listenToIssueUserCardLogic(BuildContext context) {
    ref.listen(issueUserCardLogic, (previous, next) {
      if (next is IssueUserCardSucceed) {
        toastInfo(LangKeys.toastUserCardIssued.tr());
        ref.read(issueUserCardLogic.notifier).reset();
        updateWaitDialog(context, ref, LangKeys.toastUserCardIssued.tr());
        Future.delayed(stateRefreshDuration, () => closeWaitDialog(context, ref));
      } else if (next is IssueUserCardFailed) {
        toastError(next.error?.toString() ?? LangKeys.operationFailed.tr());
        ref.read(issueUserCardLogic.notifier).reset();
        closeWaitDialog(context, ref);
      }
    });
  }

  void _listenToProgramActionLogic(BuildContext context) {
    ref.listen(programActionLogic, (previous, next) {
      if (next is ProgramActionSucceed) {
        toastInfo(LangKeys.toastBalanceHasBeenUpdated.tr());
        ref.read(programActionLogic.notifier).reset();
        updateWaitDialog(context, ref, LangKeys.toastBalanceHasBeenUpdated.tr());
        Future.delayed(stateRefreshDuration, () => closeWaitDialog(context, ref));
      } else if (next is ProgramActionFailed) {
        ref.read(programActionLogic.notifier).reset();
        closeWaitDialog(context, ref);
        final code = next.error.code;
        var info = next.error.toString();
        if (code == errorNotEnoughPoints.code) info = LangKeys.toastNotEnoughPoints.tr();
        toastError(info);
      }
    });
  }

  void _listenToIssueRewardLogic(BuildContext context) {
    ref.listen(issueRewardLogic, (previous, next) {
      if (next is IssueRewardSucceed) {
        toastInfo(LangKeys.toastRewardHasBeenIssued.tr());
        ref.read(issueRewardLogic.notifier).reset();
        updateWaitDialog(context, ref, LangKeys.toastRewardHasBeenIssued.tr());
        Future.delayed(stateRefreshDuration, () => closeWaitDialog(context, ref));
      } else if (next is IssueRewardFailed) {
        ref.read(issueRewardLogic.notifier).reset();
        closeWaitDialog(context, ref);
        final code = next.error.code;
        var info = next.error.toString();
        if (code == errorNotEnoughPoints.code) info = LangKeys.toastNotEnoughPoints.tr();
        toastError(info);
      }
    });
  }
}

// eof

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../reports/dashboard_statistic.dart";
import "../screens/splash.dart";
import "../states/providers.dart";
import "../strings.dart";
import "../widgets/drawer.dart";

abstract class VegaScreen extends Screen {
  final bool showDrawer;
  const VegaScreen({this.showDrawer = false, super.key});
}

abstract class VegaScreenState<S extends VegaScreen> extends ScreenState<S> {
  @protected
  String? getTitle();

  @protected
  List<Widget>? buildAppBarActions() => null;

  @nonVirtual
  @override
  Widget? buildDrawer(BuildContext context) => const VegaDrawer();

  @override
  @nonVirtual
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    if (widget.showDrawer)
      return VegaDrawerBar(
        title: getTitle(),
        onDrawer: widget.showDrawer
            ? () {
                final state = scaffoldKey.currentState;
                assert(state != null, "ScaffoldState is null");
                if (state != null) {
                  if (state.isDrawerOpen) {
                    if (canCloseDrawer()) state.closeDrawer();
                  } else {
                    state.openDrawer();
                  }
                }
              }
            : null,
        actions: buildAppBarActions(),
      );
    else
      return VegaAppBar(
        title: getTitle(),
        onBack: () => onBack(ref),
        centerTitle: false,
        hideButton: hideBackButton,
        actions: buildAppBarActions(),
      );
  }

  @protected
  bool canCloseDrawer() => true;

  @protected
  bool onBack(WidgetRef ref) => true;

  @protected
  bool get hideBackButton => false;

  void _listenLogoutLogic() {
    void cleanup() {
      ref.read(dashboardLogic.notifier).reset();
      ref.read(clientReportLogic(DashboardStatistic.reportId).notifier).reset();

      ref.read(activeClientCardsLogic.notifier).reset();
      ref.read(archivedClientCardsLogic.notifier).reset();

      ref.read(activeProgramsLogic.notifier).reset();
      ref.read(preparedProgramsLogic.notifier).reset();
      ref.read(finishedProgramsLogic.notifier).reset();
      ref.read(archivedProgramsLogic.notifier).reset();

      ref.read(activeCouponsLogic.notifier).reset();
      ref.read(preparedCouponsLogic.notifier).reset();
      ref.read(finishedCouponsLogic.notifier).reset();
      ref.read(archivedCouponsLogic.notifier).reset();

      ref.read(activeCouponsLogic.notifier).reset();
      ref.read(preparedCouponsLogic.notifier).reset();
      ref.read(finishedCouponsLogic.notifier).reset();
      ref.read(archivedCouponsLogic.notifier).reset();

      ref.read(activeReservationsLogic.notifier).reset();
      ref.read(archivedReservationsLogic.notifier).reset();

      ref.read(activeProductOffersLogic.notifier).refresh();
      ref.read(archivedProductOffersLogic.notifier).reset();

      ref.read(activeProductOrdersLogic.notifier).reset();
      ref.read(closedProductOrdersLogic.notifier).reset();

      ref.read(sellerPaymentsWaitingForClientLogic.notifier).reset();
      ref.read(sellerPaymentsLastThreeMonthsLogic.notifier).reset();
      ref.read(sellerPaymentsLastYearLogic.notifier).reset();
      ref.read(sellerPaymentsUnpaidLogic.notifier).reset();
      ref.read(sellerPaymentsReadyForRequestLogic.notifier).reset();
    }

    ref.listen(logoutLogic, (previous, next) {
      if (next is LogoutSucceed) {
        ref.read(logoutLogic.notifier).reset();
        cleanup();
        context.replace(const SplashScreen(), popAll: true);
      }
    });
  }

  @nonVirtual
  @override
  void listenToLogics(BuildContext context) {
    super.listenToLogics(context);
    _listenLogoutLogic();
  }

  void toastInfo(String message) => ref.read(toastLogic.notifier).info(message);
  void toastWarning(String message) => ref.read(toastLogic.notifier).warning(message);
  void toastError(String message) => ref.read(toastLogic.notifier).error(message);
  void toastCoreError(CoreError error) => ref.read(toastLogic.notifier).error(error.toString());

  final _unsavedWarningText = LangKeys.notificationUnsavedData.tr();
  void notifyUnsaved(String tag) => ref.read(notificationsLogic.notifier).warning(_unsavedWarningText, tag: tag);
  void dismissUnsaved(String tag) => ref.read(notificationsLogic.notifier).dismiss(tag);

  void delayedStateRefresh(Function() action) => mounted ? Future.delayed(stateRefreshDuration, action) : null;
}

extension ConsumerWidgetToasts on ConsumerWidget {
  void toastInfo(WidgetRef ref, String message) => ref.read(toastLogic.notifier).info(message);
  void toastWarning(WidgetRef ref, String message) => ref.read(toastLogic.notifier).warning(message);
  void toastError(WidgetRef ref, String message) => ref.read(toastLogic.notifier).error(message);
  void toastCoreError(WidgetRef ref, CoreError error) => ref.read(toastLogic.notifier).error(error.toString());
}

extension ConsumerStateToasts on ConsumerState {
  void toastInfo(String message) => ref.read(toastLogic.notifier).info(message);
  void toastWarning(String message) => ref.read(toastLogic.notifier).warning(message);
  void toastError(String message) => ref.read(toastLogic.notifier).error(message);
  void toastCoreError(CoreError error) => ref.read(toastLogic.notifier).error(error.toString());

  void delayedRefresh(Function() action) => mounted ? Future.delayed(stateRefreshDuration, action) : null;
}

// eof

import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import "package:vega_dashboard/screens/dashboard/statistics/widget_month_line.dart";
import "package:vega_dashboard/screens/dashboard/statistics/widget_week_stacked_bar_chart.dart";
import "package:vega_dashboard/states/client_report.dart";

import "../../../reports/dashboard_statistic.dart";
import "../../../states/providers.dart";
import "../../../strings.dart";
import "../../../widgets/state_error.dart";
import "../../client_user_cards/screen_user_cards.dart";
import "wdiget_item.dart";
import "widget_item_chart.dart";
import "widget_week_bar_chart.dart";
import "widget_week_bars_chart.dart";

class StatisticsGridWidget extends ConsumerStatefulWidget {
  const StatisticsGridWidget();

  @override
  createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends ConsumerState<StatisticsGridWidget> {
  String get _reportId => DashboardStatistic.reportId;
  ClientReportSet get _report => DashboardStatistic.report();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientReportLogic(_reportId).notifier).load(_report));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    if (user.userType != UserType.client) return const SizedBox();
    final state = ref.watch(clientReportLogic(_reportId));
    if (state is ClientReportFailed) {
      return StateErrorWidget(
        clientReportLogic(_reportId),
        onReload: () => ref.read(clientReportLogic(_reportId).notifier).load(_report),
      );
    }
    final data = cast<ClientReportStateWithData>(ref.watch(clientReportLogic(_reportId)))?.data;
    return PullToRefresh(
      onRefresh: () => ref.read(clientReportLogic(_reportId).notifier).refresh(),
      child: SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 6,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 1,
              child: ItemWidget(
                title: LangKeys.labelActiveCards.tr(),
                subtitle: LangKeys.labelPreviousWeek.tr(),
                value: data?.quarterOfArray(DashboardStatistic.activeCards, 2)?.sum.toString() ?? "?",
                onTap: () => context.push(const ClientUserCardsScreen()),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 1,
              child: ItemChartWidget(
                title: LangKeys.labelActiveCards.tr(),
                subtitle: LangKeys.labelThisWeek.tr(),
                isLoading: data == null,
                value: data?.quarterOfArray(DashboardStatistic.activeCards, 3)?.sum.toString() ?? "?",
                onTap: () => context.push(const ClientUserCardsScreen()),
                chart: MonthLineChart(
                  title: LangKeys.labelActiveCards.tr(),
                  firstDate: DashboardStatistic.firstDate,
                  values: data?.array(DashboardStatistic.activeCards),
                ),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: ItemWidget(
                title: LangKeys.labelTotalCards.tr(),
                subtitle: LangKeys.labelTotalSum.tr(),
                value: data?.count(DashboardStatistic.totalCards).toString() ?? "?",
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: ItemWidget(
                title: LangKeys.labelNewUsers.tr(),
                subtitle: LangKeys.labelThisWeek.tr(),
                value: data?.quarterOfArray(DashboardStatistic.newUsers, 3)?.sum.toString() ?? "?",
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: ItemWidget(
                title: LangKeys.labelTotalUsers.tr(),
                subtitle: LangKeys.labelTotalSum.tr(),
                value: data?.count(DashboardStatistic.totalUsers)?.toString() ?? "?",
              ),
            ),
            /* -- Line
            StaggeredGridTile.count(
              crossAxisCellCount: 6, // 4
              mainAxisCellCount: 2, // 2
              child: MonthLineChart(
                title: LangKeys.labelActiveCards.tr(),
                values: [
                  data?.quarterOfArray(DashboardStatistic.activeCards, 0)?.sum ?? 0,
                  data?.quarterOfArray(DashboardStatistic.activeCards, 1)?.sum ?? 0,
                  data?.quarterOfArray(DashboardStatistic.activeCards, 2)?.sum ?? 0,
                  data?.quarterOfArray(DashboardStatistic.activeCards, 3)?.sum ?? 0,
                ],
              ),
            ),
            / */
            StaggeredGridTile.count(
              crossAxisCellCount: 6, // 4
              mainAxisCellCount: 2, // 2
              child: WeekBarsChart(
                title: LangKeys.labelActiveCards.tr(),
                values: [
                  data?.quarterOfArray(DashboardStatistic.activeCards, 0),
                  data?.quarterOfArray(DashboardStatistic.activeCards, 1),
                  data?.quarterOfArray(DashboardStatistic.activeCards, 2),
                  data?.quarterOfArray(DashboardStatistic.activeCards, 3),
                ],
                colors: [
                  ref.scheme.content10,
                  ref.scheme.content20,
                  ref.scheme.secondary,
                  ref.scheme.primary,
                ],
                labels: [
                  "-3",
                  "-2",
                  LangKeys.labelPreviousWeek.tr(),
                  LangKeys.labelThisWeek.tr(),
                ],
              ),
            ),
            //
            StaggeredGridTile.count(
              crossAxisCellCount: 3, // 4
              mainAxisCellCount: 2, // 2
              child: WeekBarChart(
                title: LangKeys.labelActiveCards.tr(),
                subtitle: LangKeys.labelPreviousWeek.tr(),
                values: data?.quarterOfArray(DashboardStatistic.activeCards, 2),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 3, // 4
              mainAxisCellCount: 2, // 2
              child: WeekBarChart(
                title: LangKeys.labelActiveCards.tr(),
                subtitle: LangKeys.labelThisWeek.tr(),
                values: data?.quarterOfArray(DashboardStatistic.activeCards, 3),
              ),
            ),
            //
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: WeekBarChart(
                title: LangKeys.labelNewCards.tr(),
                subtitle: LangKeys.labelPreviousWeek.tr(),
                values: data?.quarterOfArray(DashboardStatistic.newCards, 2),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: WeekBarChart(
                title: LangKeys.labelNewCards.tr(),
                subtitle: LangKeys.labelThisWeek.tr(),
                values: data?.quarterOfArray(DashboardStatistic.newCards, 3),
              ),
            ),
            //
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: WeekStackedBarChart(
                title: LangKeys.labelReservation.tr(),
                subtitle: LangKeys.labelPreviousWeek.tr(),
                values: [
                  data?.quarterOfArray(DashboardStatistic.unconfirmedReservations, 2),
                  data?.quarterOfArray(DashboardStatistic.confirmedReservations, 2),
                  data?.quarterOfArray(DashboardStatistic.completedReservations, 2),
                  data?.quarterOfArray(DashboardStatistic.forfeitedReservations, 2),
                ],
                colors: [
                  ref.scheme.secondary,
                  ref.scheme.primary,
                  ref.scheme.positive,
                  ref.scheme.negative,
                ],
                labels: [
                  ReservationDateStatus.available.localizedName,
                  ReservationDateStatus.confirmed.localizedName,
                  ReservationDateStatus.completed.localizedName,
                  ReservationDateStatus.forfeited.localizedName,
                ],
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: WeekStackedBarChart(
                title: LangKeys.labelReservation.tr(),
                subtitle: LangKeys.labelThisWeek.tr(),
                values: [
                  data?.quarterOfArray(DashboardStatistic.unconfirmedReservations, 3),
                  data?.quarterOfArray(DashboardStatistic.confirmedReservations, 3),
                  data?.quarterOfArray(DashboardStatistic.completedReservations, 3),
                  data?.quarterOfArray(DashboardStatistic.forfeitedReservations, 3),
                ],
                colors: [
                  ref.scheme.secondary,
                  ref.scheme.primary,
                  ref.scheme.positive,
                  ref.scheme.negative,
                ],
                labels: [
                  ReservationDateStatus.available.localizedName,
                  ReservationDateStatus.confirmed.localizedName,
                  ReservationDateStatus.completed.localizedName,
                  ReservationDateStatus.forfeited.localizedName,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

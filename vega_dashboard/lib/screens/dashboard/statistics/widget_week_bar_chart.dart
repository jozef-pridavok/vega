import "package:collection/collection.dart";
import "package:community_charts_flutter/community_charts_flutter.dart" as charts;
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:vega_dashboard/screens/dashboard/statistics/widget_chart_aux.dart";

import "widget_item_base.dart";

class _WeekChartData {
  final String day;
  final int? count;

  _WeekChartData(this.day, this.count);
}

class WeekBarChart extends ConsumerWidget with ChartDefaults {
  final String title;
  final String subtitle;
  final List<int>? values;

  const WeekBarChart({required this.title, required this.subtitle, required this.values});

  List<charts.Series<_WeekChartData, String>> _createData(BuildContext context, WidgetRef ref) {
    final data = <_WeekChartData>[];

    final format = DateFormat.E(context.languageCode);

    week.forEachIndexed((index, day) {
      //final count = report?.value<int>(DashboardStatistic.newCards(index), "count");
      data.add(_WeekChartData(_getShortName(format, day), values?[index]));
    });

    final min = data.map((e) => e.count).reduce((value, element) => (value ?? 0) < (element ?? 0) ? value : element);

    return [
      charts.Series<_WeekChartData, String>(
        id: "4d811817-de96-46f0-a387-dd8748cee6f6",
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(ref.scheme.primary),
        fillColorFn: (_WeekChartData stat, _) => charts.ColorUtil.fromDartColor(
          (min != null && stat.count != null && stat.count == min) ? ref.scheme.negative : ref.scheme.primary,
        ),
        domainFn: (_WeekChartData stat, _) => stat.day,
        measureFn: (_WeekChartData stat, _) => stat.count,
        labelAccessorFn: (_WeekChartData stat, _) => stat.count.toString(),
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemBaseWidget(
      child: Column(
        children: [
          title.labelBold.alignCenter,
          const SizedBox(height: 8),
          subtitle.micro.alignCenter,
          Flexible(
            child: charts.BarChart(
              _createData(context, ref),
              animate: false,
              barRendererDecorator: barRendererDecorator(ref),
              domainAxis: ordinalAxis(ref),
              primaryMeasureAxis: primaryMeasureAxis(ref),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortName(DateFormat format, Day day) {
    int weekdayIndex = week.indexOf(day) + 1;
    return format.format(DateTime(2024, 1, weekdayIndex));
  }
}

// eof

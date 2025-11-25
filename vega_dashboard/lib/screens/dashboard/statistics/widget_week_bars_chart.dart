import "package:collection/collection.dart";
import "package:community_charts_flutter/community_charts_flutter.dart" as charts;
import "package:core_flutter/core_dart.dart" hide Color;
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

class WeekBarsChart extends ConsumerWidget with ChartDefaults {
  final String title;
  final String? subtitle;
  final List<List<int>?> values;
  final List<Color> colors;
  final List<String> labels;

  const WeekBarsChart(
      {required this.title, this.subtitle, required this.values, required this.colors, required this.labels});

  List<charts.Series<_WeekChartData, String>> _createData(BuildContext context, WidgetRef ref) {
    final data = List<List<_WeekChartData>>.generate(values.length, (_) => <_WeekChartData>[]);

    final format = DateFormat.E(context.languageCode);

    for (int set = 0; set < values.length; set++) {
      week.forEachIndexed((index, day) {
        data[set].add(_WeekChartData(_getShortName(format, day), (values[set])?[index]));
      });
    }

    return data.map((set) {
      return charts.Series<_WeekChartData, String>(
        id: "$set",
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(ref.scheme.primary),
        fillColorFn: (_WeekChartData stat, _) => charts.ColorUtil.fromDartColor(
          colors[data.indexOf(set)],
        ),
        domainFn: (_WeekChartData stat, _) => stat.day,
        measureFn: (_WeekChartData stat, _) => stat.count,
        labelAccessorFn: (_WeekChartData stat, _) => ((stat.count ?? 0) == 0) ? "" : stat.count.toString(),
        data: set,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemBaseWidget(
      child: Column(
        children: [
          title.labelBold.alignCenter,
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            subtitle.micro.alignCenter,
          ],
          Flexible(
            child: charts.BarChart(
              _createData(context, ref),
              barGroupingType: charts.BarGroupingType.grouped,
              animate: false,
              barRendererDecorator: barRendererDecorator(ref),
              domainAxis: ordinalAxis(ref),
              primaryMeasureAxis: primaryMeasureAxis(ref),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              labels.length,
              (index) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 16, height: 16, color: colors[index]),
                  const SizedBox(width: 6),
                  labels[index].micro.alignCenter,
                  const SizedBox(width: 16),
                ],
              ),
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

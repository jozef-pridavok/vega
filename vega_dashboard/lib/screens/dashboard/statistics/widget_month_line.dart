import "package:community_charts_flutter/community_charts_flutter.dart" as charts;
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:vega_dashboard/screens/dashboard/statistics/widget_chart_aux.dart";

import "../../../strings.dart";

class _MonthChartData {
  final int week;
  final int? sum;

  _MonthChartData(this.week, this.sum);
}

class MonthLineChart extends ConsumerWidget with ChartDefaults {
  final String title;
  final String? subtitle;
  final DateTime? firstDate;
  final List<int>? values;

  const MonthLineChart({required this.title, this.subtitle, required this.firstDate, required this.values});

  List<charts.Series<_MonthChartData, int>> _createData(BuildContext context, WidgetRef ref) {
    final data = <_MonthChartData>[];

    for (int i = 0; i < 4; i++) {
      final week = (values?.sublist(7 * i, 7 * (i + 1)));
      final sum = week?.reduce((value, element) => value + element);
      data.add(_MonthChartData((i + 1) * 7, sum));
    }

    return [
      charts.Series<_MonthChartData, int>(
        id: "257ebc1d-e6dd-48ec-a6dc-638634bcd0ca",
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(ref.scheme.primary),
        domainFn: (_MonthChartData stat, _) => stat.week,
        measureFn: (_MonthChartData stat, _) => stat.sum,
        labelAccessorFn: (_MonthChartData stat, _) => stat.sum.toString(),
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = DateFormat.Md(context.languageCode);
    final fd = firstDate;
    final now = DateTime.now();
    final days = DateTimeExtensions.endOfThisWeek.difference(now).inDays;
    return charts.LineChart(
      _createData(context, ref),
      animate: false,
      behaviors: [
        charts.RangeAnnotation([
          charts.LineAnnotationSegment(
            28 - days,
            charts.RangeAnnotationAxisType.domain,
            startLabel: LangKeys.coreDayToday.tr(),
            color: charts.ColorUtil.fromDartColor(ref.scheme.accent),
            dashPattern: [4, 4],
            labelStyleSpec: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(ref.scheme.content20),
              fontSize: 12,
            ),
            strokeWidthPx: 1,
          ),
        ]),
      ],

      defaultRenderer: charts.LineRendererConfig(strokeWidthPx: 1.0),
      //domainAxis: numericAxis(ref, formatter: (value) => "W${value?.toInt()}"),
      domainAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          [
            /*
            //charts.TickSpec(1, label: '1'), // 1. deň mesiaca
            charts.TickSpec(7, label: '7'), // 7. deň
            charts.TickSpec(14, label: '14'), // 14. deň
            charts.TickSpec(21, label: '21'), // 21. deň
            charts.TickSpec(28, label: '28'), // 28. deň
            */
            charts.TickSpec(7, label: fd != null ? format.format(fd.add(Duration(days: 6))) : ""),
            charts.TickSpec(14, label: fd != null ? format.format(fd.add(Duration(days: 13))) : ""),
            charts.TickSpec(21, label: fd != null ? format.format(fd.add(Duration(days: 20))) : ""),
            charts.TickSpec(28, label: fd != null ? format.format(fd.add(Duration(days: 27))) : ""),
          ],
        ),
        viewport: charts.NumericExtents(7, 28), // Zobraziť celý rozsah 1-28
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec((value) {
          final day = firstDate?.add(Duration(days: value?.toInt() ?? 0));
          if (day != null) return format.format(day);
          return "W${value?.toInt()}";
        }),
      ),

      //domainAxis: charts.NumericAxisSpec(showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
      //primaryMeasureAxis: primaryMeasureAxis(ref),
      primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
    );
  }
}

// eof

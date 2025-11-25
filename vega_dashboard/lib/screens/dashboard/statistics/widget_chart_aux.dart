import "package:community_charts_flutter/community_charts_flutter.dart" as charts;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

extension ChartStyleExtension on TextStyle {
  charts.TextStyleSpec get toChartStyle {
    return charts.TextStyleSpec(
      fontFamily: fontFamily,
      fontSize: fontSize?.toInt(),
      color: charts.ColorUtil.fromDartColor(color ?? Colors.black),
      fontWeight: _mapFontWeight(fontWeight),
    );
  }

  String? _mapFontWeight(FontWeight? fontWeight) {
    if (fontWeight == FontWeight.w100) return "100";
    if (fontWeight == FontWeight.w200) return "200";
    if (fontWeight == FontWeight.w300) return "300";
    if (fontWeight == FontWeight.w400) return "400";
    if (fontWeight == FontWeight.w500) return "500";
    if (fontWeight == FontWeight.w600) return "600";
    if (fontWeight == FontWeight.w700) return "700";
    if (fontWeight == FontWeight.w800) return "800";
    if (fontWeight == FontWeight.w900) return "900";
    return "normal";
  }
}

mixin ChartDefaults on ConsumerWidget {
  charts.BarLabelDecorator<String>? barRendererDecorator(WidgetRef ref) => charts.BarLabelDecorator<String>(
        insideLabelStyleSpec: charts.TextStyleSpec(color: charts.ColorUtil.fromDartColor(ref.scheme.light)),
        outsideLabelStyleSpec: charts.TextStyleSpec(color: charts.ColorUtil.fromDartColor(ref.scheme.content)),
      );

  charts.AxisSpec<dynamic>? ordinalAxis(WidgetRef ref) => charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: AtomStyles.microText.copyWith(color: ref.scheme.content50).toChartStyle,
          labelAnchor: charts.TickLabelAnchor.centered,
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(ref.scheme.content50), // Farba osi X - zakladna ciara
          ),
        ),
      );

  charts.AxisSpec<dynamic>? numericAxis(WidgetRef ref, {String Function(num?)? formatter}) => charts.NumericAxisSpec(
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(formatter),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: AtomStyles.microText.copyWith(color: ref.scheme.content50).toChartStyle,
          lineStyle: charts.LineStyleSpec(
            //thickness: 1, // Hrúbka linky
            color: charts.ColorUtil.fromDartColor(ref.scheme.content50),
          ),
        ),
        //viewport: charts.NumericExtents(0, 26),
      );

  charts.NumericAxisSpec primaryMeasureAxis(WidgetRef ref) => charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: AtomStyles.microText.copyWith(color: ref.scheme.content50).toChartStyle,
          labelAnchor: charts.TickLabelAnchor.centered,
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(ref.scheme.content20), // Farba osi X - horizontalne ciary
          ),
        ),
      );
}

// eof

import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "widget_item_base.dart";

class ItemChartWidget extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String value;
  final Widget? chart;
  final void Function()? onTap;
  final bool isLoading;

  const ItemChartWidget({
    required this.title,
    this.subtitle,
    required this.value,
    this.chart,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemBaseWidget(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isLoading ? null : onTap,
        child: MouseRegion(
          cursor: !isLoading && onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: isLoading
              ? CenteredWaitIndicator()
              : Row(
                  children: [
                    const Spacer(flex: 2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        title.labelBold.color(ref.scheme.content).alignCenter,
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          subtitle!.micro.color(ref.scheme.content).alignCenter,
                        ],
                        const SizedBox(height: 8),
                        value.h2.alignCenter,
                      ],
                    ),
                    if (chart != null) ...[
                      const SizedBox(width: 20),
                      AspectRatio(
                        aspectRatio: 2.25,
                        child: chart ?? const SizedBox(),
                      ),
                    ],
                    const Spacer(flex: 1),
                  ],
                ),
        ),
      ),
    );
  }
}

// eof

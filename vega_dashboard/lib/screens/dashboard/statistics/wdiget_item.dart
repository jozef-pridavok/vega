import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "widget_item_base.dart";

class ItemWidget extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String value;
  final void Function()? onTap;

  const ItemWidget({
    required this.title,
    this.subtitle,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemBaseWidget(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
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
        ),
      ),
    );
  }
}

// eof

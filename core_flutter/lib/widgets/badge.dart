import "package:core_flutter/extensions/widget_ref.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../themes/theme.dart";

class BadgeWidget extends ConsumerWidget {
  final Widget child;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final double padding;
  final double borderRadius;
  final Offset offset;

  const BadgeWidget({
    super.key,
    required this.child,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding = 5,
    this.borderRadius = 10,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        Positioned(
          top: offset.dy,
          right: offset.dx,
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: backgroundColor ?? ref.scheme.negative,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            constraints: BoxConstraints(
              minWidth: (AtomStyles.microText.fontSize ?? fontSize) + padding * 2,
              minHeight: (AtomStyles.microText.fontSize ?? fontSize) + padding * 2,
            ),
            child: Text(
              text,
              style: AtomStyles.microText,
            ),
          ),
        ),
      ],
    );
  }
}

// eif

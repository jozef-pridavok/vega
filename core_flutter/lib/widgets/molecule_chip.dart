import "package:core_flutter/core_theme.dart";
import "package:core_flutter/core_widgets.dart";
import "package:core_flutter/extensions/color.dart";
import "package:core_flutter/extensions/widget_ref.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeChip extends ConsumerWidget {
  final String label;
  final String? icon;
  final void Function()? onTap;
  final void Function()? onClose;
  final bool active;
  final Color? backgroundColor;
  final BoxBorder? border;
  final TextStyle? style;

  const MoleculeChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onClose,
    this.active = false,
    this.backgroundColor,
    this.border,
    this.style = AtomStyles.labelText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var label = ThemedText(text: this.label, style: (_) => style ?? AtomStyles.labelText);
    final color = backgroundColor != null
        ? backgroundColor!.dolText(ref.scheme.content, ref.scheme.light)
        : (!active ? ref.scheme.primary : ref.scheme.light);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: EdgeInsets.only(left: 16, right: onClose != null ? 8 : 16, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: backgroundColor ?? (!active ? ref.scheme.paperBold : ref.scheme.primary),
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                VegaIcon(name: icon!, color: color, size: 16),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: label.maxLine(1).overflowEllipsis.color(color),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: VegaIcon(name: "cancel", color: ref.scheme.light, size: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// eof

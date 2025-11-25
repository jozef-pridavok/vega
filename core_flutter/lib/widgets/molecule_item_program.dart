import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "basic.dart";

class MoleculeItemProgram extends ConsumerWidget {
  final Widget? image;
  final String title;
  final String? label;
  final int? qty;
  final void Function(bool)? onQtyChanged;

  const MoleculeItemProgram({
    super.key,
    this.image,
    required this.title,
    this.label,
    this.qty,
    this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (qty != null) ...[
          Column(
            children: [
              IconButton(
                onPressed: () => onQtyChanged?.call(true),
                icon: const VegaIcon(name: AtomIcons.plusCircle, size: 24),
              ),
              qty.toString().textBold.color(ref.scheme.content),
              IconButton(
                onPressed: () => onQtyChanged?.call(false),
                icon: const VegaIcon(name: AtomIcons.minusCircle, size: 24),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        if (image != null) ...[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ref.scheme.paperBold,
            ),
            child: image!,
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title.text.maxLine(1).overflowEllipsis.color(ref.scheme.content),
              if (label != null) ...[
                const SizedBox(height: 8),
                label!.label.maxLine(2).overflowEllipsis.color(ref.scheme.content50),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// eof

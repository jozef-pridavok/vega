import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeTableRow extends ConsumerWidget {
  final String? icon;
  final String label;
  final String? value;
  final String? iconValue;
  final void Function()? onIconValueTap;

  const MoleculeTableRow({
    this.icon,
    required this.label,
    this.value,
    this.iconValue,
    this.onIconValueTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          SizedBox(
            width: 24,
            height: 24,
            child: VegaIcon(name: icon!, color: ref.scheme.content),
          ),
          const SizedBox(width: 16),
        ],
        Container(child: label.text.maxLine(1).overflowEllipsis.color(ref.scheme.content)),
        if (value != null) ...[
          const SizedBox(width: 16),
          Expanded(child: value!.text.maxLine(2).alignRight.overflowEllipsis.color(ref.scheme.content50)),
        ],
        if (iconValue != null) ...[
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onIconValueTap,
            child: SizedBox(
              width: 24,
              height: 24,
              child: VegaIcon(name: iconValue!, color: ref.scheme.content50),
            ),
          ),
        ],
      ],
    );
    return row;
  }
}

// eof

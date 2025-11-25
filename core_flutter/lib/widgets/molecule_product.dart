import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../extensions/widget_ref.dart";
import "../themes/text.dart";
import "molecule_chip.dart";
import "molecule_items_basic.dart";

class MoleculeProduct extends ConsumerWidget {
  final String title;
  final String? label;
  final Widget? labelWidget;
  final String? value;
  final String? content;
  final Widget? image;
  final String? action;
  final void Function()? onAction;
  final bool actionActive;

  const MoleculeProduct({
    super.key,
    required this.title,
    this.label,
    this.labelWidget,
    this.value,
    this.content,
    this.image,
    this.action,
    this.onAction,
    this.actionActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.fromSize(
                  size: const Size(96, 96),
                  child: image,
                ),
              ),
              const SizedBox(width: 16),
            ],
            //if (image != null) image!,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: title.text.color(ref.scheme.content)),
                      if (value != null) ...[
                        const MoleculeItemHorizontalSpace(),
                        value!.text.color(ref.scheme.content),
                      ]
                    ],
                  ),
                  if (labelWidget != null || label != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: labelWidget ?? label.label.color(ref.scheme.content50),
                    ),
                  if (content != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: content!.label.color(ref.scheme.content),
                    ),
                ],
              ),
            ),
            //if (value != null) value!.text.color(ref.scheme.content),
          ],
        ),
        if (action != null) MoleculeChip(label: action!, onTap: onAction, active: actionActive),
      ],
    );
  }
}

// eof

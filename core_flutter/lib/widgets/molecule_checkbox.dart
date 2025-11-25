import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_theme.dart";
import "../core_widgets.dart";
import "../extensions/widget_ref.dart";

class MoleculeCheckBox extends ConsumerWidget {
  final String? title;
  final void Function(bool checked)? onChanged;
  final bool value;

  const MoleculeCheckBox({
    Key? key,
    this.title,
    this.onChanged,
    this.value = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkbox = Row(
      children: [
        VegaIcon(
          name: value ? AtomIcons.checkboxOn : AtomIcons.checkboxOff,
        ),
        if (title != null) ...[
          const SizedBox(width: 16),
          title!.text.color(ref.scheme.content),
        ],
      ],
    );
    if (onChanged == null) return checkbox;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged?.call(!value),
      child: checkbox,
    );
  }
}

// eof

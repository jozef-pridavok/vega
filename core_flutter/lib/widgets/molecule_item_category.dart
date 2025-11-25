import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_svg/svg.dart";

class MoleculeItemCategory extends ConsumerWidget {
  final String icon;
  final String title;
  final String? value;
  final bool applyColorFilter;
  final Function()? onAction;
  final bool showDetail;

  const MoleculeItemCategory({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    required this.onAction,
    this.applyColorFilter = true,
    this.showDetail = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAction,
      child: SizedBox(
        height: moleculeItemHeight,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: ref.scheme.primary,
              child: SvgPicture.asset("assets/images/ic_$icon.svg", width: 32, height: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.text.maxLine(1).overflowEllipsis.color(ref.scheme.content),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 16),
              value!.label.color(ref.scheme.content50),
            ],
            if (showDetail) ...[
              const SizedBox(width: 16),
              const VegaIcon(name: AtomIcons.chevronRight),
            ],
          ],
        ),
      ),
    );
  }
}

// eof

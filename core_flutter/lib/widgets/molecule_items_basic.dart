import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeItemSeparator extends ConsumerWidget {
  const MoleculeItemSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final row = Row(
      children: [
        Expanded(
          child: Container(height: 0.5, color: ref.scheme.content20), // height = 0.5
        ),
      ],
    );
    return row;
  }
}

class MoleculeItemSpace extends StatelessWidget {
  const MoleculeItemSpace({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: moleculeItemSpace);
  }
}

class MoleculeItemHorizontalSpace extends StatelessWidget {
  const MoleculeItemHorizontalSpace({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: moleculeItemSpace);
  }
}

class MoleculeItemDoubleSpace extends StatelessWidget {
  const MoleculeItemDoubleSpace({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: moleculeItemDoubleSpace);
  }
}

/// Molecules/Item-title
class MoleculeItemTitle extends ConsumerWidget {
  final String? icon;
  final String header;
  final String? action;
  final Function()? onAction;

  const MoleculeItemTitle({
    super.key,
    required this.header,
    this.icon,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: moleculusItemHeaderHeight,
      child: Row(
        children: [
          if (icon != null) ...[
            SizedBox(
              width: 36,
              height: 36,
              child: VegaIcon(name: icon!, color: ref.scheme.content50),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: header.toUpperCase().h4.maxLine(1).color(ref.scheme.content50)),
          if (action != null) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: action!.label.color(onAction != null ? ref.scheme.primary : ref.scheme.content50),
            )
          ],
        ],
      ),
    );
  }
}

/// Molecules/Item Basic
class MoleculeItemBasic extends ConsumerWidget {
  final String? icon;
  final Color? iconColor;
  final Color? avatarColor;
  final String title;
  final String? label;
  final String? actionIcon;
  final bool applyColorFilter;
  final Function()? onAction;
  final bool disableCompact;

  const MoleculeItemBasic({
    super.key,
    this.icon,
    this.iconColor,
    this.avatarColor,
    required this.title,
    this.label,
    this.actionIcon,
    this.onAction,
    this.applyColorFilter = true,
    this.disableCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = label == null; // && icon == null); // || compact;
    final itemHeight = isCompact && !disableCompact ? moleculeCompactItemHeight : moleculeItemHeight;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAction,
      child: MouseRegion(
        cursor: onAction != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: SizedBox(
          height: itemHeight,
          child: Row(
            children: [
              if (icon != null) ...[
                //VegaIcon(name: icon!),
                avatarColor != null
                    ? CircleAvatar(
                        backgroundColor: avatarColor,
                        child: VegaIcon(name: icon!, color: iconColor ?? ref.scheme.light),
                      )
                    : VegaIcon(name: icon!, applyColorFilter: applyColorFilter, color: iconColor),
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
              // TODO: photo here
              if (actionIcon != null) ...[const SizedBox(width: 16), VegaIcon(name: actionIcon!)],
            ],
          ),
        ),
      ),
    );
  }
}

// eof

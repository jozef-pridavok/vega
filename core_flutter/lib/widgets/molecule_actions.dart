import "package:flutter/material.dart" as material;
import "package:flutter/material.dart" hide Color;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_flutter.dart";

enum MoleculeActionType { primary, secondary, negative, positive }

extension _MoleculeActionTypeColors on MoleculeActionType {
  material.Color getForeground(MoleculeTheme theme) {
    switch (this) {
      case MoleculeActionType.primary:
        return theme.light;
      case MoleculeActionType.secondary:
        return theme.primary;
      case MoleculeActionType.negative:
        return theme.light;
      case MoleculeActionType.positive:
        return theme.light;
    }
  }

  material.Color getBackground(MoleculeTheme theme) {
    switch (this) {
      case MoleculeActionType.primary:
        return theme.primary;
      case MoleculeActionType.secondary:
        return theme.secondary;
      case MoleculeActionType.negative:
        return theme.negative;
      case MoleculeActionType.positive:
        return theme.positive;
    }
  }
}

class MoleculeAction {
  final String title;
  final MoleculeActionType type;
  final void Function()? onTap;

  const MoleculeAction({required this.title, this.type = MoleculeActionType.primary, this.onTap});

  factory MoleculeAction.primary({required String title, void Function()? onTap}) =>
      MoleculeAction(title: title, type: MoleculeActionType.primary, onTap: onTap);
  factory MoleculeAction.secondary({required String title, void Function()? onTap}) =>
      MoleculeAction(title: title, type: MoleculeActionType.secondary, onTap: onTap);
  factory MoleculeAction.positive({required String title, void Function()? onTap}) =>
      MoleculeAction(title: title, type: MoleculeActionType.positive, onTap: onTap);
  factory MoleculeAction.negative({required String title, void Function()? onTap}) =>
      MoleculeAction(title: title, type: MoleculeActionType.negative, onTap: onTap);
}

class MoleculeActions extends ConsumerWidget {
  final String? icon;
  final String title;
  final String? label;

  final String? primaryActionIcon;
  final void Function(TapUpDetails details)? onPrimaryAction;

  final List<MoleculeAction>? actions;

  const MoleculeActions({
    this.icon,
    required this.title,
    this.label,
    this.actions,
    this.primaryActionIcon,
    this.onPrimaryAction,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                VegaIcon(name: icon!, color: ref.scheme.content),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title.text.maxLine(1).overflowEllipsis.color(ref.scheme.content),
                    if (label?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      label!.label.maxLine(2).overflowEllipsis.color(ref.scheme.content50),
                    ],
                  ],
                ),
              ),
              if (primaryActionIcon != null) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTapUp: (details) => onPrimaryAction?.call(details),
                  //onTap: onPrimaryAction,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: VegaIcon(name: primaryActionIcon!, color: ref.scheme.primary),
                  ),
                ),
              ],
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 16,
              runSpacing: 16,
              children: actions!.reversed
                  .map((action) => MoleculeActionChip(label: action.title, type: action.type, onTap: action.onTap))
                  .toList(),
            ),
          ]
        ],
      ),
    );
  }
}

class MoleculeActionChip extends ConsumerWidget {
  final MoleculeActionType type;
  final String label;
  final void Function()? onTap;

  const MoleculeActionChip({super.key, required this.type, required this.label, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: type.getBackground(ref.scheme),
            borderRadius: BorderRadius.circular(16),
          ),
          child: material.Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
            child: label.label.alignCenter.maxLine(1).color(type.getForeground(ref.scheme)),
          ),
        ),
      ),
    );
  }
}

// eof

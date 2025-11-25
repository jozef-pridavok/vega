import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

/// Molecules/Item Toggle
class MoleculeItemToggle extends ConsumerStatefulWidget {
  final String? icon;
  final String title;
  final String? label;
  final bool on;
  final Function(bool on)? onChanged;

  const MoleculeItemToggle({
    super.key,
    this.icon,
    required this.title,
    this.label,
    this.onChanged,
    this.on = false,
  });

  @override
  createState() => _MoleculusItemToggleState();
}

class _MoleculusItemToggleState extends ConsumerState<MoleculeItemToggle> {
  String? get icon => widget.icon;
  String get title => widget.title;
  String? get label => widget.label;
  Function(bool)? get onChanged => widget.onChanged;
  late bool on;

  @override
  void initState() {
    super.initState();
    on = widget.on;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // TODO: niekde tu lietajú 3px navyše, treba to opraviť
      height: moleculeItemHeight + 3,
      child: Row(
        children: [
          if (icon != null) ...[
            VegaIcon(name: icon!),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.text.maxLine(3).color(ref.scheme.content),
                if (label != null) ...[
                  if (label != null) ...[
                    const SizedBox(height: 8),
                    label!.label.color(ref.scheme.content50),
                  ]
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          CupertinoSwitch(
            //activeTrackColor: ref.scheme.positive,
            activeColor: ref.scheme.positive,
            //inactiveTrackColor: ref.scheme.content50,
            //inactiveThumbColor: ref.scheme.content20,
            value: on,
            onChanged: onChanged != null
                ? (bool value) {
                    setState(() => on = value);
                    onChanged?.call(value);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// eof

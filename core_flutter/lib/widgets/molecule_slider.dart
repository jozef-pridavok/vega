import "package:core_flutter/extensions/widget_ref.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeSlider extends ConsumerWidget {
  final double initialValue;
  final double min;
  final double max;
  final int? divisions;

  final ValueChanged<double>? onChanged;

  const MoleculeSlider({
    this.initialValue = 0,
    this.min = 0,
    this.max = 100,
    this.divisions = 5,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slider(
      value: initialValue,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: (double value) => onChanged?.call(value),
      activeColor: ref.scheme.primary,
      inactiveColor: ref.scheme.paperBold,
    );
  }
}

// eof

import "package:core_flutter/core_dart.dart" as core;
import "package:core_flutter/core_flutter.dart";
import "package:flex_color_picker/flex_color_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeColorPicker extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final core.Color? initialValue;
  final Function(core.Color? selectedColor) onChanged;

  const MoleculeColorPicker({
    super.key,
    required this.title,
    required this.hint,
    this.initialValue,
    required this.onChanged,
  });

  @override
  createState() => _MoleculeColorPickerState();
}

class _MoleculeColorPickerState extends ConsumerState<MoleculeColorPicker> {
  final TextEditingController _controller = TextEditingController();
  late Color? _selectedColor;

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: _selectedColor ?? ref.scheme.primary,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => _selectedColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 250,
      //showMaterialName: true,
      //showColorName: true,
      showColorCode: true,
      colorCodeTextStyle: AtomStyles.labelText,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(copyFormat: ColorPickerCopyFormat.hexRRGGBB),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints: const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialValue?.toMaterial();
    //Future.microtask(_updateController);
  }

  @override
  Widget build(BuildContext context) {
    return MoleculeInputStack(
      title: widget.title,
      hint: widget.hint,
      controller: _controller,
      over: _selectedColor == null
          ? null
          : MoleculeChip(
              label: _selectedColor!.toCore().toHex(),
              backgroundColor: _selectedColor,
              active: true,
              onTap: () async {
                final picked = await colorPickerDialog();
                if (picked) {
                  //_selectedColor = picked;
                  //_updateController();
                  widget.onChanged(_selectedColor!.toCore());
                }
              },
            ),
      suffixIcon: VegaIcon(name: "chevron_down"),
      onTap: () async {
        final picked = await colorPickerDialog();
        widget.onChanged(picked ? _selectedColor!.toCore() : null);
      },
    );
  }
}

// eof

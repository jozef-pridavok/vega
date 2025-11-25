import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculeDatePicker extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime date)? onChanged;
  final Function(DateTime? date)? onChangedOrNull;
  final bool enabled;

  const MoleculeDatePicker({
    super.key,
    required this.title,
    required this.hint,
    this.initialValue,
    this.onChanged,
    this.onChangedOrNull,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  }) : assert(onChanged != null || onChangedOrNull != null);

  @override
  createState() => _MoleculeDatePickerState();
}

class _MoleculeDatePickerState extends ConsumerState<MoleculeDatePicker> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;

  void _updateController([bool callSetState = true]) {
    _controller.text = formatDate(context.languageCode, _selectedDate) ?? "";
    if (callSetState) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
    Future.microtask(() => _updateController(false));
  }

  @override
  Widget build(BuildContext context) {
    final showClearButton = widget.onChangedOrNull != null && _selectedDate != null;
    return MoleculeInput(
      title: widget.title,
      hint: widget.hint,
      controller: _controller,
      enableInteractiveSelection: false,
      readOnly: true,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showClearButton)
            IconButton(
              icon: VegaIcon(name: AtomIcons.cancel, size: 24),
              onPressed: () => _onTap(cancel: true),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: VegaIcon(name: AtomIcons.chevronDown, size: 36),
            padding: EdgeInsets.zero,
            //visualDensity: VisualDensity.compact,
            onPressed: () => _onTap(),
          ),
          //VegaIcon(name: AtomIcons.chevronDown),
        ],
      ),
      //VegaIcon(name: AtomIcons.chevronDown, size: 24)
      suffixIconConstraints: BoxConstraints.tightFor(
        width: (showClearButton ? (36 + 16) : 0) + 36 + 16,
        height: 36,
      ),
      onTap: () => _onTap(),

      enabled: widget.enabled,
    );
  }

  Future<void> _onTap({bool cancel = false}) async {
    if (cancel) {
      _selectedDate = null;
      _updateController();
      widget.onChangedOrNull!(null);
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialValue ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      _selectedDate = picked;
      _updateController();
      widget.onChanged?.call(picked);
      widget.onChangedOrNull?.call(picked);
    }
  }
}

// eof

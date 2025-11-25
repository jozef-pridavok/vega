import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_extensions.dart";
import "../core_theme.dart";

/// Molecules/Input
class MoleculeInput extends ConsumerWidget {
  final String? title;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? inputAction;
  final TextCapitalization capitalization;
  final TextInputType? inputType;
  final bool enabled;
  final bool readOnly;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  // https://chat.openai.com/share/2dafada7-29b0-48f0-a588-20897a8d22d2
  //final void Function(String)? onDebouncedChanged;
  final void Function()? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final String? prefixText;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final String? suffixText;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final bool obscureText;
  final bool focusable;
  final bool? enableInteractiveSelection;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;
  const MoleculeInput({
    this.title,
    this.hint,
    this.focusNode,
    this.controller,
    this.inputAction,
    this.capitalization = TextCapitalization.none,
    this.inputType,
    this.enabled = true,
    this.readOnly = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection,
    this.initialValue,
    this.validator,
    this.onChanged,
    //this.onDebouncedChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.onSaved,
    this.prefixText,
    this.prefixIcon,
    this.prefixIconConstraints = const BoxConstraints.tightFor(
      width: 36 + 16,
      height: 36,
    ),
    this.suffixText,
    this.suffixIcon,
    this.suffixIconConstraints = const BoxConstraints.tightFor(
      width: 36 + 16,
      height: 36,
    ),
    this.obscureText = false,
    this.focusable = true,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.autovalidateMode,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          title!.label.color(ref.scheme.content),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: inputAction,
          textCapitalization: capitalization,
          keyboardType: inputType,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          enableInteractiveSelection: enableInteractiveSelection,
          obscureText: obscureText,
          decoration: defaultInputDecoration(
            ref.scheme,
            enabled: enabled,
            hint: hint,
            focusable: focusable,
            prefixText: prefixText,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixText: suffixText,
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIconConstraints,
          ),
          enabled: enabled,
          readOnly: readOnly,
          initialValue: initialValue,
          validator: validator,
          style: AtomStyles.text.copyWith(color: ref.scheme.content),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          onTap: onTap,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode,
          autofocus: autofocus,
        ),
      ],
    );
  }
}

class MoleculeInputStack extends ConsumerWidget {
  final String? title;
  final String? hint;
  final Widget? over;
  final TextEditingController? controller;
  final bool enabled;
  final void Function()? onTap;
  final String? prefixText;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final String? suffixText;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final bool focusable;
  const MoleculeInputStack({
    this.title,
    this.hint,
    this.over,
    this.controller,
    this.enabled = true,
    this.onTap,
    this.prefixText,
    this.prefixIcon,
    this.prefixIconConstraints = const BoxConstraints.tightFor(
      width: 36 + 16,
      height: 36,
    ),
    this.suffixText,
    this.suffixIcon,
    this.suffixIconConstraints = const BoxConstraints.tightFor(
      width: 36 + 16,
      height: 36,
    ),
    this.focusable = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          title!.label.color(ref.scheme.content),
          const SizedBox(height: 8),
        ],
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextFormField(
              controller: controller,
              decoration: defaultInputDecoration(
                ref.scheme,
                hint: over == null ? hint : null,
                focusable: focusable,
                prefixText: prefixText,
                prefixIcon: prefixIcon,
                prefixIconConstraints: prefixIconConstraints,
                suffixText: suffixText,
                suffixIcon: suffixIcon,
                suffixIconConstraints: suffixIconConstraints,
              ),
              enabled: enabled,
              readOnly: true,
              style: AtomStyles.text.copyWith(color: ref.scheme.content),
              onTap: onTap,
            ),
            if (over != null)
              Padding(
                padding: const EdgeInsets.only(left: moleculeScreenPadding),
                child: over!,
              ),
          ],
        ),
      ],
    );
  }
}


// eof

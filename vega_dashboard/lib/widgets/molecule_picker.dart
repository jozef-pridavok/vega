import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../strings.dart";

class MoleculeSingleSelect extends ConsumerWidget {
  final String? title;
  final String hint;
  final List<SelectItem> items;
  final SelectItem? selectedItem;
  final Function(SelectItem selectedItem)? onChanged;
  final Function(SelectItem? selectedItem)? onChangedOrClear;
  //final Future<bool> Function(SelectItem? prevItem, SelectItem? nextItem)? onBeforeChange;
  final bool enabled;

  const MoleculeSingleSelect({
    super.key,
    this.title,
    required this.hint,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.onChangedOrClear,
    this.enabled = true,
  }) : assert(onChanged != null || onChangedOrClear != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: title.label.color(ref.scheme.content),
          ),
        DropdownSearch<SelectItem>(
          compareFn: (item, selectedItem) => item == selectedItem,
          dropdownButtonProps: DropdownButtonProps(
            color: ref.scheme.content20,
            icon: VegaIcon(name: "chevron_down", size: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: AtomStyles.text,
            dropdownSearchDecoration: defaultInputDecoration(
              ref.scheme,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              hint: hint,
              hintStyle: AtomStyles.text.copyWith(color: ref.scheme.content),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchDelay: fastRefreshDuration,
            searchFieldProps: TextFieldProps(
              decoration: defaultInputDecoration(
                ref.scheme,
                hint: LangKeys.hintSearchHere.tr(),
                focusable: true,
              ),
            ),
            showSelectedItems: true,
          ),
          clearButtonProps: ClearButtonProps(
            isVisible: onChangedOrClear != null,
            color: ref.scheme.content20,
            icon: VegaIcon(name: AtomIcons.cancel, size: 24),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          items: items,
          //onBeforeChange: onBeforeChange != null ? (prevItem, nextItem) => onBeforeChange!(prevItem, nextItem) : null,
          onChanged: (value) => onChangedOrClear != null ? onChangedOrClear!(value) : onChanged!(value!),
          selectedItem: selectedItem,
          enabled: enabled,
        ),
      ],
    );
  }
}

class MoleculeMultiSelect extends ConsumerWidget {
  final String title;
  final String hint;
  final List<SelectItem> items;
  final List<SelectItem> selectedItems;
  final Function(List<SelectItem> selectedItems)? onChanged;
  //final Function(SelectItem? selectedItem)? onChangedOrClear;
  final int maxSelectedItems;
  final bool clearable;

  const MoleculeMultiSelect({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    this.selectedItems = const [],
    required this.onChanged,
    this.maxSelectedItems = 3,
    this.clearable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: title.label.color(ref.scheme.content),
        ),
        DropdownSearch<SelectItem>.multiSelection(
          compareFn: (item, selectedItem) => item == selectedItem,
          dropdownBuilder: (context, selectedItems) {
            if (selectedItems.isEmpty) return hint.text.color(ref.scheme.content);
            final head = selectedItems.take(maxSelectedItems).toList();
            final remaining = selectedItems.length - head.length;
            return Wrap(
              spacing: 8,
              children: head
                      .map(
                        (item) => MoleculeChip(
                          label: item.label,
                          // TODO: tu je problém zavolať removeItem, pozri _defaultSelectedItemWidget
                          //onClose: () => print("onTap"),
                        ),
                      )
                      .toList() +
                  [if (remaining > 0) MoleculeChip(label: "+$remaining", active: true)],
            );
          },
          dropdownButtonProps: DropdownButtonProps(
            color: ref.scheme.content20,
            icon: VegaIcon(name: "chevron_down", size: 36),
            iconSize: 36,
            padding: EdgeInsets.zero,
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: AtomStyles.text,
            dropdownSearchDecoration: defaultInputDecoration(
              ref.scheme,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              hint: hint,
            ),
          ),
          popupProps: PopupPropsMultiSelection.menu(
            showSearchBox: true,
            searchDelay: fastRefreshDuration,
            selectionWidget: (context, item, isSelected) {
              return Padding(
                padding: const EdgeInsets.only(right: moleculeScreenPadding),
                child: VegaIcon(
                  name: isSelected ? "checkbox_done" : "checkbox",
                  color: ref.scheme.content,
                ),
              );
            },
            searchFieldProps: TextFieldProps(
              decoration: defaultInputDecoration(
                ref.scheme,
                hint: LangKeys.hintSearchHere.tr(),
                focusable: true,
              ),
            ),
            showSelectedItems: true,
            //disabledItemFn: (String s) => s.startsWith("I"),
          ),
          clearButtonProps: ClearButtonProps(
            isVisible: clearable,
            color: ref.scheme.content20,
            icon: VegaIcon(name: AtomIcons.cancel, size: 24),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          items: items,
          onChanged: onChanged,
          selectedItems: selectedItems,
        ),
      ],
    );
  }
}

// eof

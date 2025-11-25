import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_dashboard/widgets/molecule_picker_color.dart";
import "package:vega_dashboard/widgets/molecule_picker_date.dart";

import "../../widgets/molecule_picker.dart";
import "../screen_app.dart";

extension CountrySelectItem on Country {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code);
}

extension CountriesSelectedItems on List<Country> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension DaySelectItem on Day {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code);
}

extension DaysSelectedItems on List<Day> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

class PickersScreen extends VegaScreen {
  const PickersScreen({super.key});

  @override
  createState() => _PickersScreenState();
}

class _PickersScreenState extends VegaScreenState<PickersScreen> {
  @override
  String? getTitle() => "Pickers";

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: MoleculeInput(title: "Title", hint: "Hint", initialValue: "My value")),
                const MoleculeItemHorizontalSpace(),
                Expanded(
                  child: MoleculeDatePicker(
                    title: "Date picker",
                    hint: "Hint",
                    onChanged: (selectedDate) => print(selectedDate),
                  ),
                ),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Expanded(
                  child: MoleculeSingleSelect(
                    title: "Single select",
                    hint: "Hint",
                    items: Country.values.toSelectItems(),
                    selectedItem: Country.czechia.toSelectItem(),
                    onChangedOrClear: (selectedItem) => toastInfo(selectedItem?.label ?? "null"),
                  ),
                ),
                const MoleculeItemHorizontalSpace(),
                Expanded(
                  child: MoleculeMultiSelect(
                    title: "Multi select (Days)",
                    hint: "Hint",
                    items: Day.values.toSelectItems(),
                    maxSelectedItems: 2,
                    selectedItems: [Day.monday, Day.tuesday, Day.wednesday, Day.thursday, Day.friday].toSelectItems(),
                    onChanged: (selectedItems) => toastInfo(selectedItems.map((e) => e.label).join(", ")),
                  ),
                ),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Expanded(
                  child: MoleculeColorPicker(
                    title: "Color picker",
                    hint: "Hint",
                    onChanged: (selectedColor) => toastInfo(
                      selectedColor?.toHex() ?? "null",
                    ),
                    //initialValue: Color.fromHex("#AABBCC"),
                  ),
                ),
                const MoleculeItemHorizontalSpace(),
                Expanded(
                  child: MoleculeMultiSelect(
                    title: "Multi select (Countries)",
                    hint: "Hint",
                    items: Country.values.toSelectItems(),
                    maxSelectedItems: 3,
                    selectedItems: [Country.slovakia, Country.paraguay, Country.uruguay].toSelectItems(),
                    onChanged: (selectedItems) => toastInfo(selectedItems.map((e) => e.label).join(", ")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// eof

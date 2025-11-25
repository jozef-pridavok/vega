import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/widgets/map_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/location_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "screen_edit.dart";

extension LocationContact on LocationEditState {
  Widget buildContactMobileLayout(WidgetRef ref) {
    final state = cast<LocationEditorEditing>(ref.read(locationEditorLogic));
    final location = state?.location;
    return Form(
      key: formKeys[0],
      autovalidateMode: AutovalidateMode.always,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildName(),
            const MoleculeItemSpace(),
            _buildType(location),
            const MoleculeItemSpace(),
            _buildDescription(),
            const MoleculeItemSpace(),
            SizedBox(height: 300, child: _buildMap(location)),
            const MoleculeItemSpace(),
            _buildAddress1(),
            const MoleculeItemSpace(),
            _buildAddress2(),
            const MoleculeItemSpace(),
            Row(
              children: [
                Expanded(child: _buildZip(), flex: 1),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildCity(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            _buildCountry(),
            const MoleculeItemSpace(),
            _buildPhone(),
            const MoleculeItemSpace(),
            _buildEmail(),
            const MoleculeItemSpace(),
            _buildWeb(),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  Widget buildContactDefaultLayout(WidgetRef ref) {
    final state = cast<LocationEditorEditing>(ref.read(locationEditorLogic));
    final location = state?.location;
    return Form(
      key: formKeys[0],
      autovalidateMode: AutovalidateMode.always,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildName()),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildType(location)),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDescription()),
              ],
            ),
            const MoleculeItemSpace(),
            SizedBox(
              height: 400,
              child: Row(
                children: [
                  Expanded(child: _buildMap(location)),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAddress1()),
                        const MoleculeItemSpace(),
                        Expanded(child: _buildAddress2()),
                        const MoleculeItemSpace(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildZip()),
                            const MoleculeItemHorizontalSpace(),
                            Expanded(child: _buildCity()),
                          ],
                        ),
                        const MoleculeItemSpace(),
                        Expanded(child: _buildCountry()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPhone()),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildEmail()),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildWeb()),
              ],
            ),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildType(Location? location) => MoleculeSingleSelect(
        title: LangKeys.labelType.tr(),
        hint: "",
        items: LocationType.values.toSelectItems(),
        selectedItem: location?.type.toSelectItem(),
        onChanged: (selectedItem) {
          pickedType = LocationTypeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: descriptionController,
        maxLines: 4,
        onChanged: (value) {
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildMap(Location? location) => MapPickerWidget(
        initial: GeoPoint(latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0),
        onChanged: (point) {
          notifyUnsaved(notificationsTag);
          latitude = point.latitude;
          longitude = point.longitude;
        },
        showMapControls: true,
      );

  Widget _buildAddress1() => MoleculeInput(
        title: LangKeys.labelAddressLine1.tr(),
        controller: address1Controller,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildAddress2() => MoleculeInput(
        title: LangKeys.labelAddressLine2.tr(),
        controller: address2Controller,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildZip() => MoleculeInput(
        title: LangKeys.labelZip.tr(),
        controller: zipController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildCity() => MoleculeInput(
        title: LangKeys.labelCity.tr(),
        controller: cityController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildCountry() => MoleculeInput(
        title: LangKeys.labelCountry.tr(),
        controller: countryController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildPhone() => MoleculeInput(
        title: LangKeys.labelPhone.tr(),
        controller: phoneController,
        validator: (value) {
          if (value == null || value.isEmpty || isPhoneNumber(value)) return null;
          return LangKeys.validationPhoneInvalidFormat.tr();
        },
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildEmail() => MoleculeInput(
        title: LangKeys.labelEmail.tr(),
        controller: emailController,
        validator: (value) {
          if (value == null || value.isEmpty || isEmail(value)) return null;
          return LangKeys.validationEmailInvalidFormat.tr();
        },
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildWeb() => MoleculeInput(
        title: LangKeys.labelWeb.tr(),
        controller: webController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );
}

// eof

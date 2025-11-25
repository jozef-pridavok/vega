import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../extensions/select_item.dart";
import "../../states/client_settings.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "screen_settings.dart";

extension ContactClientSettings on ClientSettingsScreenState {
  Widget buildContactMobileLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[1],
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemSpace(),
            LangKeys.contactDetailsInfo.tr().text.alignCenter,
            const MoleculeItemSpace(),
            _buildPhone(),
            const MoleculeItemSpace(),
            _buildEmail(),
            const MoleculeItemSpace(),
            _buildWeb(),
            const MoleculeItemSpace(),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: LangKeys.descriptionLanguageInfo.tr().label,
                ),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildDescriptionLanguage()),
              ],
            ),
            _buildDescription(),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  Widget buildContactDefaultLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[1],
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LangKeys.contactDetailsInfo.tr().text,
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildPhone()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildEmail()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildWeb()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: LangKeys.descriptionLanguageInfo.tr().label,
                ),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildDescriptionLanguage()),
              ],
            ),
            const MoleculeItemSpace(),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhone() => MoleculeInput(
        title: LangKeys.labelPhone.tr(),
        controller: phoneController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) =>
            ((val?.isEmpty ?? true) || isPhoneNumber(val ?? "")) ? null : LangKeys.validationPhoneInvalidFormat.tr(),
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildEmail() => MoleculeInput(
        title: LangKeys.labelEmail.tr(),
        controller: emailController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) =>
            ((val?.isEmpty ?? true) || isEmail(val ?? "")) ? null : LangKeys.validationEmailInvalidFormat.tr(),
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildWeb() => MoleculeInput(
        title: LangKeys.labelWeb.tr(),
        controller: webController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: descriptionLocalizedController,
        maxLines: 3,
        onChanged: (value) {
          localizedDescription[languageController.text] = value;
          notifyUnsaved(notificationTag);
        },
      );

  Widget _buildDescriptionLanguage() {
    return MoleculeSingleSelect(
      title: LangKeys.descriptionLanguageInfo.tr(),
      hint: "",
      items: context.supportedLocales.toSelectItems(),
      selectedItem: language?.toSelectItem(),
      onChanged: (selectedItem) {
        language = LocaleSelectItem.from(selectedItem);
        final client = cast<ClientSettingsEditing>(ref.read(clientSettingsLogic))?.client;
        descriptionLocalizedController.text =
            localizedDescription[selectedItem.value] ?? client!.getDescription(selectedItem.value);
        notifyUnsaved(notificationTag);
      },
    );
  }
}

// eof

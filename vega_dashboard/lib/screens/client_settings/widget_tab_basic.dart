import "dart:typed_data";

import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../widgets/molecule_picker_color.dart";
import "screen_settings.dart";

extension BasicClientSettings on ClientSettingsScreenState {
  Widget buildBasicSettingsMobileLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildName(),
            const MoleculeItemSpace(),
            _buildColor(),
            const MoleculeItemSpace(),
            _buildImage(),
            const MoleculeItemSpace(),
            _buildDescription(),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  Widget buildBasicSettingsDefaultLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildName()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildColor()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildImage(),
                  flex: 1,
                ),
                const MoleculeItemHorizontalSpace(),
                Expanded(
                  child: _buildDescription(),
                  flex: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelCompanyName.tr(),
        controller: nameController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => (val?.isEmpty ?? true) ? LangKeys.validationNameRequired.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildColor() {
    return MoleculeColorPicker(
      title: LangKeys.labelColor.tr(),
      hint: LangKeys.hintPickColor.tr(),
      initialValue: color,
      onChanged: (newColor) {
        if (newColor == null) return;
        color = newColor;
        //colorController.text = newColor.toHex();
        refresh();
        notifyUnsaved(notificationTag);
      },
    );
  }

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildImage() {
    return GestureDetector(
      onTap: () => _pickFile(),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          decoration: moleculeShadowDecoration(color.toMaterial()),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: IndexedStack(
                index: loadingImage ? 0 : 1,
                alignment: Alignment.center,
                children: [
                  const CenteredWaitIndicator(),
                  newImage != null
                      ? Image.memory(Uint8List.fromList(newImage!), fit: BoxFit.contain)
                      : oldLogo != null
                          ? Image.network(
                              oldLogo!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => SvgAsset.logo(),
                            )
                          : LangKeys.hintClickToSetImage.tr().text.alignCenter,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    refresh(() => loadingImage = true);
    final image = await ImagePicker().pickImage(width: 512, height: 512);
    if (image == null) return refresh(() => loadingImage = false);
    newImage = image.toList();
    refresh(() => loadingImage = false);
    notifyUnsaved(notificationTag);
  }
}

// eof

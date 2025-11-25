import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";

class EditSectionWidget extends ConsumerStatefulWidget {
  final String offerId;
  final ProductSection? sectionToEdit;
  final bool isNew;
  EditSectionWidget({super.key, required this.offerId, this.sectionToEdit}) : isNew = sectionToEdit == null;

  @override
  createState() => _EditSectionWidgetState();
}

class _EditSectionWidgetState extends ConsumerState<EditSectionWidget> {
  late String offerId;
  late ProductSection? sectionToEdit;
  late bool isNew;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isNew = widget.isNew;
    offerId = widget.offerId;
    sectionToEdit = widget.sectionToEdit;
    Future.microtask(() {
      _nameController.text = sectionToEdit?.name ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LangKeys.labelEnterSectionName.tr().h3],
            ),
            const MoleculeItemSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildName()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCloseButton(context),
                const MoleculeItemHorizontalSpace(),
                _buildEditSectionButton(context, ref),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName() => MoleculeInput(
        controller: _nameController,
        hint: isNew ? LangKeys.hintNewSection.tr() : "",
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
      );

  Widget _buildCloseButton(BuildContext context) {
    return MoleculeSecondaryButton(
      titleText: LangKeys.buttonCloseWindow.tr(),
      onTap: () {
        context.pop();
      },
    );
  }

  Widget _buildEditSectionButton(BuildContext context, WidgetRef ref) {
    return MoleculePrimaryButton(
      titleText: isNew ? LangKeys.buttonAddSection.tr() : LangKeys.buttonRenameSection.tr(),
      onTap: () {
        if (!_formKey.currentState!.validate()) return;
        if (sectionToEdit == null) {
          final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
          final section = ProductSection(
            sectionId: uuid(),
            clientId: client.clientId,
            offerId: offerId,
            name: _nameController.text,
          );
          ref.read(productSectionEditorLogic.notifier).edit(section, isNew: true);
          ref.read(productSectionEditorLogic.notifier).save();
        } else {
          ref.read(productSectionEditorLogic.notifier).edit(sectionToEdit!);
          ref.read(productSectionEditorLogic.notifier).save(name: _nameController.text);
        }
        if (isNew) context.pop();
        showWaitDialog(context, ref, isNew ? LangKeys.toastCreatingSection.tr() : LangKeys.toastRenamingSection.tr());
      },
    );
  }
}

import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/user/address_editor.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "../screen_app.dart";

class EditAddressScreen extends AppScreen {
  const EditAddressScreen({super.key});

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends AppScreenState<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isNew = false;

  final _nameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _updateControllers());
  }

  void _updateControllers() {
    final editing = ref.read(userAddressEditorLogic) as UserAddressEditing;
    isNew = editing.isNew;
    _nameController.text = editing.address.name;
    _addressLine1Controller.text = editing.address.addressLine1 ?? "";
    _addressLine2Controller.text = editing.address.addressLine2 ?? "";
    _cityController.text = editing.address.city ?? "";
    _zipController.text = editing.address.zip ?? "";
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenAddress.tr(),
        cancel: true,
      );

  void _listenToUserAddressEditorLogic(BuildContext context) {
    ref.listen<UserAddressState>(userAddressEditorLogic, (previous, state) {
      if (state is UserAddressSavingFailed) {
        final error = state.error;
        ref.read(toastLogic.notifier).error(error.message);
        Future.delayed(stateRefreshDuration, () => ref.read(userAddressEditorLogic.notifier).reedit());
      } else if (state is UserAddressDeletingFailed) {
        final error = state.error;
        ref.read(toastLogic.notifier).error(error.message);
        Future.delayed(stateRefreshDuration, () => ref.read(userAddressEditorLogic.notifier).reset());
      } else if (state is UserAddressSaved) {
        Future.delayed(stateRefreshDuration, () => ref.read(userAddressEditorLogic.notifier).reset());
        ref.read(userAddressesLogic.notifier).refresh();
        ref.read(toastLogic.notifier).info(LangKeys.operationSuccessful.tr());
        context.pop();
      } else if (state is UserAddressDeleted) {
        Future.delayed(stateRefreshDuration, () => ref.read(userAddressEditorLogic.notifier).reset());
        ref.read(userAddressesLogic.notifier).refresh();
        ref.read(toastLogic.notifier).info(LangKeys.operationSuccessful.tr());
        // 2x pop to close the modal dialog and this screen
        context.pop();
        context.pop();
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToUserAddressEditorLogic(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MoleculeInput(
                  controller: _nameController,
                  title: LangKeys.labelAddressName.tr(),
                  hint: LangKeys.hintAddressName.tr(),
                  capitalization: TextCapitalization.sentences,
                  inputAction: TextInputAction.next,
                  validator: (val) => val?.isEmpty ?? true ? LangKeys.validationNameRequired.tr() : null,
                  onChanged: (val) => _nameController.text = val,
                ),
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _addressLine1Controller,
                  title: LangKeys.labelAddressLine1Name.tr(),
                  hint: LangKeys.hintAddressLine1.tr(),
                  capitalization: TextCapitalization.words,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.streetAddress,
                  onChanged: (val) => _addressLine1Controller.text = val,
                ),
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _addressLine2Controller,
                  title: LangKeys.labelAddressLine2Name.tr(),
                  hint: LangKeys.hintAddressLine2.tr(),
                  capitalization: TextCapitalization.words,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.streetAddress,
                  validator: (val) => val?.isEmpty ?? true ? LangKeys.validationAddressLine2Required.tr() : null,
                  onChanged: (val) => _addressLine2Controller.text = val,
                ),
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _zipController,
                  title: LangKeys.labelAddressZip.tr(),
                  hint: LangKeys.hintAddressZip.tr(),
                  capitalization: TextCapitalization.characters,
                  inputAction: TextInputAction.next,
                  enableSuggestions: false,
                  onChanged: (val) => _zipController.text = val,
                ),
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _cityController,
                  title: LangKeys.labelAddressCity.tr(),
                  hint: LangKeys.hintAddressCity.tr(),
                  capitalization: TextCapitalization.words,
                  inputAction: TextInputAction.done,
                  validator: (val) => val?.isEmpty ?? true ? LangKeys.validationCityRequired.tr() : null,
                  onChanged: (val) => _cityController.text = val,
                ),
                const MoleculeItemSpace(),
                MoleculeActionButton(
                  title: isNew ? LangKeys.buttonCreateAddress.tr() : LangKeys.buttonConfirm.tr(),
                  successTitle: LangKeys.operationSuccessful.tr(),
                  failTitle: LangKeys.operationFailed.tr(),
                  buttonState: ref.watch(userAddressEditorLogic).buttonState,
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    ref.read(userAddressEditorLogic.notifier).save(
                          name: _nameController.text,
                          addressLine1: _addressLine1Controller.text.isEmpty ? null : _addressLine1Controller.text,
                          addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
                          city: _cityController.text.isEmpty ? null : _cityController.text,
                          zip: _zipController.text.isEmpty ? null : _zipController.text,
                        );
                  },
                ),
                const MoleculeItemSpace(),
                if (!isNew) ...[
                  MoleculeSecondaryButton(
                    titleText: "button_delete_address".tr(),
                    onTap: () => _askToDeleteAddress(context),
                    color: ref.scheme.negative,
                  ),
                  const MoleculeItemSpace(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _askToDeleteAddress(BuildContext context) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogDeleteAddressTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogDeleteAddressMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Consumer(
                builder: (BuildContext _, WidgetRef ref, Widget? child) {
                  return MoleculeActionButton(
                    title: "button_delete_address".tr(),
                    onPressed: () => ref.read(userAddressEditorLogic.notifier).delete(),
                    successTitle: LangKeys.operationSuccessful.tr(),
                    failTitle: LangKeys.operationFailed.tr(),
                    buttonState: ref.watch(userAddressEditorLogic).buttonState,
                    color: ref.scheme.negative,
                  );
                },
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: LangKeys.buttonClose.tr(),
                onTap: () => context.pop(),
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }
}

// eof

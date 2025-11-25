import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/src/consumer.dart";

import "../../extensions/select_item.dart";
import "../../states/locations.dart";
import "../../states/product_offer_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditProductOffer extends VegaScreen {
  const EditProductOffer({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditProductOffer> {
  final notificationsTag = "a47b3fdf-f7be-4da6-8c41-07bf2c98280f";

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  IntDate? _date;
  ProductOfferType? _type;
  LoyaltyMode? _loyaltyMode;
  String? _locationId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productOffer = cast<ProductOfferEditorEditing>(ref.read(productOfferEditorLogic))?.productOffer;
      if (productOffer == null) return;
      _nameController.text = productOffer.name;
      _descriptionController.text = productOffer.description ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductOfferEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    final watchedLogic = cast<ProductOfferEditorEditing>(ref.watch(productOfferEditorLogic));
    final productOffer = watchedLogic!.productOffer;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () async {},
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: isMobile ? _mobileLayout(productOffer) : _defaultLayout(productOffer),
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void _listenToLogic() {
    ref.listen<ProductOfferEditorState>(productOfferEditorLogic, (previous, next) {
      if (next is ProductOfferEditorFailed) {
        toastCoreError(next.error);
        Future.delayed(stateRefreshDuration, () => ref.read(productOfferEditorLogic.notifier).reedit());
      } else if (previous is ProductOfferEditorSaving && next is ProductOfferEditorSucceed) {
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(productOfferEditorLogic.notifier).edit(next.productOffer);
        dismissUnsaved(notificationsTag);
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout(ProductOffer productOffer) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildType(productOffer)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDate(productOffer)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLocation(productOffer)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildLoyaltyMode(productOffer)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _defaultLayout(ProductOffer productOffer) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildType(productOffer)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDate(productOffer)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLocation(productOffer)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildLoyaltyMode(productOffer)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: _nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildType(ProductOffer? productOffer) => MoleculeSingleSelect(
        title: LangKeys.labelType.tr(),
        hint: "",
        items: ProductOfferType.values.toSelectItems(),
        selectedItem: productOffer?.type.toSelectItem(),
        onChanged: (selectedItem) {
          _type = ProductOfferTypeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildDate(ProductOffer? productOffer) => MoleculeDatePicker(
        title: LangKeys.labelDate.tr(),
        hint: LangKeys.hintDate.tr(),
        initialValue: productOffer?.date.toLocalDate(),
        onChanged: (selectedDate) {
          _date = IntDate.fromDate(selectedDate);
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildLoyaltyMode(ProductOffer? productOffer) => MoleculeSingleSelect(
        title: LangKeys.labelLoyaltyMode.tr(),
        hint: "",
        items: LoyaltyMode.values.toSelectItems(),
        selectedItem: productOffer?.loyaltyMode.toSelectItem(),
        onChanged: (selectedItem) {
          _loyaltyMode = LoyaltyModeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildLocation(ProductOffer? productOffer) {
    final state = cast<LocationsSucceed>(ref.watch(locationsLogic));
    final locations = state?.locations.toList() ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelLocation.tr(),
      hint: "",
      items: locations.toSelectItems(),
      selectedItem: locations.firstWhereOrNull((e) => e.locationId == productOffer?.locationId)?.toSelectItem(),
      onChanged: (selectedItem) {
        _locationId = selectedItem.value;
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildSaveButton() {
    final state = ref.watch(productOfferEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        final productOffer = cast<ProductOfferEditorEditing>(state)?.productOffer;
        if (productOffer == null || !_formKey.currentState!.validate()) return;
        await ref.read(productOfferEditorLogic.notifier).save(
              name: _nameController.text,
              description: _descriptionController.text,
              type: _type,
              date: _date,
              loyaltyMode: _loyaltyMode,
              locationId: _locationId,
            );
      },
    );
  }
}

// eof

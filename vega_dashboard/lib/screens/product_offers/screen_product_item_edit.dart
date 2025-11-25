import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/product_item_editor.dart";
import "../../states/product_item_modification_editor.dart";
import "../../states/product_item_modification_patch.dart";
import "../../states/product_item_modifications.dart";
import "../../states/product_item_options.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../widgets/notifications.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "screen_product_modification_edit.dart";

class EditProductItemScreen extends VegaScreen {
  static final notificationsTag = "139b446c-2511-4e96-aed9-9b4d688e38ef";

  const EditProductItemScreen({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditProductItemScreen> with LoggerMixin {
  final notificationsTag = EditProductItemScreen.notificationsTag;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<int>? _newImage;
  bool _loadingImage = false;
  Currency? currency;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = cast<ProductItemEditorEditing>(ref.read(productItemEditorLogic));
      if (state == null) return;
      final productItem = cast<ProductItemEditorEditing>(ref.read(productItemEditorLogic))!.productItem;
      ref.read(productItemModificationsLogic(productItem.itemId).notifier).load();
      ref.read(productItemOptionsLogic(productItem.itemId).notifier).load();

      currency = productItem.currency;
      final price = productItem.price;
      final locale = context.locale.languageCode;
      _priceController.text = (currency != null && price != null) ? currency!.format(price, locale) : "";

      _nameController.text = productItem.name;
      _unitController.text = productItem.unit ?? "";
      _descriptionController.text = productItem.description ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductItemEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildAddModificationButton()),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    final watchedLogic = cast<ProductItemEditorEditing>(ref.watch(productItemEditorLogic));
    final productItem = watchedLogic!.productItem;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _buildMobileLayout(productItem) : _buildDefaultLayout(productItem),
        ),
      ),
    );
  }

  void refresh() => setState(() {});

  void _listenToLogic() {
    ref.listen<ProductItemEditorState>(productItemEditorLogic, (previous, next) {
      if (next is ProductItemEditorFailed) {
        toastCoreError(next.error);
        Future.delayed(stateRefreshDuration, () => ref.read(productItemEditorLogic.notifier).reedit());
      } else if (previous is ProductItemEditorSaving && next is ProductItemEditorSucceed) {
        toastInfo(LangKeys.operationSuccessful.tr());
        dismissUnsaved(notificationsTag);
        ref.read(productItemEditorLogic.notifier).edit(next.productItem);
        final key = ref.read(productItemsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
    //
    ref.listen<ProductItemModificationEditorState>(productItemModificationEditorLogic, (previous, next) async {
      if (previous is ProductItemModificationEditorSaving && next is ProductItemModificationEditorSucceed) {
        final productItem = cast<ProductItemEditorEditing>(ref.read(productItemEditorLogic))?.productItem;
        if (productItem == null) return;
        ref.read(productItemModificationsLogic(productItem.itemId).notifier).reload();
      }
    });
    //
    ref.listen<ProductItemModificationPatchState>(productItemModificationPatchLogic, (previous, next) async {
      bool failed = next is ProductItemModificationPatchFailed;
      if (next.phase.isSuccessful || failed) {
        closeWaitDialog(context, ref);
        ref.read(productItemModificationPatchLogic.notifier).reset();
        final productItem = cast<ProductItemEditorEditing>(ref.read(productItemEditorLogic))?.productItem;
        if (productItem == null) return;
        ref.read(productItemModificationsLogic(productItem.itemId).notifier).reload();
      }
      if (failed) {
        toastCoreError(next.error);
      }
    });
  }

  // TODO: Mobile layout
  Widget _buildMobileLayout(ProductItem productItem) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice(productItem)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildUnit()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildImage(productItem), flex: 1),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDescription(), flex: 4),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 500,
            child: _ModificationDetailWidget(item: productItem),
          ),
          const MoleculeItemSpace(),
          _buildSaveButton(),
        ],
      );

  Widget _buildDefaultLayout(ProductItem productItem) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice(productItem)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildUnit()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildImage(productItem), flex: 1),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDescription(), flex: 4),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 500,
            child: _ModificationDetailWidget(item: productItem),
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

  Widget _buildPrice(ProductItem productItem) {
    final locale = context.locale.languageCode;
    final currency = productItem.currency;
    return MoleculeInput(
      title: LangKeys.labelPrice.tr(),
      controller: _priceController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) {
        if (val?.isEmpty ?? true) return null;
        if (currency == null) return LangKeys.validationCurrencyNotDefined.tr();
        return !((currency.parse(val, locale) ?? -1) > currency.expand(1))
            ? LangKeys.validationPriceInvalidFormat.tr()
            : null;
      },
      maxLines: 1,
      onChanged: (value) => notifyUnsaved(notificationsTag),
      suffixText: currency?.code ?? "?",
    );
  }

  Widget _buildUnit() => MoleculeInput(
        title: LangKeys.labelUnit.tr(),
        controller: _unitController,
        validator: (value) => value!.isEmpty ? LangKeys.validationUnitRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildImage(ProductItem productItem) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: GestureDetector(
        onTap: () => _pickFile(),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: ref.scheme.paperBold,
            child: IndexedStack(
              index: _loadingImage ? 0 : 1,
              children: [
                const CenteredWaitIndicator(),
                _newImage != null
                    ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.cover)
                    : productItem.photo != null
                        ? Image.network(productItem.photo!, fit: BoxFit.cover)
                        : Center(child: LangKeys.hintClickToSetImage.tr().text.alignCenter),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    setState(() => _loadingImage = true);
    final image = await ImagePicker().pickImage(width: 512, height: 512);
    if (image == null) return setState(() => _loadingImage = false);
    _newImage = image.toList();
    setState(() => _loadingImage = false);
    notifyUnsaved(notificationsTag);
  }

  Widget _buildAddModificationButton() {
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonAddModification.tr(),
      onTap: () {
        final state = cast<ProductItemEditorEditing>(ref.read(productItemEditorLogic));
        if (state == null) return debug(() => errorUnexpectedState.toString());
        if (state.isNew) return toastError(LangKeys.toastSaveProductItemFirst.tr());
        final item = state.productItem;
        final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
        final modification = ProductItemModification(
          modificationId: uuid(),
          itemId: item.itemId,
          clientId: client.clientId,
          name: "",
          type: ProductItemModificationType.singleSelection,
        );
        ref.read(productItemModificationEditorLogic.notifier).edit(item, modification, isNew: true);
        context.push(EditProductModificationScreen());
      },
    );
  }

  Widget _buildSaveButton() {
    final state = ref.watch(productItemEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        final productItem = cast<ProductItemEditorEditing>(state)?.productItem;
        if (productItem == null || !_formKey.currentState!.validate()) return;
        if (productItem.photo == null && _newImage == null)
          return toastError(LangKeys.toastValidationImageRequired.tr());
        await ref.read(productItemEditorLogic.notifier).save(
              name: _nameController.text,
              price: currency?.parse(_priceController.text, context.locale.languageCode),
              unit: _unitController.text,
              description: _descriptionController.text,
              newImage: _newImage,
            );
      },
    );
  }
}

class _ModificationDetailWidget extends ConsumerWidget {
  final ProductItem _item;
  const _ModificationDetailWidget({required ProductItem item}) : _item = item;

  static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modificationsState = ref.watch(productItemModificationsLogic(_item.itemId));
    final optionsState = ref.watch(productItemOptionsLogic(_item.itemId));
    final List<ProductItemModification> modifications =
        modificationsState is ProductItemModificationsSucceed ? modificationsState.productItemModifications : [];
    final List<ProductItemOption> options =
        optionsState is ProductItemOptionsSucceed ? optionsState.productItemOptions : [];
    return ReorderableListView.builder(
      proxyDecorator: createMoleculeDragDecorator(Colors.transparent),
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: false,
      physics: vegaScrollPhysic,
      itemCount: modifications.length,
      //shrinkWrap: true,
      itemBuilder: (contextBuilder, index) => ReorderableDragStartListener(
        index: index,
        key: Key("page-$index"),
        child: Padding(
          padding: const EdgeInsets.only(right: moleculeScreenPadding, bottom: 8, left: 4, top: 4),
          // TODO: remove fixed dimensions
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(moleculeScreenPadding / 2),
            decoration: moleculeShadowDecoration(ref.scheme.paperCard),
            child: _buildDetail(contextBuilder, context, index, ref, _item, modifications, options),
          ),
        ),
      ),
      onReorder: (int oldIndex, int newIndex) async {
        if (_reorderInProgress) return toastWarning(ref, LangKeys.toastReorderInProgressTitle.tr());
        _reorderInProgress = true;
        if (oldIndex < newIndex) newIndex -= 1;
        await ref.read(productItemModificationsLogic(_item.itemId).notifier).reorder(oldIndex, newIndex);
        _reorderInProgress = false;
      },
    );
  }

  Widget _buildDetail(contextBuilder, BuildContext contextWidget, index, WidgetRef ref, ProductItem item,
      List<ProductItemModification> modifications, List<ProductItemOption> options) {
    final modification = modifications[index];
    final modificationOptions =
        options.where((option) => option.modificationId == modification.modificationId).toList();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: modification.name.textBold),
              IconButton(
                icon: const VegaIcon(name: AtomIcons.edit),
                onPressed: () {
                  ref.read(productItemModificationEditorLogic.notifier).edit(item, modification);
                  contextWidget.push(EditProductModificationScreen());
                },
              ),
              IconButton(
                icon: const VegaIcon(name: AtomIcons.delete),
                onPressed: () {
                  showWaitDialog(contextWidget, ref, LangKeys.toastArchiving.tr());
                  ref.read(productItemModificationPatchLogic.notifier).archive(modification);
                },
              ),
            ],
          ),
          for (final option in modificationOptions) ...{
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: moleculeScreenPadding / 2),
                  child: const VegaIcon(name: AtomIcons.checkboxOff),
                ),
                Expanded(child: option.name.text.overflowEllipsis),
                Padding(
                  padding: const EdgeInsets.only(left: moleculeScreenPadding / 2),
                  child: ("${option.pricing.symbol} ${_item.currency?.formatSymbol(option.price)}").text,
                ),
              ],
            ),
          },
        ],
      ),
    );
  }
}

// eof

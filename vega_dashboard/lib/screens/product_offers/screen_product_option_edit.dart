import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/product_item_editor.dart";
import "../../states/product_item_option_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditProductOptionScreen extends VegaScreen {
  static final notificationsTag = "e2312401-321a-4961-aeea-df57865160f5";

  const EditProductOptionScreen({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditProductOptionScreen> {
  static final notificationsTag = EditProductOptionScreen.notificationsTag;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();

  ProductItemOptionPricing? _pricing;
  Currency currency = defaultCurrency;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final option = cast<ProductItemOptionEditorEditing>(ref.read(productItemOptionEditorLogic))?.productItemOption;
      if (option == null) return;

      _nameController.text = option.name;
      _unitController.text = option.unit;

      final productItem = (ref.read(productItemEditorLogic) as ProductItemEditorEditing).productItem;
      currency = productItem.currency;
      final price = option.price;
      final locale = context.locale.languageCode;
      _priceController.text = currency.format(price, locale);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductItemOptionEditTitle.tr();

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
    final watchedLogic = cast<ProductItemOptionEditorEditing>(ref.watch(productItemOptionEditorLogic));
    final productItemOption = watchedLogic!.productItemOption;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout(productItemOption) : _defaultLayout(productItemOption),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void _listenToLogic() {
    ref.listen<ProductItemOptionEditorState>(productItemOptionEditorLogic, (previous, next) {
      if (next is ProductItemOptionEditorFailed) {
        final error = next.error;
        toastCoreError(error);
        Future.delayed(stateRefreshDuration, () => ref.read(productItemOptionEditorLogic.notifier).reedit());
      } else if (previous is ProductItemOptionEditorSaving && next is ProductItemOptionEditorSucceed) {
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(productItemOptionEditorLogic.notifier).edit(next.productItemOption);
        dismissUnsaved(notificationsTag);
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout(ProductItemOption productItemOption) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildType(productItemOption)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildUnit()),
            ],
          ),
        ],
      );

  Widget _defaultLayout(ProductItemOption productItemOption) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildType(productItemOption)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrice()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildUnit()),
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

  Widget _buildType(ProductItemOption? productItemOption) => MoleculeSingleSelect(
        title: LangKeys.labelType.tr(),
        hint: "",
        items: ProductItemOptionPricing.values.toSelectItems(),
        selectedItem: productItemOption?.pricing.toSelectItem(),
        onChanged: (selectedItem) {
          _pricing = ProductItemOptionPricingCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildPrice() {
    final item = (ref.read(productItemEditorLogic) as ProductItemEditorEditing).productItem;
    final locale = context.locale.languageCode;
    final currency = item.currency;
    return MoleculeInput(
      title: LangKeys.labelPrice.tr(),
      controller: _priceController,
      validator: (val) {
        if (val?.isEmpty ?? true) return null;
        if (currency == null) return LangKeys.validationCurrencyNotDefined.tr();
        return !((currency.parse(val, locale) ?? -1) >= currency.expand(0))
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
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSaveButton() {
    final locale = context.locale.languageCode;
    final item = (ref.read(productItemEditorLogic) as ProductItemEditorEditing?)?.productItem;
    final state = ref.watch(productItemOptionEditorLogic);
    final currency = item?.currency;
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        final productItemOption = cast<ProductItemOptionEditorEditing>(state)?.productItemOption;
        if (productItemOption == null || !_formKey.currentState!.validate()) return;
        await ref.read(productItemOptionEditorLogic.notifier).save(
              name: _nameController.text,
              pricing: _pricing,
              price: currency?.parse(_priceController.text, locale),
              unit: _unitController.text,
            );
      },
    );
  }
}

// eof

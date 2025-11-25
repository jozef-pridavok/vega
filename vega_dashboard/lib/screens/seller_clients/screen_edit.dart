import "dart:typed_data";

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../enums/seller_template.dart";
import "../../extensions/client_category_period.dart";
import "../../extensions/select_item.dart";
import "../../states/client_payment_providers.dart";
import "../../states/providers.dart";
import "../../states/seller_client_editor.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_color.dart";
import "../screen_app.dart";

class EditSellerClientScreen extends VegaScreen {
  final bool isNew;
  final Client client;

  const EditSellerClientScreen({super.key, required this.client, this.isNew = false});

  @override
  createState() => _EditState();
}

enum _Module {
  loyalty,
  coupons,
  leaflets,
  reservations,
  orders,
}

extension _ModuleToSelectedItems on List<_Module> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();

  static List<_Module> from(List<SelectItem> items) => items.map((e) => _ModuleExt.from(e)).toList();
}

extension _ModuleExt on _Module {
  SelectItem toSelectItem() => SelectItem(label: displayName, value: name);

  static _Module from(SelectItem item) => _Module.values.firstWhere((e) => e.name == item.value);

  String get displayName {
    switch (this) {
      case _Module.loyalty:
        return LangKeys.sellerClientModuleLoyalty.tr();
      case _Module.coupons:
        return LangKeys.sellerClientModuleCoupons.tr();
      case _Module.leaflets:
        return LangKeys.sellerClientModuleLeaflets.tr();
      case _Module.reservations:
        return LangKeys.sellerClientModuleReservations.tr();
      case _Module.orders:
        return LangKeys.sellerClientModuleOrders.tr();
    }
  }
}

extension _ModuleOnClient on Client {
  List<_Module> get modules {
    final modules = <_Module>[];
    if (licenseModuleLoyalty) modules.add(_Module.loyalty);
    if (licenseModuleCoupons) modules.add(_Module.coupons);
    if (licenseModuleLeaflets) modules.add(_Module.leaflets);
    if (licenseModuleReservations) modules.add(_Module.reservations);
    if (licenseModuleOrders) modules.add(_Module.orders);
    return modules;
  }
}

class _EditState extends VegaScreenState<EditSellerClientScreen> with SingleTickerProviderStateMixin {
  Client get _client => widget.client;

  final _formKey = GlobalKey<FormState>();

  final _clientName = TextEditingController();
  final _accountPrefix = TextEditingController();
  final _activityPeriod = TextEditingController();
  final _cardMask = TextEditingController();

  final _licenseBaseController = TextEditingController();
  final _licensePricingController = TextEditingController();

  late bool _isNew;

  late Currency _currency;
  List<Country> _countries = [];
  List<ClientCategory> _categories = [];
  late Color _color;
  List<String> _providers = [];

  late Currency _licenseCurrency;
  late int _licenseBase;
  late int _licensePricing;

  late List<int>? _newImage;

  List<_Module> _modules = [];

  SellerTemplate? _template;

  @override
  void initState() {
    super.initState();

    _isNew = widget.isNew;

    _newImage = null;

    _clientName.text = _client.name;
    _accountPrefix.text = _client.accountPrefix;
    _currency = _client.currency;
    _countries = _client.countries ?? [];
    _categories = _client.categories ?? [];
    _activityPeriod.text = _client.licenseActivityPeriod.toString();
    _color = _client.color;
    _cardMask.text = _client.newUserCardMask;
    _providers = _client.licenseProviders;
    _licenseCurrency = _client.licenseCurrency;
    _licenseBase = _client.licenseBase;
    _licensePricing = _client.licensePricing;
    _modules = _client.modules;

    Future.microtask(() => _updatePriceControllers(context));

    Future.microtask(() => ref.read(sellerClientEditorLogic.notifier).reset());
    Future(() => ref.read(clientPaymentProvidersLogic.notifier).load());
  }

  void _updatePriceControllers(BuildContext context) {
    final locale = context.locale.languageCode;
    _licenseBaseController.text = _licenseCurrency.format(_licenseBase, locale);
    _licensePricingController.text = _licenseCurrency.format(_licensePricing, locale);
  }

  @override
  String? getTitle() => _client.name;

  @override
  bool onBack(WidgetRef ref) {
    ref.read(activeSellerClientsLogic.notifier).refresh();
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: _buildSaveButton(context),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout() : _defaultLayout(),
        ),
      ),
    );
  }

  void _listenToLogics(BuildContext context) async {
    ref.listen<SellerClientEditorState>(sellerClientEditorLogic, (previous, next) async {
      if (next is SellerClientEditorSaved) {
        _isNew = false;
        Future.delayed(stateRefreshDuration, () => ref.read(sellerClientEditorLogic.notifier).reset());
      } else if (next is SellerClientEditorFailed) {
        ref.read(sellerClientEditorLogic.notifier).reset();
        if (next.error == errorFailedToSaveData)
          toastError(LangKeys.toastAccountPrefixMustBeUnique.tr());
        else
          toastError(LangKeys.operationFailed.tr());
      }
    });
  }

  Widget _mobileLayout() => Column(
        children: [
          if (_isNew) ...{
            _buildTemplate(),
            const MoleculeItemSpace(),
          },
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildClientName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildAccountPrefix()),
            ],
          ),
          const MoleculeItemSpace(),
          _buildCountries(true),
          const MoleculeItemSpace(),
          _buildCategories(true),
          const MoleculeItemSpace(),
          _buildCurrency(),
          const MoleculeItemSpace(),
          _buildLogo(),
          const MoleculeItemSpace(),
          _buildColor(),
          const MoleculeItemSpace(),
          _buildCardMask(),
          const MoleculeItemSpace(),
          const MoleculeItemSeparator(),
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.sectionLicense.tr()),
          const MoleculeItemSpace(),
          _buildModules(true),
          const MoleculeItemSpace(),
          _buildActivePeriod(),
          const MoleculeItemSpace(),
          _buildPaymentProvider(true),
          const MoleculeItemSpace(),
          _buildBase(context),
          const MoleculeItemSpace(),
          _buildPricing(context),
          const MoleculeItemSpace(),
          _buildLicenseCurrency(),
          const MoleculeItemSpace(),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isNew) ...{
            _buildTemplate(),
            const MoleculeItemSpace(),
          },
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildClientName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildAccountPrefix()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildCountries(false)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCategories(false)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildCurrency()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildColor()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCardMask()),
            ],
          ),
          const MoleculeItemSpace(),
          Center(child: _buildLogo()),
          const MoleculeItemSpace(),
          const MoleculeItemSeparator(),
          const MoleculeItemSpace(),
          // TODO localize section_license "Licencia", "License", "Licencia"
          MoleculeItemTitle(header: LangKeys.sectionLicense.tr()),
          const MoleculeItemSpace(),
          _buildModules(false),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildActivePeriod()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildPaymentProvider(false)),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildBase(context)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildPricing(context)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLicenseCurrency()),
            ],
          ),
          const MoleculeItemSpace(),
        ],
      );

  Widget _buildModules(bool isMobile) {
    return MoleculeMultiSelect(
      title: LangKeys.labelModules.tr(),
      hint: LangKeys.hintModules.tr(),
      items: _Module.values.toSelectItems(),
      maxSelectedItems: isMobile ? 2 : 3,
      selectedItems: _modules.toSelectItems(),
      onChanged: (selectedItems) => _modules = _ModuleToSelectedItems.from(selectedItems),
    );
  }

  Widget _buildPaymentProvider(bool isMobile) {
    final state = ref.watch(clientPaymentProvidersLogic);
    final succeed = cast<ClientPaymentProvidersSucceed>(state);
    final providers = succeed?.providers ?? [];
    return MoleculeMultiSelect(
      title: LangKeys.labelPaymentProvider.tr(),
      hint: LangKeys.hintPaymentProviders.tr(),
      items: providers.toSelectItems(),
      maxSelectedItems: isMobile ? 2 : 5,
      selectedItems: providers.where((e) => _providers.contains(e.clientPaymentProviderId)).toList().toSelectItems(),
      onChanged: (selectedItems) {
        _providers = selectedItems
            .map((item) => providers.firstWhere(
                  (e) => e.clientPaymentProviderId == item.value,
                ))
            .map((e) => e.clientPaymentProviderId)
            .toList();
      },
    );
  }

  Widget _buildClientName() {
    return MoleculeInput(
      title: LangKeys.labelCompanyName.tr(),
      controller: _clientName,
      validator: (p0) => p0!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
      onChanged: (value) {
        setState(() => _client.name = value);
        if (_isNew)
          _accountPrefix.text = value.toLowerCase().replaceAll(RegExp(r"\s+"), "").removeDiacritics().toString();
      },
    );
  }

  static const _minimalPrefixLength = 3;

  Widget _buildAccountPrefix() {
    return MoleculeInput(
      title: LangKeys.labelAccountPrefix.tr(),
      enabled: _isNew,
      controller: _accountPrefix,
      maxLines: 1,
      validator: (val) {
        if (!_isNew) return null;
        return (val?.length ?? 0) < _minimalPrefixLength
            ? LangKeys.validationMinimalLength.tr(args: [_minimalPrefixLength.toString()])
            : null;
      },
    );
  }

  Widget _buildCountries(bool isMobile) {
    return MoleculeMultiSelect(
      title: LangKeys.labelCountries.tr(),
      hint: LangKeys.hintClientCountries.tr(),
      items: Country.values.toSelectItems(),
      maxSelectedItems: isMobile ? 2 : 3,
      selectedItems: (_client.countries ?? []).toSelectItems(),
      onChanged: (selectedItems) => _countries = selectedItems
          .map((item) => Country.values.firstWhere(
                (e) => e.code == item.value,
              ))
          .toList(),
    );
  }

  Widget _buildCategories(bool isMobile) {
    return MoleculeMultiSelect(
      title: LangKeys.labelCategories.tr(),
      hint: LangKeys.hintClientCategories.tr(),
      items: ClientCategory.values.toSelectItems(),
      maxSelectedItems: isMobile ? 2 : 3,
      selectedItems: (_client.categories ?? []).toSelectItems(),
      onChanged: (selectedItems) {
        _categories = selectedItems
            .map((item) => ClientCategory.values.firstWhere(
                  (e) => e.code.toString() == item.value,
                ))
            .toList();
        // find minimal period in _categories
        final minimalPeriod = _categories.map((e) => e.period).reduce((a, b) => a < b ? a : b);
        _activityPeriod.text = minimalPeriod.toString();
      },
    );
  }

  static const _minimalPeriod = 7;

  Widget _buildActivePeriod() {
    return MoleculeInput(
      title: LangKeys.labelActivePeriod.tr(),
      controller: _activityPeriod,
      maxLines: 1,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) => !isInt(val ?? "", min: _minimalPeriod)
          ? LangKeys.validationMinimalNumber.tr(args: [_minimalPeriod.toString()])
          : null,
    );
  }

  Widget _buildCurrency() {
    return MoleculeSingleSelect(
      title: LangKeys.labelCurrency.tr(),
      hint: "",
      items: Currency.values.toSelectItems(),
      selectedItem: _currency.toSelectItem(),
      onChanged: (selectedItem) => _currency = CurrencySelectItem.from(selectedItem),
    );
  }

  Widget _buildColor() {
    return MoleculeColorPicker(
      title: LangKeys.labelColor.tr(),
      hint: "",
      initialValue: _color,
      onChanged: (Color? selectedColor) {
        //_color = selectedColor ?? _color;
        setState(() => _color = selectedColor ?? _color);
      },
    );
  }

  Widget _buildBase(BuildContext context) {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      title: LangKeys.labelLicenseBase.tr(),
      controller: _licenseBaseController,
      maxLines: 1,
      suffixText: _licenseCurrency.symbol,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (val) => _licenseBase = _licenseCurrency.parse(val, locale) ?? _licenseBase,
      validator: (val) => !((_licenseCurrency.parse(val, locale) ?? -1) > _licenseCurrency.expand(1))
          ? LangKeys.validationPriceInvalidFormat.tr()
          : null,
    );
  }

  Widget _buildPricing(BuildContext context) {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      title: LangKeys.labelLicensePricing.tr(),
      controller: _licensePricingController,
      maxLines: 1,
      suffixText: _licenseCurrency.symbol,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (val) => _licensePricing = _licenseCurrency.parse(val, locale) ?? _licensePricing,
      validator: (val) => !((_licenseCurrency.parse(val, locale) ?? -1) > _licenseCurrency.expand(1))
          ? LangKeys.validationPriceInvalidFormat.tr()
          : null,
    );
  }

  Widget _buildLicenseCurrency() {
    return MoleculeSingleSelect(
      title: LangKeys.labelCurrency.tr(),
      hint: LangKeys.labelCurrency.tr(),
      items: Currency.values.toSelectItems(),
      selectedItem: _client.licenseCurrency.toSelectItem(),
      onChanged: (selectedItem) {
        _licenseCurrency = CurrencyCode.fromCodeOrNull(selectedItem.value) ?? _licenseCurrency;
        setState(() => _updatePriceControllers(context));
      },
    );
  }

  Widget _buildCardMask() {
    return MoleculeInput(
      title: LangKeys.labelCardMask.tr(),
      controller: _cardMask,
      maxLines: 1,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // at least three *, -, space or YY
      validator: (val) =>
          !RegExp(r"^(?=(?:[^*]*\*){3})(?=(?:[^Y]*YY[^Y]*)?[^Y]*$)(?=(?:[^-]*-[^-]*)*$).*$").hasMatch(val ?? "")
              ? LangKeys.validationCardMask.tr()
              : null,
    );
  }

  Widget _buildTemplate() => MoleculeSingleSelect(
        title: LangKeys.labelTemplate.tr(),
        hint: "",
        items: SellerTemplate.values.toSelectItems(),
        onChanged: (selectedItem) {
          _template = SellerTemplateValue.fromString(selectedItem.value);
        },
      );

  void _pickFile() async {
    final image = await ImagePicker().pickImage(width: 256, height: 256);
    if (image == null) return;
    setState(() => _newImage = image.toList());
  }

  Widget _buildLogo() {
    final String? logo = _client.logo;
    return SizedBox(
      height: 200,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickFile,
            child: MoleculusCardGrid4(
              detailText: _clientName.text,
              backgroundColor: _color.toMaterial(),
              image: _newImage != null
                  ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.contain)
                  : logo != null
                      ? Image.network(logo, fit: BoxFit.contain)
                      : LangKeys.hintClickToSetImage.tr().text.alignCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final locale = context.locale.languageCode;
    final editorState = ref.watch(sellerClientEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: editorState.buttonState,
      onPressed: () {
        if (!(_formKey.currentState?.validate() ?? false)) return;
        if (_isNew && _newImage == null) return toastError(LangKeys.validationImageRequired.tr());

        _client.name = _clientName.text;
        if (_isNew) _client.accountPrefix = _accountPrefix.text;
        _client.currency = _currency;
        _client.countries = _countries;
        _client.categories = _categories;
        _client.color = _color;
        _client.newUserCardMask = _cardMask.text;

        _client.setMetaLicense(
          base: _licenseCurrency.parse(_licenseBaseController.text, locale),
          pricing: _licenseCurrency.parse(_licensePricingController.text),
          currency: _licenseCurrency,
          providers: _providers,
          activityPeriod: tryParseInt(_activityPeriod.text) ?? 30,
          moduleLoyalty: _modules.contains(_Module.loyalty),
          moduleCoupons: _modules.contains(_Module.coupons),
          moduleLeaflets: _modules.contains(_Module.leaflets),
          moduleReservations: _modules.contains(_Module.reservations),
          moduleOrders: _modules.contains(_Module.orders),
        );

        if (_isNew)
          ref.read(sellerClientEditorLogic.notifier).create(_client, logoImage: _newImage, template: _template);
        else
          ref.read(sellerClientEditorLogic.notifier).save(_client, logoImage: _newImage);
      },
    );
  }
}

// eof

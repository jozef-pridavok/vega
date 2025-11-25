import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/product_item_editor.dart";
import "../../states/product_item_modification_editor.dart";
import "../../states/product_item_option_editor.dart";
import "../../states/product_item_options.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/input_formatters.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/notifications.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_item.dart";
import "screen_product_option_edit.dart";

class EditProductModificationScreen extends VegaScreen {
  static final notificationsTag = "47794154-a444-47c8-b87e-a2a0975e8d23";

  const EditProductModificationScreen({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditProductModificationScreen> with LoggerMixin {
  static final notificationsTag = EditProductModificationScreen.notificationsTag;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _maxController = TextEditingController();

  ProductItemModificationType? _type;
  bool? _mandatory;
  bool? _maxEnabled;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final modification =
          cast<ProductItemModificationEditorEditing>(ref.read(productItemModificationEditorLogic))?.modification;
      if (modification == null) return;
      _nameController.text = modification.name;
      _maxEnabled = modification.max != null;
      _maxController.text = modification.max?.toString() ?? "";
      _mandatory = modification.mandatory;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _maxController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductItemModificationEditTitle.tr();

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
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildAddOptionButton()),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    final isMobile = ref.watch(layoutLogic).isMobile;
    final watchedLogic = cast<ProductItemModificationEditorEditing>(ref.watch(productItemModificationEditorLogic));
    final item = watchedLogic!.item;
    final modification = watchedLogic.modification;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Form(
        key: _formKey,
        child: isMobile ? _mobileLayout(item, modification) : _defaultLayout(item, modification),
      ),
    );
  }

  void refresh() => setState(() {});

  void _listenToLogic() {
    ref.listen<ProductItemOptionEditorState>(productItemOptionEditorLogic, (previous, next) {
      if (previous is ProductItemOptionEditorSaving && next is ProductItemOptionEditorSucceed) {
        final watchedLogic = cast<ProductItemModificationEditorEditing>(ref.watch(productItemModificationEditorLogic));
        if (watchedLogic == null) return;
        ref.read(productItemOptionsLogic(watchedLogic.modification.itemId).notifier).reload();
      }
    });
    //
    ref.listen<ProductItemModificationEditorState>(productItemModificationEditorLogic, (previous, next) {
      if (next is ProductItemModificationEditorFailed) {
        final error = next.error;
        toastCoreError(error);
        Future.delayed(stateRefreshDuration, () => ref.read(productItemModificationEditorLogic.notifier).reedit());
      } else if (previous is ProductItemModificationEditorSaving && next is ProductItemModificationEditorSucceed) {
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(productItemModificationEditorLogic.notifier).edit(next.item, next.modification);
        ref.read(notificationsLogic.notifier).dismiss(EditProductModificationScreen.notificationsTag);
      }
    });
  }

  Widget _buildOptions(BuildContext context, ProductItem item) {
    final itemsState = ref.watch(productItemOptionsLogic(item.itemId));
    if (itemsState is ProductItemOptionsSucceed || itemsState is ProductItemOptionsRefreshing) return _Options(item);
    if (itemsState is ProductItemOptionsFailed)
      return StateErrorWidget(
        productItemOptionsLogic(item.itemId),
        onReload: () => ref.read(productItemOptionsLogic(item.itemId).notifier).reload(),
      );
    return const CenteredWaitIndicator();
  }

  // TODO: Mobile layout
  Widget _mobileLayout(ProductItem item, ProductItemModification modification) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildType(modification)),
            ],
          ),
          const MoleculeItemSpace(),
          _buildMandatory(),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLimitNumbers()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildMax()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: Container(width: 0, height: 0)),
            ],
          ),
          const MoleculeItemSpace(),
          // TODO: remove fixed height
          Flexible(child: _buildOptions(context, item)),
          const MoleculeItemSpace(),
          _buildSaveButton(),
        ],
      );

  Widget _defaultLayout(ProductItem item, ProductItemModification modification) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildType(modification)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildMandatory()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLimitNumbers()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildMax()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: Container(width: 0, height: 0)),
            ],
          ),
          const MoleculeItemSpace(),
          // TODO: remove fixed height
          Flexible(child: _buildOptions(context, item)),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: _nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildType(ProductItemModification? productItemModification) => MoleculeSingleSelect(
        title: LangKeys.labelType.tr(),
        hint: "",
        items: ProductItemModificationType.values.toSelectItems(),
        selectedItem: productItemModification?.type.toSelectItem(),
        onChanged: (selectedItem) {
          _type = ProductItemModificationTypeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildMandatory() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeCheckBox(
            value: _mandatory ?? false,
            onChanged: (bool? value) {
              notifyUnsaved(notificationsTag);
              setState(() {
                _mandatory = value!;
              });
            },
          ),
          const MoleculeItemHorizontalSpace(),
          Flexible(child: LangKeys.labelMandatory.tr().text.maxLine(2).overflowEllipsis),
        ],
      );

  Widget _buildLimitNumbers() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeCheckBox(
            value: _maxEnabled ?? false,
            onChanged: (bool? value) {
              notifyUnsaved(notificationsTag);
              setState(() {
                _maxEnabled = value!;
              });
            },
          ),
          const MoleculeItemHorizontalSpace(),
          Flexible(child: LangKeys.labelLimitNumbers.tr().text.maxLine(2).overflowEllipsis),
        ],
      );

  Widget _buildMax() => MoleculeInput(
        controller: _maxController,
        maxLines: 1,
        enabled: _maxEnabled ?? false,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          MinValueInputFormatter(1),
        ],
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildAddOptionButton() {
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonAddOption.tr(),
      onTap: () {
        final state = cast<ProductItemModificationEditorEditing>(ref.read(productItemModificationEditorLogic));
        if (state == null) return debug(() => errorUnexpectedState.toString());
        if (state.isNew) return toastError(LangKeys.toastSaveProductModificationFirst.tr());
        final modification = state.modification;
        final productItemOption = ProductItemOption(
          optionId: uuid(),
          modificationId: modification.modificationId,
          name: "",
          price: 0,
          unit: "",
        );
        ref.read(productItemOptionEditorLogic.notifier).edit(productItemOption, isNew: true);
        context.push(EditProductOptionScreen());
      },
    );
  }

  Widget _buildSaveButton() {
    final state = ref.watch(productItemModificationEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        final productItemModification = cast<ProductItemModificationEditorEditing>(state)?.modification;
        if (productItemModification == null || !_formKey.currentState!.validate()) return;
        await ref.read(productItemModificationEditorLogic.notifier).save(
              name: _nameController.text,
              type: _type,
              mandatory: _mandatory,
              max: _maxEnabled == true ? int.tryParse(_maxController.text) : null,
            );
      },
    );
  }
}

class _Options extends ConsumerWidget {
  final ProductItem item;
  const _Options(this.item);

  static const _columnOption = "option";
  static const _columnPrice = "price";
  static const _columnUnit = "unit";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productItem = (ref.read(productItemEditorLogic) as ProductItemEditorEditing).productItem;
    final productItemModification =
        (ref.read(productItemModificationEditorLogic) as ProductItemModificationEditorEditing).modification;
    final productItemOptions =
        ((cast<ProductItemOptionsSucceed>(ref.read(productItemOptionsLogic(productItem.itemId))))?.productItemOptions ??
                [])
            .where((item) => item.modificationId == productItemModification.modificationId)
            .toList();
    return PullToRefresh(
        onRefresh: () {
          final productItem = (ref.read(productItemEditorLogic) as ProductItemEditorEditing).productItem;
          ref.read(productItemOptionsLogic(productItem.itemId).notifier).reload();
          return Future<void>.value();
        },
        child: DataGrid<ProductItemOption>(
          rows: productItemOptions,
          columns: [
            DataGridColumn(name: _columnUnit, label: LangKeys.columnUnit.tr(), width: 100),
            DataGridColumn(name: _columnOption, label: LangKeys.columnOption.tr()),
            DataGridColumn(name: _columnPrice, label: LangKeys.columnPrice.tr(), width: 0),
          ],
          onRowTapUp: (column, option, details) => _popupOperations(context, ref, option, details),
          onBuildCell: (column, option) => _buildCell(context, ref, column, option),
        ));
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ProductItemOption option) {
    final currency = item.currency;
    final price = option.price;
    final isBlocked = option.blocked;
    final columnMap = <String, ThemedText>{
      _columnOption: option.name.text.color(ref.scheme.content),
      _columnPrice: (currency != null ? (option.pricing.symbol + currency.formatSymbol(price)) : "")
          .text
          .color(ref.scheme.content),
      _columnUnit: option.unit.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, ProductItemOption option, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: option.name,
        items: [
          ProductOptionMenuItems.edit(context, ref, option),
        ],
      );
}

// eof

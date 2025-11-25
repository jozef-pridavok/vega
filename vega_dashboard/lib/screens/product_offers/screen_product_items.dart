import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/screen_app.dart";
import "../../states/product_item_patch.dart";
import "../../states/product_items.dart";
import "../../states/product_section_editor.dart";
import "../../states/product_sections.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";
import "screen_product_item_edit.dart";
import "screen_product_sections.dart";
import "widget_edit_section.dart";

class ProductItemsScreen extends VegaScreen {
  final ProductOffer productOffer;
  const ProductItemsScreen({required this.productOffer, super.key});

  @override
  createState() => _ProductItemsState();
}

class _ProductItemsState extends VegaScreenState<ProductItemsScreen> with SingleTickerProviderStateMixin, LoggerMixin {
  String? _pickedSectionId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productItemsLogic.notifier).load();
      ref.read(productSectionsLogic.notifier).load();
    });
  }

  @override
  String? getTitle() => LangKeys.screenProductItemsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final productItems = ref.watch(productItemsLogic);
    final productSections = ref.watch(productSectionsLogic);
    final isRefreshing =
        productItems.runtimeType == ProductItemsRefreshing || productSections.runtimeType == ProductSectionsRefreshing;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: IconButton(
          icon: const VegaIcon(name: AtomIcons.plusCircle),
          onPressed: () {
            final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
            final productItem = ProductItem(
              itemId: uuid(),
              sectionId: _pickedSectionId,
              name: "",
              clientId: client.clientId,
              rank: 0,
              qtyPrecision: 0,
              currency: client.currency,
            );
            ref.read(productItemEditorLogic.notifier).edit(productItem, isNew: true);
            context.push(EditProductItemScreen());
          },
        ),
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(productItemsLogic.notifier).refresh();
          ref.read(productSectionsLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    final itemsState = ref.watch(productItemsLogic);
    final sectionsState = ref.watch(productSectionsLogic);
    if ((itemsState is ProductItemsSucceed || itemsState is ProductItemsRefreshing) &&
        (sectionsState is ProductSectionsSucceed || sectionsState is ProductSectionsRefreshing)) return _build(context);
    if (itemsState is ProductItemsFailed) {
      return StateErrorWidget(productItemsLogic, onReload: () {
        ref.read(productItemsLogic.notifier).load();
        ref.read(productSectionsLogic.notifier).load();
      });
    } else if (sectionsState is ProductSectionsFailed) {
      return StateErrorWidget(productSectionsLogic, onReload: () {
        ref.read(productItemsLogic.notifier).load();
        ref.read(productSectionsLogic.notifier).load();
      });
    }
    return const CenteredWaitIndicator();
  }

  void refresh() {
    setState(() {});
  }

  void _listenToLogic() {
    ref.listen<ProductItemPatchState>(productItemPatchLogic, (previous, next) {
      bool failed = next is ProductItemPatchFailed;
      if (next.phase.isSuccessful || failed) {
        closeWaitDialog(context, ref);
        ref.read(productItemPatchLogic.notifier).reset();
        ref.read(productItemsLogic.notifier).refresh();
      }
      if (failed) {
        toastCoreError(next.error);
      }
    });
    //
    ref.listen<ProductSectionEditorState>(productSectionEditorLogic, (previous, next) {
      bool failed = next is ProductSectionEditorFailed;
      if (previous is ProductSectionEditorSaving && (next is ProductSectionEditorSucceed || failed)) {
        closeWaitDialog(context, ref);
        ref.read(productSectionsLogic.notifier).refresh();
      }
      if (failed) {
        toastCoreError(next.error);
      }
    });
    //
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(productItemsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(productItemsLogic.notifier).load();
    });
  }

  Widget _build(BuildContext context) {
    final sectionsState = ref.read(productSectionsLogic) as ProductSectionsSucceed;
    final productSections =
        sectionsState.productSections.where((section) => section.offerId == widget.productOffer.offerId).toList();
    if (_pickedSectionId == null && productSections.isNotEmpty) _pickedSectionId = productSections.first.sectionId;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSections(context, productSections),
          Expanded(child: _GridWidget(sections: productSections, pickedSectionId: _pickedSectionId)),
        ],
      ),
    );
  }

  Widget _buildSections(BuildContext context, List<ProductSection> productSections) {
    return Padding(
      padding: const EdgeInsets.only(bottom: moleculeScreenPadding),
      child: SizedBox(
        height: 30,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: vegaScrollPhysic,
          children: [
            for (final section in productSections) ...{
              MoleculeChip(
                  label: section.name,
                  border: Border.all(color: ref.scheme.primary, width: 1),
                  backgroundColor: _pickedSectionId == section.sectionId ? ref.scheme.primary : ref.scheme.paperBold,
                  onTap: () {
                    _pickedSectionId = section.sectionId;
                    refresh();
                  }),
              const SizedBox(width: 16),
            },
            MoleculeLinkButton(
              titleText: LangKeys.labelAddSection.tr(),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: LangKeys.labelAddSection.tr().text,
                  content: EditSectionWidget(offerId: widget.productOffer.offerId),
                ),
              ),
            ),
            const SizedBox(width: 16),
            MoleculeLinkButton(
              titleText: LangKeys.labelEditSections.tr(),
              onTap: () => context.push(ProductSectionsScreen(productOffer: widget.productOffer)),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _GridWidget extends ConsumerWidget {
  final List<ProductSection> sections;
  final String? pickedSectionId;
  const _GridWidget({required this.sections, required this.pickedSectionId});

  static const _columnImage = "date";
  static const _columnUnit = "unit";
  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnPrice = "price";
  static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final productItems = (ref.read(productItemsLogic) as ProductItemsSucceed)
        .productItems
        .where((item) => item.sectionId == pickedSectionId)
        .toList();
    return PullToRefresh(
      onRefresh: () => ref.read(productItemsLogic.notifier).refresh(),
      child: DataGrid<ProductItem>(
          rows: productItems,
          columns: [
            DataGridColumn(name: _columnImage, label: LangKeys.columnImage.tr(), width: 100),
            DataGridColumn(name: _columnUnit, label: LangKeys.columnUnit.tr(), width: 100),
            DataGridColumn(name: _columnName, label: LangKeys.columnName.tr(), width: isMobile ? double.nan : 250),
            if (!isMobile) DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
            DataGridColumn(name: _columnPrice, label: LangKeys.columnPrice.tr(), width: 0),
          ],
          onBuildCell: (column, productItem) => _buildCell(context, ref, column, productItem),
          onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
          onReorder: (oldIndex, newIndex) async {
            if (_reorderInProgress) return toastWarning(ref, LangKeys.toastReorderInProgressTitle.tr());
            _reorderInProgress = true;
            if (oldIndex < newIndex) newIndex -= 1;
            await ref.read(productItemsLogic.notifier).reorder(oldIndex, newIndex);
            _reorderInProgress = false;
          }),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ProductItem productItem) {
    final currency = productItem.currency;
    final price = productItem.price;
    final isBlocked = productItem.blocked;
    final columnMap = <String, Widget>{
      //_columnImage: "".text.color(ref.scheme.content),
      _columnImage: Padding(
        padding: const EdgeInsets.all(4),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Image.network(productItem.photo!, fit: BoxFit.cover),
          ),
        ),
      ),
      _columnUnit: productItem.unit.text.color(ref.scheme.content),
      _columnName: productItem.name.text.color(ref.scheme.content),
      _columnDescription: productItem.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnPrice: (price != null ? currency.formatSymbol(price) : "").text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? (cell is ThemedText ? cell.lineThrough : cell) : cell;
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ProductItem productItem,
    TapUpDetails details,
  ) {
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: productItem.name,
      items: [
        ProductItemMenuItems.edit(context, ref, productItem),
        ProductItemMenuItems.block(context, ref, productItem),
        ProductItemMenuItems.changeSection(context, ref, productItem, sections),
        ProductItemMenuItems.archive(context, ref, productItem),
      ],
    );
  }
}

// eof

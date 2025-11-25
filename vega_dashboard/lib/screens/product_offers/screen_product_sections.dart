import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/screen_app.dart";
import "../../states/product_section_editor.dart";
import "../../states/product_section_patch.dart";
import "../../states/product_sections.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";
import "widget_edit_section.dart";

class ProductSectionsScreen extends VegaScreen {
  final ProductOffer productOffer;
  const ProductSectionsScreen({required this.productOffer, super.key}) : super();

  @override
  createState() => _ProductSectionsState();
}

class _ProductSectionsState extends VegaScreenState<ProductSectionsScreen>
    with SingleTickerProviderStateMixin, LoggerMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productSectionsLogic.notifier).load();
    });
  }

  @override
  String? getTitle() => LangKeys.screenProductSectionsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.plusCircle),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: LangKeys.labelAddSection.tr().text,
              content: EditSectionWidget(offerId: widget.productOffer.offerId),
            ),
          );
        },
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    final state = ref.watch(productSectionsLogic);
    if (state is ProductSectionsSucceed || state is ProductSectionsRefreshing) return _build(context);
    if (state is ProductSectionsFailed)
      return StateErrorWidget(productSectionsLogic, onReload: () => ref.read(productSectionsLogic.notifier).refresh());
    return const CenteredWaitIndicator();
  }

  void refresh() => setState(() {});

  void _listenToLogic() {
    ref.listen<ProductSectionPatchState>(productSectionPatchLogic, (previous, next) {
      bool failed = next is ProductSectionPatchFailed;
      if (next.phase.isSuccessful || failed) {
        closeWaitDialog(context, ref);
        ref.read(productSectionPatchLogic.notifier).reset();
        ref.read(productSectionsLogic.notifier).refresh();
      }
      if (failed) {
        toastError(next.error.toString());
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
        toastError(next.error.toString());
      }
    });
  }

  Widget _build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _GridWidget(productOffer: widget.productOffer)),
        ],
      ),
    );
  }
}

class _GridWidget extends ConsumerWidget {
  final ProductOffer productOffer;
  const _GridWidget({required this.productOffer});

  static const _columnSection = "section";
  static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productSections = (ref.read(productSectionsLogic) as ProductSectionsSucceed)
        .productSections
        .where((section) => section.offerId == productOffer.offerId)
        .toList();
    return PullToRefresh(
      onRefresh: () => ref.read(productSectionsLogic.notifier).refresh(),
      child: DataGrid<ProductSection>(
          rows: productSections,
          columns: [
            DataGridColumn(name: _columnSection, label: LangKeys.columnSection.tr()),
          ],
          onBuildCell: (column, productSection) => _buildCell(context, ref, column, productSection),
          onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
          onReorder: (oldIndex, newIndex) async {
            if (_reorderInProgress) return toastWarning(ref, LangKeys.toastReorderInProgressTitle.tr());
            _reorderInProgress = true;
            if (oldIndex < newIndex) newIndex -= 1;
            await ref.read(productSectionsLogic.notifier).reorder(oldIndex, newIndex);
            _reorderInProgress = false;
          }),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ProductSection productSection) {
    final isBlocked = productSection.blocked;
    final columnMap = <String, ThemedText>{
      _columnSection: productSection.name.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ProductSection productSection,
    TapUpDetails details,
  ) {
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: productSection.name,
      items: [
        ProductSectionMenuItems.edit(context, ref, productSection),
        ProductSectionMenuItems.block(context, ref, productSection),
        ProductSectionMenuItems.archive(context, ref, productSection),
      ],
    );
  }
}

// eof

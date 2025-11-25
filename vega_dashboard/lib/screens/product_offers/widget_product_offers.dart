import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../repositories/product_offer.dart";
import "../../states/product_offers.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

extension ProductOfferRepositoryFilterLogic on ProductOfferRepositoryFilter {
  static final _map = {
    ProductOfferRepositoryFilter.active: activeProductOffersLogic,
    ProductOfferRepositoryFilter.archived: archivedProductOffersLogic,
  };

  StateNotifierProvider<ProductOffersNotifier, ProductOffersState> get logic => _map[this]!;
}

class ProductOffersWidget extends ConsumerStatefulWidget {
  final ProductOfferRepositoryFilter filter;
  ProductOffersWidget(this.filter, {super.key});

  @override
  createState() => _ProductOffersWidgetState();
}

class _ProductOffersWidgetState extends ConsumerState<ProductOffersWidget> {
  ProductOfferRepositoryFilter get _filter => widget.filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(_filter.logic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_filter.logic);
    if (state is ProductOffersSucceed || state is ProductOffersRefreshing) return _GridWidget(_filter);
    if (state is ProductOffersFailed)
      return StateErrorWidget(_filter.logic, onReload: () => ref.read(_filter.logic.notifier).refresh());
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final ProductOfferRepositoryFilter filter;
  const _GridWidget(this.filter);

  static const _columnDate = "date";
  static const _columnName = "name";
  static const _columnDescription = "description";
  static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(filter.logic) as ProductOffersSucceed;
    final productOffers = succeed.productOffers;
    return PullToRefresh(
      onRefresh: () => ref.read(filter.logic.notifier).refresh(),
      child: DataGrid<ProductOffer>(
          rows: productOffers,
          columns: [
            DataGridColumn(name: _columnDate, label: LangKeys.columnDate.tr()),
            DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
            DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          ],
          onBuildCell: (column, productOffer) => _buildCell(context, ref, column, productOffer),
          onRowTapUp: (column, data, details) => _popupOperations(context, ref, succeed, data, details),
          onReorder: (oldIndex, newIndex) async {
            if (_reorderInProgress) return context.toastWarning(LangKeys.toastReorderInProgressTitle.tr());
            _reorderInProgress = true;
            if (oldIndex < newIndex) newIndex -= 1;
            await ref.read(filter.logic.notifier).reorder(oldIndex, newIndex);
            _reorderInProgress = false;
          }),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ProductOffer productOffer) {
    final formatter = DateFormat("d. MMM yyyy", Localizations.localeOf(context).toString());
    final isBlocked = filter == ProductOfferRepositoryFilter.active && productOffer.blocked;
    final String dateString;
    switch (productOffer.type) {
      case ProductOfferType.daily:
        dateString = formatter.format(productOffer.date.toLocalDate());
      case ProductOfferType.weekly:
        final localDate = productOffer.date.toLocalDate();
        dateString = "${formatter.format(localDate.startOfWeek)} - ${formatter.format(localDate.endOfWeek)}";
      case ProductOfferType.monthly:
        final localDate = productOffer.date.toLocalDate();
        dateString = "${formatter.format(localDate.startOfMonth)} - ${formatter.format(localDate.endOfMonth)}";
      case ProductOfferType.yearly:
        final localDate = productOffer.date.toLocalDate();
        dateString = "${formatter.format(localDate.startOfYear)} - ${formatter.format(localDate.endOfYear)}";
      default:
        dateString = "-";
    }
    final columnMap = <String, ThemedText>{
      _columnDate: dateString.text.color(ref.scheme.content),
      _columnName: productOffer.name.text.color(ref.scheme.content),
      _columnDescription: productOffer.description.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ProductOffersSucceed succeed,
    ProductOffer productOffer,
    TapUpDetails details,
  ) {
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: productOffer.name,
      items: [
        if (filter == ProductOfferRepositoryFilter.active) ...{
          ProductOfferMenuItems.edit(context, ref, productOffer),
          ProductOfferMenuItems.editProducts(context, ref, productOffer),
          ProductOfferMenuItems.block(context, ref, productOffer),
          ProductOfferMenuItems.archive(context, ref, productOffer),
        },
      ],
    );
  }
}

// eof

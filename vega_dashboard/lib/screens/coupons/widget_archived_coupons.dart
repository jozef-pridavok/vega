import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/coupons.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class ArchivedCoupons extends ConsumerStatefulWidget {
  const ArchivedCoupons({super.key});

  @override
  createState() => _CouponsState();
}

class _CouponsState extends ConsumerState<ArchivedCoupons> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      ref.read(archivedCouponsLogic.notifier).load();
    });
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(archivedCouponsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(archivedCouponsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(archivedCouponsLogic);
    if (state is CouponsSucceed)
      return const _GridWidget();
    else if (state is CouponsFailed)
      return StateErrorWidget(
        archivedCouponsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.coupon : null,
        onReload: () => ref.read(archivedCouponsLogic.notifier).load(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnValidFrom = "validFrom";
  static const _columnValidTo = "validTo";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(archivedCouponsLogic) as CouponsSucceed;
    final coupons = succeed.coupons;
    return PullToRefresh(
      onRefresh: () => ref.read(archivedCouponsLogic.notifier).refresh(),
      child: DataGrid<Coupon>(
        rows: coupons,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          if (!isMobile) DataGridColumn(name: _columnValidFrom, label: LangKeys.columnValidFrom.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, coupon) => _buildCell(context, ref, column, coupon),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Coupon coupon) {
    final locale = context.languageCode;
    final columnMap = <String, Widget>{
      _columnName: coupon.name.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnDescription: coupon.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnValidFrom: formatIntDate(locale, coupon.validFrom).text.color(ref.scheme.content),
      _columnValidTo:
          formatIntDate(locale, coupon.validTo, fallback: LangKeys.cellAlwaysValid.tr()).text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Coupon coupon, TapUpDetails details) => showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: coupon.name,
        items: [
          CouponMenuItems.showProgress(context, ref, coupon),
        ],
      );
}

// eof

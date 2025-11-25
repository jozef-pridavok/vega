import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/client_user_coupons.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class UserCouponsWidget extends ConsumerStatefulWidget {
  const UserCouponsWidget({super.key});

  @override
  createState() => _UserCouponsWidgetState();
}

class _UserCouponsWidgetState extends ConsumerState<UserCouponsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientUserCouponsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientUserCouponsLogic);
    if (state is ClientUserCouponsSucceed) {
      return _GridWidget();
    } else if (state is ClientUserCouponsFailed) {
      return StateErrorWidget(
        clientUserCouponsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.user : null,
        onReload: () => ref.read(clientUserCouponsLogic.notifier).refresh(),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnRedeemedAt = "redeemedAt";
  static const _columnUserNick = "userNick";
  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnType = "type";
  static const _columnValidFrom = "validFrom";
  static const _columnValidTo = "validTo";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(clientUserCouponsLogic) as ClientUserCouponsSucceed;
    final userCoupons = succeed.userCoupons;
    return PullToRefresh(
      onRefresh: () => ref.read(clientUserCouponsLogic.notifier).refresh(),
      child: DataGrid<UserCoupon>(
        rows: userCoupons,
        columns: [
          DataGridColumn(name: _columnRedeemedAt, label: LangKeys.columnRedeemedAt.tr()),
          DataGridColumn(name: _columnUserNick, label: LangKeys.columnUserNick.tr()),
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          DataGridColumn(name: _columnType, label: LangKeys.columnType.tr()),
          DataGridColumn(name: _columnValidFrom, label: LangKeys.columnValidFrom.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, userCoupon) => _buildCell(context, ref, column, userCoupon),
        onRowTapUp: (column, userCoupon, details) => (),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, UserCoupon userCoupon) {
    final locale = context.locale.languageCode;
    final columnMap = <String, Widget>{
      _columnRedeemedAt: formatDate(locale, userCoupon.redeemedAt).text.color(ref.scheme.content),
      _columnUserNick: userCoupon.userNick.text.color(ref.scheme.content),
      _columnName: userCoupon.name.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnDescription: userCoupon.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnType: userCoupon.type!.localizedName.text.color(ref.scheme.content),
      _columnValidFrom: formatIntDate(locale, userCoupon.validFrom).text.color(ref.scheme.content),
      _columnValidTo: formatIntDate(locale, userCoupon.validTo).text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }
}

// eof
